# Dong Zhang — AI 多项目管理系统规划文档

**版本：** v1.0  
**日期：** 2026-03-23  
**状态：** 执行中

---

## 一、核心需求

### 1.1 我是谁，我在做什么

同时推进多个 vibe coding 项目的独立开发者，项目包括：

| 项目 | 状态 | 描述 |
|------|------|------|
| **LaunchRadar** | 开发中 | 市场需求分析工具 |
| **AceRocket** | 开发中 | AI 数学/STEM 教育平台 |
| **SAT/AP** | 开发中 | 考试辅导工具 |
| **ProfitPilot** | 开发中 | 盈利分析工具 |
| **Socrates Finds You** | 开发中 | 自动获客pipeline |

### 1.2 我的核心痛点

1. **我是人肉中间层** — 在 Claude Console 和 CC Terminal 之间手动传话，每个任务需要我自己生成 prompt 再粘贴给 CC
2. **单线程切换成本高** — 每天只能有效推进 1 个项目，3-5 个项目完全来不及
3. **没有全局视野** — 不知道每个项目今天该做什么、优先级是什么
4. **没有自动复盘** — 需要手动同步各项目进度，没有"昨天做了什么"的自动记录
5. **CC 失控风险** — 担心 AI 跑偏了才发现，浪费大量时间

### 1.3 我真正需要的系统

一个 **AI 幕僚长系统**，具备以下能力：

- ✅ **自动感知进度** — 不需要我手动汇报，AI 自己读 git commits、文件变化、报错日志
- ✅ **每日主动建议** — 早上起来告诉我今天该做什么、顺序怎么排、哪些可以并行
- ✅ **根据完成情况进化** — 昨天卡在哪里，第二天建议自动调整
- ✅ **跨项目调度** — 同时管理 5 个项目，感知项目间依赖关系
- ✅ **我只做决策** — 高价值判断留给我，执行和感知交给 AI
- ✅ **安全** — 不能破坏主力机系统

---

## 二、现有工具评估

### 2.1 市面上现成工具的局限

| 工具 | 能做到 | 做不到 |
|------|--------|--------|
| Motion / Reclaim | 日历调度、任务排期 | 读代码进度、感知 CC 状态 |
| Linear / Notion AI | 项目管理 | 自动感知，需手动更新 |
| Windsurf / Cursor | 写代码更顺 | 跨项目调度、每日主动建议 |
| GitHub Copilot | 代码补全 | 跨项目调度 |

**结论：没有任何现成产品能完整满足需求。**

### 2.2 最接近需求的方案：OpenClaw

**OpenClaw** 是 2026 年最火的开源本地 AI Agent，100,000+ GitHub stars。

核心能力：
- 本地运行，读取文件系统、git commits、终端日志
- Heartbeat 机制：每 30 分钟自动执行任务，不需要你触发
- 通过 WhatsApp/Telegram 主动推送给你
- Skill 系统：可以自定义自动化逻辑
- 支持 Claude API 作为大脑

---

## 三、系统架构设计

### 3.1 整体架构

```
Mac Mini（24小时运行）
└── OpenClaw（调度中枢）
    ├── 感知层：读 git commits、文件变化、报错日志
    ├── 调度层：分析进度、生成今日建议
    ├── 通知层：WhatsApp 推送晨报和预警
    └── 记忆层：记录每日完成情况，供明天参考

MacBook Pro M4 Max（主力机）
└── Claude Code（执行层）
    ├── LaunchRadar
    ├── AceRocket
    ├── SAT/AP
    ├── ProfitPilot
    └── Socrates
```

### 3.2 每日标准流程

**早上 09:00 — 收到 OpenClaw 晨报（WhatsApp）**
```
"Dong，今日简报：
- 昨天 AceRocket 有 2 个未修复报错
- LaunchRadar 发现 3 条高价值 Shopify 需求
- 今日建议：先修 AceRocket bug（30min），再推进 LaunchRadar
- Socrates 昨晚生成了 10 条 Reddit 回复草稿，待你审核"
```

**09:15 — 启动并行执行**
- CC 窗口 1：LaunchRadar 任务
- CC 窗口 2：AceRocket 任务
- 你：审核 Socrates 草稿，选择发布

**18:00 — OpenClaw 自动生成复盘**
```
status_report.md 自动更新：
- 今日新增代码量
- 完成了哪些功能
- 哪些任务被取消或推迟
- 明日建议的调整方向
```

### 3.3 项目依赖关系（需配置）

```markdown
# dependencies.md
- Shopify Analysis 依赖 LaunchRadar 发现需求才启动
- ProfitPilot 独立运行
- SAT/AP 独立运行
- AceRocket 独立运行
- Socrates 每日独立扫描
```

### 3.4 安全边界（Guardrails）

```
PLAN_BEFORE_CODE = true          # 动工前必须出计划
HUMAN_APPROVAL = [               # 这些操作必须人工确认
  "reddit_post",
  "git_push_main", 
  "api_deployment",
  "email_send"
]
VIBE_CHECKPOINT = "50 lines"     # 每改动50行暂停汇报
MAX_DAILY_API_SPEND = "$5"       # 每日 API 消费上限
```

---

## 四、硬件决策

### 4.1 为什么需要 Mac Mini

| 需求 | MacBook（合盖休眠） | Mac Mini（24h运行） |
|------|-------------------|-------------------|
| 半夜跑 Socrates 扫描 | ❌ | ✅ |
| 早上起来晨报已准备好 | ❌ | ✅ |
| 不占用主力机资源 | ❌ | ✅ |
| 主力机安全隔离 | ❌ | ✅ |

### 4.2 推荐配置

**Mac Mini M4 / 16GB / 256GB — $599**

- 16GB 内存足够（OpenClaw 是轻量调度工具，不跑本地 LLM）
- 256GB 存储足够（代码库不大）
- 不需要买 $799 的 24GB 版本

**购买渠道：**
- Best Buy open-box：$580.99（目前缺货，点 Notify Me）
- apple.com 新机：$599（随时有货）

---

## 五、实施计划

### 阶段一：现在立刻开始（今天，免费）

**用 Claude 手动替代 OpenClaw 的调度功能**

每天早上：把昨天的 GitHub commit 记录 + 今天计划发给 Claude，Claude 给出今日执行建议

每天晚上：告诉 Claude 完成了什么、卡在哪里

这是零成本、今天就能用的过渡方案。

**需要做：**
- [ ] 把所有项目推到 GitHub private repo
- [ ] 每个项目根目录创建 `CLAUDE.md`（项目说明 + 工作规则）
- [ ] 发 GitHub repo 链接给 Claude，开始第一次调度

### 阶段二：买 Mac Mini（等到货）

- [ ] 购买 Mac Mini M4 16GB（Best Buy Notify Me 或 apple.com）
- [ ] 安装 OpenClaw
- [ ] 配置 WhatsApp/Telegram 集成
- [ ] 配置 Heartbeat 晨报

### 阶段三：自定义 Skill（Mac Mini 到货后 1-2 天）

用 CC 来 vibe code 这个 skill 本身：

- [ ] 写 Perception Script（读 git log + 文件变化 + 报错日志）
- [ ] 写 Morning Brief 生成逻辑
- [ ] 写 Evening Retrospective 逻辑
- [ ] 配置 dependencies.md（项目依赖关系）
- [ ] 测试完整闭环

### 阶段四：稳定运行

- [ ] 根据第一周使用反馈调整 Heartbeat 频率
- [ ] 根据实际 API 消费调整 Daily Budget
- [ ] 持续优化各项目的 CLAUDE.md

---

## 六、CLAUDE.md 模板

每个项目根目录放一个，内容如下：

```markdown
# [项目名称]

## 项目描述
[一句话描述这个项目是什么]

## 技术栈
- Frontend: 
- Backend: 
- Database: 
- Deployment: 

## 项目依赖
- 依赖哪个项目的结果：
- 哪个项目依赖我：

## 工作规则
1. 开始任务前，先列出执行计划，等我说"ok"再动手
2. 每完成一个主要步骤，停下来汇报
3. 不确定的地方直接问，不要猜
4. 不要修改我没提到的文件
5. 每次改动超过50行，主动暂停汇报

## 当前状态
- 阶段：[刚开始 / 开发中 / 测试中 / 接近上线]
- 上次进展：
- 已知问题：

## 今日任务
[每天早上更新这里]
```

---

## 七、预期收益

| 指标 | 现在 | 目标 |
|------|------|------|
| 每日有效推进项目数 | 1个 | 3个 |
| 手动状态同步时间 | 每天30-60分钟 | 0 |
| CC 失控被发现的延迟 | 几小时 | 实时预警 |
| 早上规划时间 | 30分钟 | 5分钟（看晨报） |

---

## 八、今天的第一步

**现在就做（10分钟）：**

1. 把你的 GitHub repo 链接发给 Claude
2. 告诉 Claude 今天 5 个项目各自的状态
3. Claude 给你今天的执行计划

不需要等 Mac Mini，不需要装任何软件，今天就能开始。

---

*文档由 Claude + Gemini 协作整理*  
*下次更新：Mac Mini 到货后*
