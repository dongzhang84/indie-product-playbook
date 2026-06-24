#!/usr/bin/env bash
#
# wire-existing.sh — retrofit sprint-sync into an EXISTING repo and register it in the playbook.
#
# Unlike new-project.sh (which scaffolds a brand-new repo), this script assumes the repo
# already exists locally AND on GitHub. It does NOT create a folder, create a GitHub repo,
# copy product docs, or git init. It only:
#   1. drops the three sync files into the repo
#        .github/workflows/sprint-report.yml
#        .github/workflows/notify-playbook.yml   (project_id / project_name substituted)
#        scripts/extract-sprint-summary.py
#   2. commits + pushes ONLY those files via the repo's existing origin remote
#   3. registers the project in the playbook: a row in ideas/README.md (All Ideas)
#      + a stub ideas/<id>.md (created only if missing)
#   4. prints the PLAYBOOK_TOKEN secret URL (the one unavoidable manual step)
#
# Usage:  bash stack/wire-existing.sh <project-id> "<Project Name>" "<one-liner>" [repo-path]
#         repo-path defaults to ../<project-id>; pass it when the folder name differs.
# Docs:   stack/NEW-PROJECT.md  →  "Retrofitting an existing repo"

set -euo pipefail

# ─── Paths ───────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK_DIR="$(dirname "$SCRIPT_DIR")"

# ─── Output helpers ──────────────────────────────────────────────────────────
C_RED=$'\033[0;31m'; C_GREEN=$'\033[0;32m'; C_YELLOW=$'\033[0;33m'; C_DIM=$'\033[2m'; C_RESET=$'\033[0m'
ok()   { echo "${C_GREEN}[OK]${C_RESET} $*"; }
err()  { echo "${C_RED}[ERR]${C_RESET} $*" >&2; exit 1; }
warn() { echo "${C_YELLOW}[!]${C_RESET}  $*"; }
info() { echo "${C_DIM}  $*${C_RESET}"; }

# ─── Args ────────────────────────────────────────────────────────────────────
[[ $# -ge 3 ]] || err "Usage: bash stack/wire-existing.sh <project-id> \"<Project Name>\" \"<one-liner>\" [repo-path]"
PROJECT_ID="$1"
PROJECT_NAME="$2"
ONE_LINER="$3"
REPO_DIR_ARG="${4:-}"

[[ "$PROJECT_ID" =~ ^[A-Za-z][A-Za-z0-9_-]*$ ]] || \
  err "Invalid project-id '$PROJECT_ID' (start with a letter; letters/digits/-/_ only; must match ideas/<id>.md filename)"

# ─── Prerequisites ───────────────────────────────────────────────────────────
[[ -d "$PLAYBOOK_DIR/ideas" ]] || err "ideas/ not found (run this from the playbook repo)"
for f in sprint-report.yml notify-playbook.yml extract-sprint-summary.py; do
  [[ -f "$SCRIPT_DIR/$f" ]] || err "Missing source template: stack/$f"
done
for tool in git python3 sed; do command -v "$tool" >/dev/null || err "Required tool missing: $tool"; done

PARENT_DIR="$(cd "$PLAYBOOK_DIR/.." && pwd)"
REPO_DIR="${REPO_DIR_ARG:-$PARENT_DIR/$PROJECT_ID}"
[[ -d "$REPO_DIR" ]]      || err "Target repo folder not found: $REPO_DIR (pass [repo-path] if the folder name differs from project-id)"
[[ -d "$REPO_DIR/.git" ]] || err "Not a git repo: $REPO_DIR"
git -C "$REPO_DIR" remote get-url origin >/dev/null 2>&1 || err "Repo has no 'origin' remote: $REPO_DIR"

# Human-readable repo URL (strip embedded token and trailing .git), for the secret link + ideas stub.
REMOTE_URL="$(git -C "$REPO_DIR" remote get-url origin | sed -E 's#https://[^@]*@#https://#; s#\.git$##')"

ok "Inputs validated"
info "Repo:   $REPO_DIR"
info "Remote: $REMOTE_URL"

# ─── 1. Drop the three sync files into the existing repo ─────────────────────
mkdir -p "$REPO_DIR/.github/workflows" "$REPO_DIR/scripts"
cp "$SCRIPT_DIR/sprint-report.yml" "$REPO_DIR/.github/workflows/sprint-report.yml"
sed -e "s|YOUR_PROJECT_ID|${PROJECT_ID}|g" \
    -e "s|YOUR_PROJECT_NAME|${PROJECT_NAME}|g" \
    "$SCRIPT_DIR/notify-playbook.yml" > "$REPO_DIR/.github/workflows/notify-playbook.yml"
cp "$SCRIPT_DIR/extract-sprint-summary.py" "$REPO_DIR/scripts/extract-sprint-summary.py"
ok "Sync files written (project_id=${PROJECT_ID})"

# ─── 2. Commit + push ONLY those files via the repo's existing remote ────────
(
  cd "$REPO_DIR"
  git add .github/workflows/sprint-report.yml .github/workflows/notify-playbook.yml scripts/extract-sprint-summary.py
  if git diff --cached --quiet; then
    warn "Sync files already up to date in ${PROJECT_ID} — nothing to push"
  else
    git commit -m "ci: wire sprint-sync to indie-product-playbook" \
               -m "Adds sprint-report + notify-playbook workflows and the sprint-summary extractor." >/dev/null
    BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    git push origin "$BRANCH" >/dev/null 2>&1 || err "Push failed for ${PROJECT_ID} (check origin auth in ${REPO_DIR})"
    ok "Pushed sync files to ${PROJECT_ID}/origin (${BRANCH})"
  fi
)

# ─── 3a. Create stub ideas/<id>.md if missing ───────────────────────────────
SPEC_FILE="$PLAYBOOK_DIR/ideas/${PROJECT_ID}.md"
if [[ -f "$SPEC_FILE" ]]; then
  info "ideas/${PROJECT_ID}.md already exists — leaving it untouched"
else
  cat > "$SPEC_FILE" <<EOF
# ${PROJECT_NAME}

## One-liner

${ONE_LINER}

## Links

- Repo: ${REMOTE_URL}

## Sprint Summary

_Auto-updated by the project's notify-playbook workflow on each push._
EOF
  ok "Created ideas/${PROJECT_ID}.md"
fi

# ─── 3b. Append the All Ideas row (idempotent) ──────────────────────────────
TODAY=$(date -u +%Y-%m-%d)
ONE_LINER_ESC="${ONE_LINER//|/\\|}"
python3 - "$PROJECT_ID" "$PROJECT_NAME" "$ONE_LINER_ESC" "$TODAY" "$PLAYBOOK_DIR/ideas/README.md" <<'PYEOF'
import sys
project_id, project_name, one_liner, today, readme_path = sys.argv[1:6]
with open(readme_path) as f:
    content = f.read()
if f"[link](./{project_id}.md)" in content:
    print(f"  (skip) All Ideas row for '{project_id}' already present")
    sys.exit(0)
new_row = f"| {today}   | {project_name} | {one_liner} | In Progress | [link](./{project_id}.md) | {today} |"
lines = content.split("\n")
legend_idx = next((i for i, l in enumerate(lines) if l.startswith("## Legend")), None)
if legend_idx is None:
    print("ERROR: '## Legend' marker not found in ideas/README.md", file=sys.stderr)
    sys.exit(1)
i = legend_idx - 1
while i > 0 and lines[i].strip() == "":
    i -= 1
lines.insert(i + 1, new_row)
with open(readme_path, "w") as f:
    f.write("\n".join(lines))
print(f"  (added) All Ideas row for '{project_id}'")
PYEOF
ok "Playbook ideas/README.md updated"

# ─── 3c. Commit the playbook change (do NOT push — bundle with your next push) ─
(
  cd "$PLAYBOOK_DIR"
  git add "ideas/README.md" "ideas/${PROJECT_ID}.md"
  if git diff --cached --quiet; then
    info "No playbook changes to commit"
  else
    git commit -m "ideas: register ${PROJECT_NAME} via wire-existing.sh" >/dev/null
    ok "Playbook commit created (not pushed)"
  fi
)

# ─── 4. Final report ─────────────────────────────────────────────────────────
SECRET_URL="${REMOTE_URL}/settings/secrets/actions"
echo ""
echo "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo "${C_GREEN}  Done.${C_RESET} ${PROJECT_NAME} is wired into the playbook."
echo ""
echo "  Repo:     ${REMOTE_URL}"
echo "  Playbook: ideas/${PROJECT_ID}.md + a row in ideas/README.md (committed, not pushed)"
echo ""
echo "${C_YELLOW}  One manual step (30 seconds):${C_RESET}  add the dispatch token"
echo "    1. Open ${SECRET_URL}"
echo "    2. New repository secret  →  Name: PLAYBOOK_TOKEN"
echo "    3. Value: the same token teachloop / physlit / etc. use"
echo ""
echo "  Until that secret exists, the first notify-playbook run will fail (harmless)."
echo "  After it's set, every push to ${PROJECT_ID} updates the playbook's"
echo "  Last Active date and Sprint Summary automatically."
echo "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
