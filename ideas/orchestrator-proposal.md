# Vibe Coding Orchestrator — 详细设计方案

## 背景与目标

### 现状痛点
- 双窗口工作流：Claude.ai（规划）+ Claude Code CLI（执行）
- 人工在两者之间传递信息，效率低
- 每次需要手动复制 prompt，上下文容易丢失

### 目标
用一个编排脚本替代人工搬运，让 Planner Claude 和 Claude Code 自动协作，你只需要用自然语言表达意图。

---

## 系统架构

```
┌─────────────────────────────────────────────┐
│                   你                        │
│         （自然语言输入 / 决策确认）           │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│             Orchestrator (Python)            │
│  - 管理对话循环                              │
│  - 读取项目上下文 (CLAUDE.md / git info)     │
│  - 协调 Planner 和 Executor 之间的信息流     │
└──────────┬───────────────────┬──────────────┘
           │                   │
           ▼                   ▼
┌──────────────────┐  ┌────────────────────────┐
│  Planner Claude  │  │   Claude Code (CLI)     │
│  (Anthropic API) │  │   (subprocess)          │
│                  │  │                         │
│  - 理解你的意图  │  │  - 实际写代码            │
│  - 生成精确 CC   │  │  - 执行文件操作          │
│    prompt        │  │  - 运行命令              │
│  - 维护项目状态  │  │  - 返回执行结果          │
└──────────────────┘  └────────────────────────┘
```

---

## 交互流程（每一轮）

```
Step 1  你输入自然语言需求
        例："帮我加一个用户登录页面，用 shadcn 的组件"

Step 2  Orchestrator 收集上下文
        - 读取 CLAUDE.md（项目背景、技术栈、约定）
        - 读取最近 git log（知道做到哪一步了）
        - 加上完整对话历史

Step 3  发给 Planner Claude (API)
        - Planner 理解意图
        - 如有歧义，先提问澄清（返回给你）
        - 生成结构化的 Claude Code prompt

Step 4  展示 prompt 给你确认
        [Planner 生成的 prompt 预览]
        > 确认发送？(y) / 修改(e) / 跳过(s)

Step 5  Orchestrator 调用 Claude Code CLI
        $ claude --print "<prompt>"
        实时流式输出 CC 的执行过程

Step 6  执行结果返回
        - 显示 CC 做了什么
        - Orchestrator 自动 git diff 展示变更摘要

Step 7  你决定下一步
        > 继续下一步 / 有问题要修正 / 结束
```

---

## 目录结构

```
vibe-orchestrator/
├── main.py                  # 入口，主循环
├── planner.py               # Planner Claude API 封装
├── executor.py              # Claude Code CLI 调用封装
├── context.py               # 项目上下文读取（CLAUDE.md, git）
├── config.py                # 配置（API key, 模型, 路径等）
├── history.py               # 对话历史管理
├── utils.py                 # 工具函数（颜色输出、确认提示等）
├── .env                     # API key（不入 git）
├── requirements.txt
└── README.md
```

---

## 各模块详细设计

### 1. `config.py` — 配置管理

```python
# 从 .env 读取
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")

# Planner 用的模型
PLANNER_MODEL = "claude-opus-4-5"

# Claude Code CLI 路径
CLAUDE_CLI = "claude"

# 项目上下文文件名
CONTEXT_FILE = "CLAUDE.md"
```

---

### 2. `context.py` — 上下文读取

**读取内容：**
- `CLAUDE.md`：项目目标、技术栈、当前阶段、约定
- `git log --oneline -10`：最近 10 条 commit，了解进展
- `git status`：当前工作区状态
- 项目根目录结构（tree，2 层深度）

**注入格式（发给 Planner 的 system prompt 片段）：**
```
=== 项目上下文 ===
[CLAUDE.md 内容]

=== 最近 Git 记录 ===
[git log 输出]

=== 当前文件状态 ===
[git status 输出]
```

**启动方式：**
```bash
python main.py --project /path/to/your/project
```
脚本自动从项目目录读取上下文，无需手动粘贴。

---

### 3. `planner.py` — Planner Claude 封装

**System Prompt 核心内容：**
```
你是一个资深的技术规划助手，专门帮助用户和 Claude Code 协作。

你的工作：
1. 理解用户的开发意图（可能表达模糊）
2. 结合项目上下文，生成精确、可执行的 Claude Code prompt
3. 如果需求不清晰，先提问，不要猜测
4. 生成的 prompt 要包含：具体目标、技术约定、边界条件、不能改动的地方

输出格式：
- 如果需要澄清：以 [CLARIFY] 开头，列出问题
- 如果可以生成：以 [PROMPT] 开头，后跟给 CC 的完整 prompt
```

**对话历史管理：**
- 全程维护 `messages[]` 数组
- 每轮把 CC 的执行结果也作为上下文传回 Planner
- Planner 因此知道"做到哪一步了"

---

### 4. `executor.py` — Claude Code CLI 封装

**调用方式：**
```python
import subprocess

def run_claude_code(prompt: str, project_dir: str) -> str:
    result = subprocess.run(
        ["claude", "--print", prompt],
        cwd=project_dir,
        capture_output=True,
        text=True,
        timeout=300
    )
    return result.stdout
```

**执行后自动做：**
- `git diff --stat`：显示改动了哪些文件
- 提示用户是否 commit（可选自动 commit）

---

### 5. `main.py` — 主循环

```
启动
  ↓
读取项目上下文
  ↓
初始化 Planner（注入 system prompt + 上下文）
  ↓
循环开始
  ├─ 等待你输入
  ├─ 发给 Planner
  ├─ Planner 返回 [CLARIFY] → 展示问题 → 等你回答 → 继续
  ├─ Planner 返回 [PROMPT] → 展示 prompt → 等你确认
  ├─ 确认后 → 调用 CC
  ├─ 展示 CC 结果 + git diff
  └─ 把结果反馈给 Planner → 下一轮
```

---

## 终端 UI 设计

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🎯 Vibe Orchestrator
  项目: my-saas-app  |  分支: feature/auth
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[你] 加一个用户登录页面，用 shadcn 的组件

[Planner 思考中...]

[Planner → CC Prompt]
─────────────────────
在 src/app/login/page.tsx 创建登录页面：
- 使用 shadcn/ui 的 Card, Input, Button 组件
- 表单字段：email, password
- 接入已有的 useAuth hook（位于 src/hooks/useAuth.ts）
- 不要修改 layout.tsx
- 样式跟随项目现有的 Tailwind 配置
─────────────────────

[确认发送给 Claude Code？] (y/修改/跳过): y

[Claude Code 执行中...]
─────────────────────
[CC 实时输出流]
─────────────────────

[变更摘要]
  新增: src/app/login/page.tsx (+87 行)
  修改: src/app/page.tsx (+3 行，加了登录入口)

[你] 下一步做什么？ / 有问题输入:
```

---

## 开发阶段计划

### Phase 1 — MVP（目标：跑通一轮完整流程）

- [ ] `config.py`：读取 API key
- [ ] `context.py`：读取 CLAUDE.md + git log
- [ ] `planner.py`：基础 API 调用，单轮
- [ ] `executor.py`：调用 CC CLI，拿输出
- [ ] `main.py`：串起来，手动输入跑通一次
- [ ] 基础终端输出（颜色区分角色）

**完成标志：** 你输入一句话，能看到 Planner 生成 prompt，CC 执行，结果返回。

---

### Phase 2 — 上下文记忆（目标：多轮连贯对话）

- [ ] `history.py`：维护完整对话历史
- [ ] 每轮把 CC 输出反馈给 Planner
- [ ] Planner 能基于历史给出连贯建议
- [ ] git diff 摘要自动注入上下文

**完成标志：** 做完登录页后说"再加注册页，风格和登录页一致"，Planner 知道登录页长什么样。

---

### Phase 3 — 项目初始化体验（目标：开新项目更顺滑）

- [ ] 如果项目没有 CLAUDE.md，引导你填写并自动生成
- [ ] 支持 `--project` 参数指定项目目录
- [ ] 启动时展示项目摘要（最近 commit、当前分支等）

---

### Phase 4 — 可选增强

- [ ] 支持 `clarify` 模式（Planner 先问问题再生成）
- [ ] 自动 commit 功能（每轮执行后可选）
- [ ] 会话存档（把每次对话保存成 JSON，可以复盘）
- [ ] Web UI（用 Gradio 或简单 HTML，如果终端不够用）

---

## 环境要求

| 依赖 | 版本 | 用途 |
|------|------|------|
| Python | 3.10+ | 运行环境 |
| anthropic | latest | Planner API 调用 |
| python-dotenv | latest | 读取 .env |
| claude CLI | latest | 执行 Claude Code |
| git | 任意 | 读取项目状态 |

安装：
```bash
pip install anthropic python-dotenv
```

---

## 启动命令

```bash
# 进入 orchestrator 目录
cd vibe-orchestrator

# 设置 API key
echo "ANTHROPIC_API_KEY=your_key_here" > .env

# 启动，指定项目目录
python main.py --project /path/to/your/project
```

---

## 第一步行动

确认方案后，从 Phase 1 MVP 开始，预计 1-2 小时可以跑通第一个完整循环。

是否开始写代码？
