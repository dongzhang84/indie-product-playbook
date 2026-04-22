# New Project Bootstrap — 零门槛新建仓库

一条命令把"写完产品说明和技术步骤"之后的所有仓库 / workflow / 同步管道跑通。

---

## 下次你要建新 repo，做这 4 件事

### 1. 让 Claude 写产品说明

跟 Claude 说：
> 我想做一个 XXX，参照 vibe-reading 的格式写产品说明，放到 ideas/ 里。

Claude 产出 `ideas/<id>.md`。

### 2. 让 Claude 写技术步骤

跟 Claude 说：
> 基于 ideas/<id>.md 和 stack/STANDARD.md 写技术步骤，放到 implementation-guides/ 里。

Claude 产出 `implementation-guides/<id>.md`。

### 3. 跑一条命令

在 indie-product-playbook 根目录：

```bash
bash stack/new-project.sh <id> "<项目名>"
```

例子：
```bash
bash stack/new-project.sh vibe-writing "Vibe Writing"
```

这一条命令自动：建 `../vibe-writing/` 文件夹、拷 docs、配 workflow、创建 GitHub public repo、push。

### 4. 点一个链接加 PLAYBOOK_TOKEN

脚本最后会打印一个 URL。点进去，`New repository secret`，名字填 `PLAYBOOK_TOKEN`，值填你其他 repo 用的同一个 token。30 秒。

**完。**

> 也可以直接跟 Claude 说"按新项目流程走，项目叫 XXX"——Claude 会按顺序走这 4 步。

---

---

## 前置要求（一次性，以后不用管）

- GitHub personal access token 存在下面任一位置：
  - 环境变量 `$GITHUB_TOKEN`
  - indie-product-playbook 的 `.git/config`（remote URL 里嵌着 `ghp_...`，当前就是这样）
- 系统装了 `git`, `curl`, `jq`, `python3`, `sed`, `awk`（macOS 全部默认有）
- 你在 `dongzhang84` 这个 GitHub 账号下工作（脚本硬编码了这个用户名，改 `new-project.sh` 里 `GITHUB_USER=` 可以换）

---

## 完整流程

### Step 1 — 产品说明（你 + Claude 对话）

和 Claude 对话产出 `ideas/<project-id>.md`，参照 `ideas/vibe-reading.md` 的结构：

- `# <项目名>` 标题
- `## One-liner` — **脚本会从这里抽取 one-liner，必须有**
- 其它 section 自由（Problem / Solution / Target Users / Differentiation / MVP Boundaries / Success Criteria 等）

> **命名**：`<project-id>` 必须是 kebab-case（小写字母、数字、连字符；字母开头）。比如 `vibe-reading`、`teachloop`、`x-growth-radar`。

### Step 2 — 技术步骤 v1（你 + Claude 对话）

让 Claude 基于 `ideas/<project-id>.md` + `stack/STANDARD.md` 写 `implementation-guides/<project-id>.md`。参照现有的 `teachloop.md` / `growpilot.md` 结构：

- Header（stack、repo、last updated）
- Golden Rules（如果有）
- Phase 0–N + Checklist

### Step 3 — 跑脚本

```bash
cd /path/to/indie-product-playbook
bash stack/new-project.sh vibe-writing "Vibe Writing"
```

脚本自动做这些事：

| # | 动作 | 产物 |
|---|------|------|
| 1 | 从 `ideas/<id>.md` 抽 `## One-liner` | 内存变量 |
| 2 | 在 `ideas/README.md` 的 All Ideas 表追加一行（若没有） | 改 playbook |
| 3 | 创建 `../<id>/docs/` | 新仓库 |
| 4 | `ideas/<id>.md` → `docs/product-spec.md` | 新仓库 |
| 5 | `implementation-guides/<id>.md` → `docs/implementation-guide.md` | 新仓库 |
| 6 | 拷贝 `sprint-report.yml` + 替换占位符生成 `notify-playbook.yml` | 新仓库 |
| 7 | 拷贝 `extract-sprint-summary.py` | 新仓库 |
| 8 | 从 `templates/` 渲染 `.gitignore` + `README.md` + `.env.local` | 新仓库 |
| 9 | `git init` + 初始 commit（安全检查：`.env.local` 必须被忽略） | 新仓库 |
| 10 | GitHub API 创建 public repo | github.com |
| 11 | set remote + push | github.com |
| 12 | playbook 自动 commit `ideas/README.md` 改动（**不 push**，留给你手动） | playbook |

### Step 4 — 加 PLAYBOOK_TOKEN secret（手动 30 秒）

脚本最后会打印 URL。点进去：

1. 打开 `https://github.com/dongzhang84/<id>/settings/secrets/actions`
2. `New repository secret`
3. Name: **PLAYBOOK_TOKEN**
4. Value: 和 teachloop / growpilot 等其他项目**同一个** token（在你本地别的项目 `.env.local` 里，或者从已有 repo 的 secret 设置里知道）

加完，下次对新 repo 任何 push 会触发：
- `sprint-report.yml` 生成 `SPRINT.md`（新 repo 内部）
- `notify-playbook.yml` 通知 playbook，更新 `ideas/README.md` 的 `Last Active` 列和 `ideas/<id>.md` 的 Sprint Summary section

---

## 一个完整示例

假设要做一个新项目 `vibe-writing`：

```bash
cd ~/Projects/indie-product-playbook

# (1) 让 Claude 写产品说明
#     "我想做一个 Vibe Writing，参照 vibe-reading 的哲学做写作端……"
#     → ideas/vibe-writing.md

# (2) 让 Claude 写技术步骤
#     "基于 ideas/vibe-writing.md 和 stack/STANDARD.md 写 implementation-guides/vibe-writing.md"
#     → implementation-guides/vibe-writing.md

# (3) 跑脚本
bash stack/new-project.sh vibe-writing "Vibe Writing"

# 输出：
# [OK] Inputs validated
#      GitHub token found (length 40)
#      One-liner: A writing tool that ...
# [OK] Playbook ideas/README.md updated
# [OK] Docs copied → docs/product-spec.md + docs/implementation-guide.md
# [OK] Workflows + sprint extractor wired up (project_id=vibe-writing)
# [OK] Templates rendered (.gitignore, README.md, .env.local)
# [OK] Local git repo initialized and committed
#      Creating public GitHub repo: dongzhang84/vibe-writing
# [OK] GitHub repo created: https://github.com/dongzhang84/vibe-writing
# [OK] Pushed initial commit to origin/main
# [OK] Playbook commit created (not pushed — bundle with your next push)
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#   Done. Vibe Writing is ready.
#   Repo:   https://github.com/dongzhang84/vibe-writing
#   Local:  /Users/dong/Projects/vibe-writing
#
#   One manual step (30 seconds):
#   Add PLAYBOOK_TOKEN secret so sprint sync works bidirectionally.
#     1. Open https://github.com/dongzhang84/vibe-writing/settings/secrets/actions
#     2. New repository secret  →  Name: PLAYBOOK_TOKEN
#     3. Value: same token as used by teachloop / growpilot / etc.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# (4) 打开 URL，粘 PLAYBOOK_TOKEN，完
# (5) 需要的时候 push playbook 的 README 改动（脚本已 commit，没 push）
```

---

## 脚本会拒绝的情况（友好报错）

| 情况 | 错误信息 |
|------|---------|
| `<project-id>` 不是 kebab-case | `Invalid project-id` |
| 不在 playbook 根目录跑 / `ideas/` 找不到 | `ideas/ not found (is this the playbook repo?)` |
| `ideas/<id>.md` 不存在 | `Missing product spec: ...` |
| `implementation-guides/<id>.md` 不存在 | `Missing implementation guide: ...` |
| 本地 `../<id>/` 目录已存在 | `Target folder already exists: ...` |
| GitHub token 找不到 | `No GitHub token found` |
| GitHub 上同名 repo 已存在 | `GitHub API error: Repository creation failed.` |
| `.env.local` 不小心要被 commit | `CRITICAL: .env.local is staged` |

遇到错误脚本立即 abort，不会做半截。重跑之前把 `../<id>/` 删掉即可。

---

## 脚本**不**做的事（刻意）

- ❌ **不生成产品内容**。产品说明和技术步骤是你 + Claude 的认知工作，不能自动化。
- ❌ **不排优先级**。脚本插到 All Ideas 表末尾，Roadmap 优先级表（README.md 顶部那张）你自己手动改。
- ❌ **不设 PLAYBOOK_TOKEN**（GitHub secret 要 libsodium 加密，手动一次搞定更省事）。
- ❌ **不 push playbook 的 README 改动**（保留给你和其他改动一起 push）。
- ❌ **不改 `remote.origin.url` 里的 token 方式**（当前是 embed ghp_ 到 URL——想治本就 `brew install gh && gh auth login`，不在本脚本范围）。

---

## 模板自定义

三个模板在 `stack/templates/` 下，想改长什么样直接编辑：

- `gitignore` — 新 repo 的 `.gitignore` 内容（Next.js + macOS + env 的标准一套）
- `README.md` — 新 repo 的首页 README（带 `{{PROJECT_NAME}}` / `{{ONE_LINER}}` / `{{TODAY}}` / `{{GITHUB_USER}}` 占位符）
- `env-local` — 新 repo 的 `.env.local` 种子（含 `{{GITHUB_TOKEN}}`，gitignore 自动排除）

可用的占位符（都会被 `{{VAR}}` 语法替换）：

- `{{PROJECT_ID}}` — 比如 `vibe-writing`
- `{{PROJECT_NAME}}` — 比如 `Vibe Writing`
- `{{ONE_LINER}}` — 从 spec 抽取的一句话
- `{{TODAY}}` — 当天（UTC, YYYY-MM-DD）
- `{{GITHUB_USER}}` — `dongzhang84`
- `{{GITHUB_TOKEN}}` — PAT 原文（只给 `.env.local` 用）

---

## FAQ

**Q: 能不能跳过产品说明 / 技术步骤直接建 repo？**
A: 不能。脚本强制要求 `ideas/<id>.md` 和 `implementation-guides/<id>.md` 都存在。这是刻意设计——强迫你在建 repo 之前把"这是什么 / 怎么做"想清楚，避免建完 repo 又不知道下一步写啥的尴尬。

**Q: 跑一半失败了怎么办？**
A: 脚本 `set -euo pipefail`，第一个错误立即 abort。重跑之前：
  - 如果 `../<id>/` 建了一部分：`rm -rf ../<id>`
  - 如果 GitHub 上 repo 建了：手动去 GitHub UI 删
  - 如果 `ideas/README.md` 加了行：脚本第二次跑时会自动跳过（幂等）

**Q: 能不能先本地建好再推 GitHub？**
A: 目前是一条龙。想分两步可以临时注释掉脚本末尾的 GitHub API + push 段落——但建议不要这样做，容易忘。

**Q: Project name 能带空格吗？**
A: 能（就是传给脚本的第二个参数，用引号包起来）。但 project-id（第一个参数）不能带空格，必须 kebab-case。

**Q: PLAYBOOK_TOKEN 和嵌在 URL 里的 `ghp_` 是同一个 token 吗？**
A: 目前是的——都是你的 PAT。未来想区分权限时可以分开（PLAYBOOK_TOKEN 只给 public_repo + dispatch 的 fine-grained token），但现阶段用同一个省事。

---

## 相关文件

- `stack/new-project.sh` — 主脚本
- `stack/templates/` — 新 repo 的种子模板
- `stack/sprint-report.yml` + `stack/notify-playbook.yml` — workflow 源（脚本从这里拷）
- `stack/extract-sprint-summary.py` — sprint summary 抽取脚本源
- `stack/STANDARD.md` — 代码层面的标准栈（独立关注点，本脚本不涉及）
