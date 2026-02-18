# Vibe Coding 学习计划
> 基于 Claude Code，从入门到 Agent 并行加速的完整路线

---

## 总体结构

| 阶段 | 主题 | 时长 | 目标 |
|------|------|------|------|
| 第一阶段 | 大局观建立 | 半天 | 理解 vibe coding 是什么、在哪里 |
| 第二阶段 | 工具安装与心智模型 | 1 天 | 装好 Claude Code，理解正确用法 |
| 第三阶段 | 第一个真实项目 | 3–5 天 | 跑通完整流程，踩真实的坑 |
| 第四阶段 | 深度实战项目 | 1–2 周 | 建立肌肉记忆，处理复杂情况 |
| 第五阶段 | Agent 并行加速 | 3–5 天 | 从单线程变成多线程工作 |
| 第六阶段 | 系统化工作流 | 持续迭代 | 形成自己的可重复流程 |

---

## 第一阶段：大局观建立（半天）

**目标：** 在动手之前，先理解这个世界发生了什么，避免用错误的预期开始。

### 必看视频

- **Fireship — Vibe Coding Mind Virus**
  - 链接：YouTube 搜索 "Fireship vibe coding mind virus"
  - 时长：约 8 分钟
  - 内容：用 Fireship 一贯的快节奏讲清楚 vibe coding 是什么、Leo 的失败案例、边界在哪里
  - 为什么看：建立准确认知，不要被过度的成功叙事误导

- **Fireship 的 AI 编程相关视频（2–3 个）**
  - YouTube 搜索 "Fireship Claude Code" 或 "Fireship vibe coding 2025"
  - 每个 5–15 分钟
  - 为什么看：快速了解工具生态全貌

### 阅读

- Karpathy 的 Vibe Coding 定义原推（1 分钟）
  - https://x.com/karpathy/status/1886192184808149383
- Karpathy 一周年回顾（"Agentic Engineering"）（5 分钟）
  - https://x.com/karpathy/status/2019137879310836075

---

## 第二阶段：工具安装与心智模型（1 天）

**目标：** 装好 Claude Code，理解 Plan Mode 和 CLAUDE.md，完成第一个 hello world。

### 必读文章

1. **官方 Quickstart（第一优先）**
   - 链接：https://code.claude.com/docs/en/quickstart
   - 时长：20 分钟
   - 操作：跟着安装，运行 `/init`，让 Claude 创建一个 `hello.txt`

2. **codewithmukesh — Complete 2026 Guide**
   - 链接：https://codewithmukesh.com/blog/claude-code-for-beginners/
   - 时长：30 分钟阅读
   - 重点：CLAUDE.md 的作用、Plan Mode 的工作方式、和其他工具的对比

### 必看视频

- **Greg Isenberg + Ras Mic — Claude Code Clearly Explained**
  - YouTube 搜索："Greg Isenberg Claude Code Ras Mic"
  - 时长：31 分钟
  - 评价：被称为"互联网上对 Claude Code 最清晰的非技术人员解释"，推文 30 万浏览、9000 书签
  - 重点：Plan Mode、Ask User Question Tool、为什么要先规划再执行

### 第一个练习

在装好 Claude Code 后，完成以下：
```
1. 用 Plan Mode（Shift+Tab 两次）让 Claude 规划一个计算器
2. 审查计划，确认没问题后执行
3. 观察 Claude 如何创建文件、执行命令
4. 用 /compact 查看 context 压缩效果
```

---

## 第三阶段：第一个真实项目（3–5 天）

**目标：** 用一个完整的小项目跑通全流程，建立基础肌肉记忆。

### 推荐项目：简单工具类 SaaS MVP

选择以下其中一个（重要：选你自己真的需要的东西）：
- 个人习惯追踪器
- 链接书签管理工具
- 简单的文字转格式工具
- 小游戏（见下方 EnzeD Guide）

### 学习资源

1. **cgstrategylab 入门教程**
   - 链接：https://cgstrategylab.com/detailed-claude-code-vibe-coding-guide/
   - 适合：零基础，跟着做计算器项目

2. **EnzeD/vibe-coding GitHub Guide（核心资源）**
   - 链接：https://github.com/EnzeD/vibe-coding
   - 内容：完整的游戏构建指南，包含 memory-bank 架构、CLAUDE.md 模板、Git 检查点策略
   - 为什么推荐：游戏项目足够复杂，能暴露真实知识盲区

3. **Scrimba + Coursera 免费视频课（可选）**
   - 链接：https://www.coursera.org/learn/introduction-to-claude-code
   - 适合喜欢视频学习的人，可以免费旁听

### 这一阶段必须养成的习惯

- **每次超过 50 行改动，先用 Plan Mode**，看计划再执行，不要直接让 Claude 开干
- **每 1–2 小时 commit 一次 git**，让 `/rewind` 命令可以用
- **遇到问题先用 `/compact` 压缩 context**，不要让 context 超过 70% 就开始新 session
- **开始写 CLAUDE.md**，把每一个你踩过的坑和决定记录进去

### CLAUDE.md 最低要求模板

```markdown
# 项目名称

## 技术栈
- 前端：[框架]
- 后端：[框架]  
- 数据库：[数据库]
- 部署：[平台]

## 架构决定
- [记录你做的每个重要技术决定]

## 安全规则（必须）
- 所有 API endpoint 必须有 Rate Limiting
- 用户认证不能在前端校验
- 所有 secret/API Key 只能在服务端使用，绝不出现在前端代码或 git 仓库
- 数据库操作必须在 try/catch 里，并有备份策略

## 不要动的文件
- [列出已稳定的文件]

## 常用命令
- 开发：[命令]
- 测试：[命令]
- 部署：[命令]
```

---

## 第四阶段：深度实战项目（1–2 周）

**目标：** 用一个更复杂的项目，真正处理 context 管理、架构决策、迭代循环。

### 推荐资源

1. **cgstrategylab 进阶教程**
   - 链接：https://cgstrategylab.com/advanced-claude-code-vibe-coding-guide/
   - 重点：Explore Agent（用更便宜的模型分析 codebase）、Background Processes、Task Lists

2. **FlorianBruniaux/claude-code-ultimate-guide（参考手册）**
   - 链接：https://github.com/FlorianBruniaux/claude-code-ultimate-guide
   - 用法：不需要从头读，碰到问题时查询

3. **官方 Common Workflows**
   - 链接：https://code.claude.com/docs/en/common-workflows
   - 重点：Plan Mode、session 管理、CI 集成

### 这一阶段的关键能力

- 能够管理 context window（70% 时 `/compact`，90% 时强制 `/clear` 开新 session）
- 能够让 Claude 先探索再计划（"Explore, Plan, Code, Commit" 流程）
- 能够识别 Claude 输出的错误，不盲目 Accept All
- 开始为常见操作写自定义 slash commands（存放在 `.claude/commands/`）

---

## 第五阶段：Agent 并行加速（3–5 天）

**目标：** 从单个 Claude 串行工作，升级为多个 Claude 并行工作，速度提升 3–5 倍。

### 必读文章（按顺序）

1. **incident.io 工程博客（第一优先）**
   - 链接：https://incident.io/blog/shipping-faster-with-claude-code-and-git-worktrees
   - 内容：真实工程团队从 0 到"同时跑 4–5 个 Claude agent"的演变，比任何教程都真实
   - 重点：为什么要并行、哪些任务适合并行、他们踩过的坑

2. **Upsun Developer Center — Git Worktrees 完整技术指南**
   - 链接：https://devcenter.upsun.com/posts/git-worktrees-for-parallel-ai-coding-agents/
   - 内容：所有现有工具的评测（agentree、Crystal、ccswarm、gwq）
   - 重点：每种工具的优缺点，以及目前尚未解决的问题（数据库隔离、磁盘空间等）

3. **Anthropic 官方 — Common Workflows（Agent Teams 章节）**
   - 链接：https://code.claude.com/docs/en/common-workflows
   - 内容：官方文档对 worktree 和 agent teams 的描述

### 必看视频

- **IndyDevDan — How I PARALLELIZE Claude Code with Git Worktrees**
  - 搜索："IndyDevDan parallelize Claude Code git worktrees"
  - 最常被引用的并行 agent 实操视频

- **AI Code King — Self-Spawning AI Coder Team**
  - 搜索："AI Code King self spawning coder team tmux worktrees"
  - 展示用 tmux 管理多个 Claude 的实际工作流

### 动手练习（按顺序）

**练习 1：第一次手动 worktree（1 天）**
```bash
# 在项目根目录
git worktree add ../project-feature-a -b feature-a
git worktree add ../project-feature-b -b feature-b

# 打开两个终端
cd ../project-feature-a && claude   # 终端 1：Agent A 做功能 A
cd ../project-feature-b && claude   # 终端 2：Agent B 做功能 B
```
目标：感受并行的感觉，理解 worktree 的隔离机制。

**练习 2：引入工具简化操作（1 天）**
- 安装 agentree：`npm install -g agentree`
- 用 `agentree -b feature-name` 一行创建 worktree + 启动 agent
- 或安装 Crystal（桌面 GUI）可视化管理多个 session

**练习 3：尝试 Agent Teams（1–2 天）**
- 在主 Claude Code session 里，让它调度子 agent 完成独立任务
- 子 agent 完成后把结果写入 `RESULTS.md`，主 agent 汇总
- 参考官方 Agent Teams 文档

---

## 第六阶段：系统化工作流（持续迭代）

**目标：** 把前面所有学到的东西形成自己可重复的流程，不再依赖教程。

### 建立个人工具箱

- **CLAUDE.md 模板库**：为不同类型项目（SaaS、工具、游戏）各准备一个标准模板
- **自定义 Slash Commands**：把常用操作（代码审查、安全检查、部署前检查）写成命令
- **Git Alias 或脚本**：简化 worktree 创建和管理

### 进阶参考资源（按需查阅）

- ainativedev.io 并行 agent 综述：https://ainativedev.io/news/how-to-parallelize-ai-coding-agents
- shipyard.build multi-agent 指南（含 Gas Town、Multiclaude）：https://shipyard.build/blog/claude-code-multi-agent/
- Peter Steinberger 在 Lex Fridman 播客讲他的工作流（3 小时，建议 1.5 倍速）

---

## 关键原则（贯穿全程）

1. **先 Plan，再 Execute** — 任何超过简单修改的任务都用 Plan Mode
2. **CLAUDE.md 是你的永久记忆** — 把每个决定和规则写进去，越早越好
3. **Git 是你的安全网** — 频繁 commit，让 `/rewind` 始终可用
4. **Context 是消耗品** — 超过 70% 就 compact，开新 session 比继续污染 context 更好
5. **你是审查者，不是接受者** — 永远不要 Accept All 超过你能理解的改动
6. **并行是放大器，不是起点** — 先把单个 Claude 用熟，再讨论多 agent

---

## 快速参考链接

| 资源 | 链接 |
|------|------|
| 官方 Quickstart | https://code.claude.com/docs/en/quickstart |
| 官方 Common Workflows | https://code.claude.com/docs/en/common-workflows |
| codewithmukesh 入门 | https://codewithmukesh.com/blog/claude-code-for-beginners/ |
| EnzeD Vibe Coding Guide | https://github.com/EnzeD/vibe-coding |
| cgstrategylab 入门 | https://cgstrategylab.com/detailed-claude-code-vibe-coding-guide/ |
| cgstrategylab 进阶 | https://cgstrategylab.com/advanced-claude-code-vibe-coding-guide/ |
| Ultimate Guide（参考手册）| https://github.com/FlorianBruniaux/claude-code-ultimate-guide |
| Coursera 免费课 | https://www.coursera.org/learn/introduction-to-claude-code |
| incident.io 并行指南 | https://incident.io/blog/shipping-faster-with-claude-code-and-git-worktrees |
| Upsun Worktree 指南 | https://devcenter.upsun.com/posts/git-worktrees-for-parallel-ai-coding-agents/ |
| shipyard multi-agent | https://shipyard.build/blog/claude-code-multi-agent/ |
