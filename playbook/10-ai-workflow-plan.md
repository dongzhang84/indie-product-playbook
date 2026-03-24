# Dong Zhang — AI 私人秘书系统规划文档

**版本：** v2.0  
**日期：** 2026-03-24  
**状态：** 执行中

---

## 一、核心需求

### 1.1 我是谁，我在做什么

同时推进多个 vibe coding 项目的独立开发者，工作时间 早上8-9点 → 晚上10点。

| 项目 | 状态 | 描述 |
|------|------|------|
| **LaunchRadar** | 开发中 | 市场需求分析工具 |
| **AceRocket** | 开发中 | AI 数学/STEM 教育平台 |
| **SAT/AP** | 开发中 | 考试辅导工具 |
| **ProfitPilot** | 开发中 | 盈利分析工具 |
| **Socrates Finds You** | 开发中 | 自动获客 pipeline |

### 1.2 我真正要的：一个永远在线的AI私人秘书

不是工具，是秘书。它需要：

- **监控** — 自动知道我今天做了什么，不需要我汇报，不只是 git，包括我在哪个 App 待了多久
- **规划** — 主动告诉我明天该做什么，顺序怎么排，哪些并行
- **执行** — 配合 CC 自动化任务，每阶段汇报，防止跑偏
- **推送** — 主动找我，不是我找它，发到手机
- **进化** — 数据越积累越了解我的节奏和工作习惯，建议越来越准

### 1.3 痛点

1. **人肉中间层** — 在 Claude Console 和 CC Terminal 之间手动传话
2. **CC 跑偏** — 跑很远了才发现方向错了，浪费大量时间
3. **多项目切换成本高** — 每天只能有效推进 1 个项目
4. **没有全局视野** — 不知道每个项目今天该做什么
5. **没有自动复盘** — 没有人帮我记录昨天做了什么

---

## 二、工具评估结论

### 现成工具都不够用

| 工具 | 能做 | 不能做 |
|------|------|--------|
| Claude Cowork | 读文件、执行任务、定时任务 | 跨天记忆、主动推送、监控活动、Mac关了就停 |
| OpenClaw | 感知本地文件、Heartbeat推送、24h运行 | 需要自己配置skill |
| ActivityWatch | 记录所有App活动时间 | 本身不做规划推送 |
| Motion / Reclaim | 日历调度 | 不懂代码项目 |

### 结论

**没有任何现成产品能满足需求。必须组合三个工具自己搭。**

---

## 三、系统架构：三层秘书系统

```
感知层（眼睛）
└── ActivityWatch — 记录你在哪个App待了多久、编辑器在哪个文件
└── Git Commits — 记录代码进展
└── 终端日志 — 记录CC运行状态

        ↓ 数据流向

大脑层（决策）
└── OpenClaw on Mac Mini（24小时运行）
    ├── 每天深夜读取ActivityWatch数据 + git commits
    ├── 生成今日复盘 → 写入 logs/YYYY-MM-DD.md
    ├── 每天早上8:30读取昨日复盘 → 生成今日建议
    └── 数据积累后越来越了解你的节奏

        ↓ 推送

推送层（嘴巴）
└── Telegram Bot → 你的手机
    "Dong，今日简报：
    - 昨天在AceRocket花了3小时，PDF解析卡住
    - LaunchRadar发现5条Shopify需求
    - 建议：先30分钟修AceRocket，再推LaunchRadar
    - Socrates草稿已准备好，待审核"

        ↓ 执行

执行层（手）
└── Claude Code on MacBook Pro
    ├── LaunchRadar
    ├── AceRocket
    ├── SAT/AP
    ├── ProfitPilot
    └── Socrates
```

---

## 四、每日标准流程（目标状态）

**早上 8:30 — 手机收到 Telegram 晨报**
不需要开电脑，已经知道今天做什么

**早上 9:00 — 开电脑直接执行**
按晨报建议开多个 CC 窗口，并行跑任务

**白天 — CC 自动阶段汇报**
每完成一个阶段暂停，你验收后继续，不会跑偏

**晚上 10:00 — commit 代码**
OpenClaw 深夜读取，生成复盘，为明天准备

---

## 五、硬件配置

### 主力机（已有）
MacBook Pro M4 Max 48GB — 跑 Claude Code，写代码

### 秘书机（待购）
**Mac Mini M4 16GB 256GB — $599**
- 24小时开着，不休眠
- 跑 OpenClaw + ActivityWatch 数据读取
- 物理隔离，主力机安全
- 16GB 够用，不需要买 24GB 版本

**购买：** apple.com，选 Pick up today，今天拿

---

## 六、安全边界

```
# 这些操作必须人工确认，OpenClaw不能自动执行
HUMAN_APPROVAL = [
  "reddit_post",        # 发帖前必须我看
  "git_push_main",      # 主分支push必须我确认
  "api_deployment",     # 部署必须我批准
  "email_send"          # 发邮件必须我审核
]

# CC工作规则（写入每个项目CLAUDE.md）
PLAN_BEFORE_CODE = true         # 动工前先出计划
VIBE_CHECKPOINT = "50 lines"    # 每改50行暂停汇报
MAX_DAILY_API_SPEND = "$5"      # 每日API消费上限
```

---

## 七、实施计划

### ✅ 阶段零：已完成（今天）

- [x] 安装 ActivityWatch — 感知层开始收集数据
- [x] 安装 Claude Cowork — 了解其能力边界
- [x] 明确需求：AI私人秘书，而非普通工具

### 🔄 阶段一：过渡期（现在 → Mac Mini 到货）

用 Claude + Cowork 手动替代，每天：
- 早上：在 Cowork 里问今日建议（读 repo + git commits）
- 晚上：commit 代码，告诉 Claude 今天做了什么

需要做：
- [ ] 每个项目根目录创建 `CLAUDE.md`
- [ ] 在 indie-product-playbook repo 建 `logs/` 文件夹
- [ ] 在 Cowork 设置早上9点定时任务

### ⏳ 阶段二：购买并配置 Mac Mini

- [ ] 购买 Mac Mini M4 16GB $599（apple.com）
- [ ] 安装 OpenClaw
- [ ] 配置 Telegram Bot 集成
- [ ] 把 ActivityWatch 数据接入 OpenClaw
- [ ] 配置 Heartbeat 晨报（每天8:30）

### ⏳ 阶段三：自定义 Skill（Mac Mini 到货后1-2天）

用 CC 来 vibe code 这个系统本身：
- [ ] 写 Perception Script（读 ActivityWatch API + git log）
- [ ] 写 Morning Brief 生成逻辑
- [ ] 写 Evening Retrospective 逻辑
- [ ] 配置 dependencies.md（项目依赖关系）
- [ ] 测试完整闭环

### ⏳ 阶段四：进化期（跑满一个月后）

- [ ] 分析 ActivityWatch 数据，找出你效率最高的时间段
- [ ] 调整晨报建议的粒度和节奏
- [ ] 根据哪些任务你容易拖，自动加强提醒

---

## 八、CLAUDE.md 模板

每个项目根目录放一个：

```markdown
# [项目名称]

## 项目描述
[一句话]

## 技术栈
- Frontend: 
- Backend: 
- Database: 
- Deployment: 

## 项目依赖
- 我依赖：
- 依赖我的：

## 工作规则
1. 开始前先列执行计划，等我说ok再动手
2. 每完成一个主要步骤，停下来汇报
3. 不确定直接问，不要猜
4. 不要修改我没提到的文件
5. 每次改动超过50行，主动暂停汇报

## 当前状态
- 阶段：
- 上次进展：
- 已知问题：

## 今日任务
[每天早上更新]
```

---

## 九、预期收益

| 指标 | 现在 | 目标 |
|------|------|------|
| 每日有效推进项目数 | 1个 | 3个 |
| 每天规划时间 | 30分钟 | 0（看晨报） |
| CC跑偏发现延迟 | 几小时 | 每50行汇报 |
| 手动状态同步 | 每天30-60分钟 | 0 |
| AI对你的了解程度 | 零 | 随数据积累持续提升 |

---

## 十、今天立刻做的事

1. **去 apple.com 买 Mac Mini M4 16GB $599，选 Pick up today**
2. ActivityWatch 继续在后台跑，积累数据
3. 每个项目创建 CLAUDE.md

---

*v2.0 更新：加入 ActivityWatch 感知层、Claude Cowork 评估、秘书系统完整架构*
*下次更新：Mac Mini 到货配置完成后*
