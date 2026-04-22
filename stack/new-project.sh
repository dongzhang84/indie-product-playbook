#!/usr/bin/env bash
#
# new-project.sh — bootstrap a new repo from an existing ideas + implementation-guides pair.
#
# Usage:  bash stack/new-project.sh <project-id> "<Project Name>"
# Docs:   stack/NEW-PROJECT.md

set -euo pipefail

# ─── Paths ───────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
GITHUB_USER="dongzhang84"

# ─── Output helpers ──────────────────────────────────────────────────────────
C_RED=$'\033[0;31m'
C_GREEN=$'\033[0;32m'
C_YELLOW=$'\033[0;33m'
C_DIM=$'\033[2m'
C_RESET=$'\033[0m'

ok()   { echo "${C_GREEN}[OK]${C_RESET} $*"; }
err()  { echo "${C_RED}[ERR]${C_RESET} $*" >&2; exit 1; }
warn() { echo "${C_YELLOW}[!]${C_RESET}  $*"; }
info() { echo "${C_DIM}  $*${C_RESET}"; }

# ─── Args ────────────────────────────────────────────────────────────────────
[[ $# -eq 2 ]] || err "Usage: bash stack/new-project.sh <project-id> \"<Project Name>\""

PROJECT_ID="$1"
PROJECT_NAME="$2"

[[ "$PROJECT_ID" =~ ^[a-z][a-z0-9-]*$ ]] || \
  err "Invalid project-id '$PROJECT_ID' (use kebab-case: lowercase letters/digits/hyphens, start with a letter)"

# ─── Prerequisites ───────────────────────────────────────────────────────────
[[ -d "$PLAYBOOK_DIR/ideas" ]] || err "ideas/ not found (is this the playbook repo?)"
[[ -d "$PLAYBOOK_DIR/implementation-guides" ]] || err "implementation-guides/ not found"
[[ -d "$TEMPLATES_DIR" ]] || err "stack/templates/ not found"

for tool in git curl jq python3 sed awk; do
  command -v "$tool" >/dev/null || err "Required tool missing: $tool"
done

SPEC_FILE="$PLAYBOOK_DIR/ideas/${PROJECT_ID}.md"
IMPL_FILE="$PLAYBOOK_DIR/implementation-guides/${PROJECT_ID}.md"
PARENT_DIR="$(cd "$PLAYBOOK_DIR/.." && pwd)"
NEW_REPO_DIR="$PARENT_DIR/${PROJECT_ID}"

[[ -f "$SPEC_FILE" ]] || err "Missing product spec: $SPEC_FILE (write it first)"
[[ -f "$IMPL_FILE" ]] || err "Missing implementation guide: $IMPL_FILE (write it first)"
[[ ! -e "$NEW_REPO_DIR" ]] || err "Target folder already exists: $NEW_REPO_DIR"

ok "Inputs validated"

# ─── GitHub token ────────────────────────────────────────────────────────────
TOKEN=""
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  TOKEN="$GITHUB_TOKEN"
elif [[ -f "$PLAYBOOK_DIR/.git/config" ]]; then
  TOKEN=$(grep -oE 'ghp_[A-Za-z0-9]+' "$PLAYBOOK_DIR/.git/config" 2>/dev/null | head -1 || true)
fi
[[ -n "$TOKEN" ]] || err "No GitHub token found (set \$GITHUB_TOKEN, or embed ghp_ token in playbook's .git/config)"
info "GitHub token found (length ${#TOKEN})"

# ─── Extract one-liner from product spec ─────────────────────────────────────
ONE_LINER=$(awk '
  /^## One-liner/ { flag=1; next }
  flag && NF {
    gsub(/\|/, "\\|")       # escape pipes for markdown table
    print
    exit
  }
' "$SPEC_FILE")

if [[ -z "$ONE_LINER" ]]; then
  warn "Could not extract '## One-liner' section from $SPEC_FILE; using placeholder '—'"
  ONE_LINER="—"
fi

TODAY=$(date -u +%Y-%m-%d)
info "One-liner: $ONE_LINER"

# ─── Update ideas/README.md (append row if not present) ──────────────────────
python3 - "$PROJECT_ID" "$PROJECT_NAME" "$ONE_LINER" "$TODAY" "$PLAYBOOK_DIR/ideas/README.md" <<'PYEOF'
import sys
project_id, project_name, one_liner, today, readme_path = sys.argv[1:6]

with open(readme_path) as f:
    content = f.read()

# Idempotent: if a row links to this project's file, skip.
if f"[link](./{project_id}.md)" in content:
    print(f"  (skip) README row for '{project_id}' already present")
    sys.exit(0)

new_row = f"| {today}   | {project_name} | {one_liner} | Proposal | [link](./{project_id}.md) | {today} |"

lines = content.split("\n")
legend_idx = None
for i, line in enumerate(lines):
    if line.startswith("## Legend"):
        legend_idx = i
        break
if legend_idx is None:
    print("ERROR: '## Legend' marker not found in README.md", file=sys.stderr)
    sys.exit(1)

# Walk back from Legend to find last non-empty line (= last existing table row)
i = legend_idx - 1
while i > 0 and lines[i].strip() == "":
    i -= 1

lines.insert(i + 1, new_row)

with open(readme_path, "w") as f:
    f.write("\n".join(lines))
print(f"  (added) README row inserted for '{project_id}'")
PYEOF
ok "Playbook ideas/README.md updated"

# ─── Create new repo structure ───────────────────────────────────────────────
mkdir -p "$NEW_REPO_DIR/docs" "$NEW_REPO_DIR/.github/workflows" "$NEW_REPO_DIR/scripts"

cp "$SPEC_FILE" "$NEW_REPO_DIR/docs/product-spec.md"
cp "$IMPL_FILE" "$NEW_REPO_DIR/docs/implementation-guide.md"
ok "Docs copied → docs/product-spec.md + docs/implementation-guide.md"

cp "$SCRIPT_DIR/sprint-report.yml" "$NEW_REPO_DIR/.github/workflows/sprint-report.yml"

# Substitute project_id and project_name into notify-playbook.yml
# Use `|` as sed delimiter since path-safe; template placeholders are simple ASCII.
sed -e "s|YOUR_PROJECT_ID|${PROJECT_ID}|g" \
    -e "s|YOUR_PROJECT_NAME|${PROJECT_NAME}|g" \
    "$SCRIPT_DIR/notify-playbook.yml" > "$NEW_REPO_DIR/.github/workflows/notify-playbook.yml"

cp "$SCRIPT_DIR/extract-sprint-summary.py" "$NEW_REPO_DIR/scripts/extract-sprint-summary.py"
ok "Workflows + sprint extractor wired up (project_id=${PROJECT_ID})"

# ─── Render templates via Python (handles any chars in values) ───────────────
render_templates() {
  python3 - "$TEMPLATES_DIR" "$NEW_REPO_DIR" \
    "$PROJECT_ID" "$PROJECT_NAME" "$ONE_LINER" "$TODAY" "$GITHUB_USER" "$TOKEN" <<'PYEOF'
import sys, os
templates_dir, repo_dir, pid, pname, oneliner, today, guser, gtoken = sys.argv[1:9]

vars_ = {
    "PROJECT_ID":   pid,
    "PROJECT_NAME": pname,
    "ONE_LINER":    oneliner,
    "TODAY":        today,
    "GITHUB_USER":  guser,
    "GITHUB_TOKEN": gtoken,
}

mapping = [
    ("gitignore",  ".gitignore"),
    ("README.md",  "README.md"),
    ("env-local",  ".env.local"),
]

for src_name, dst_name in mapping:
    src = os.path.join(templates_dir, src_name)
    dst = os.path.join(repo_dir, dst_name)
    with open(src) as f:
        content = f.read()
    for k, v in vars_.items():
        content = content.replace("{{" + k + "}}", v)
    with open(dst, "w") as f:
        f.write(content)
PYEOF
}
render_templates
ok "Templates rendered (.gitignore, README.md, .env.local)"

# ─── git init + initial commit in new repo ──────────────────────────────────
(
  cd "$NEW_REPO_DIR"
  git init -b main >/dev/null
  git add . >/dev/null

  # Safety gate: .env.local must NOT be in the index
  if git diff --cached --name-only | grep -qx '.env.local'; then
    err "CRITICAL: .env.local is staged (would leak GITHUB_TOKEN). Check .gitignore."
  fi

  git commit -m "initial commit — ${PROJECT_NAME} docs + CI" \
             -m "Product spec + implementation guide (v1) + sprint-report/notify-playbook workflows." \
             >/dev/null
)
ok "Local git repo initialized and committed"

# ─── Create public GitHub repo ───────────────────────────────────────────────
info "Creating public GitHub repo: ${GITHUB_USER}/${PROJECT_ID}"

api_response=$(jq -n \
  --arg name "$PROJECT_ID" \
  --arg desc "$ONE_LINER" \
  '{name: $name, description: $desc, private: false, auto_init: false}' | \
  curl -sS -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -d @- \
    https://api.github.com/user/repos)

api_error=$(echo "$api_response" | jq -r 'if type == "object" and has("message") then .message else empty end')
if [[ -n "$api_error" ]]; then
  err "GitHub API error: $api_error"
fi
ok "GitHub repo created: https://github.com/${GITHUB_USER}/${PROJECT_ID}"

# ─── Set remote + push ───────────────────────────────────────────────────────
(
  cd "$NEW_REPO_DIR"
  git remote add origin "https://${TOKEN}@github.com/${GITHUB_USER}/${PROJECT_ID}.git"
  git push -u origin main >/dev/null 2>&1
)
ok "Pushed initial commit to origin/main"

# ─── Auto-commit the playbook README change ─────────────────────────────────
(
  cd "$PLAYBOOK_DIR"
  if ! git diff --quiet ideas/README.md; then
    git add ideas/README.md
    git commit -m "ideas: add ${PROJECT_NAME} row via new-project.sh" >/dev/null
    ok "Playbook commit created (not pushed — bundle with your next push)"
  fi
)

# ─── Final report ────────────────────────────────────────────────────────────
echo ""
echo "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo "${C_GREEN}  Done.${C_RESET} ${PROJECT_NAME} is ready."
echo ""
echo "  Repo:   https://github.com/${GITHUB_USER}/${PROJECT_ID}"
echo "  Local:  $NEW_REPO_DIR"
echo ""
echo "${C_YELLOW}  One manual step (30 seconds):${C_RESET}"
echo "  Add PLAYBOOK_TOKEN secret so sprint sync works bidirectionally."
echo ""
echo "    1. Open https://github.com/${GITHUB_USER}/${PROJECT_ID}/settings/secrets/actions"
echo "    2. New repository secret  →  Name: PLAYBOOK_TOKEN"
echo "    3. Value: same token as used by teachloop / growpilot / etc."
echo ""
echo "  After that, push anything → sprint-report + notify-playbook run."
echo "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
