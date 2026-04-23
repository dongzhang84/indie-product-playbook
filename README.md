# Indie Product Development Playbook

> 一人公司的产品开发完整指南
>
> Track A (For Human) + Track B (For Agents)，真名公开，粉丝先行

## 📌 当前战略（必读）

**2026-04-21 起战略已重写。** 在动手做任何新产品之前先看这两份：

- **[STRATEGY.md](./STRATEGY.md)** — 当期决策、3 个月计划、已拒绝的方向（source of truth）
- **[playbook/13-vibe-strategy.md](./playbook/13-vibe-strategy.md)** — 战略原则方法论（下次迷茫时重读）

历史演进：[strategy-2026-early.md](./strategy-2026-early.md)（已被取代）

## 🚫 我们不再做的事

从 2026-04-21 起明确拒绝：

- ❌ Niche / vertical B2B SaaS（过去 5 周失败的共同模式，无自用、无人脉、冷启动不可行）
- ❌ 不自用的产品（违反 Track A self-use 原则）
- ❌ 跳过 Track A 直接做 "shovel 公司"
- ❌ 用长期 vision（"做大公司"）指导当周行动
- ❌ 互推群 / 买粉（低质量粉丝没有真实转化）
- ❌ 在 ship 第一个产品前同时规划多个产品

## 🆕 新建项目（standardized flow）

要建新项目？**跟 Claude 说"按新项目流程走，项目叫 XXX"** 就行。

或者手动 4 步：

1. Claude 写 `ideas/<id>.md`（产品说明）— 参考 `ideas/vibe-reading.md` 结构
2. Claude 写 `implementation-guides/<id>.md`（技术步骤 v1）— **详见下面"写 implementation-guide 约定"**
3. 跑 `bash stack/new-project.sh <id> "<项目名>"`（自动建 repo + 配 workflow + push）
4. 脚本打印的 URL → 点进去加 `PLAYBOOK_TOKEN` secret（30 秒）

完整流程说明：[`stack/NEW-PROJECT.md`](stack/NEW-PROJECT.md)

### 📝 写 implementation-guide 的 prompt

把下面这段改 `<id>` 和 `<参考项目>` 后直接贴给 Claude：

```
基于 ideas/<id>.md 和 stack/STANDARD.md 写 implementation-guides/<id>.md。
结构参考 implementation-guides/<参考项目>.md。

必须遵守：

1. 标准模块直接引用 STANDARD.md，不复制
   - Scaffold 清理（meta / favicon / 字体变量）→ STANDARD §2.5
   - Auth 三件套 → STANDARD §3
   - Supabase Dashboard + Setup checklist → STANDARD §3.7
   - 数据库 RLS + owner policies → STANDARD §4.1
   - Stripe Credits / Subscription → STANDARD §6
   - Vercel 部署 → STANDARD §5
   每处只列项目偏离（砍哪个 provider / schema 名 / price ID / 等）。

2. 业务逻辑完整写
   - 数据 schema（所有表 + RLS policies + indexes）
   - AI prompts + JSON schema
   - UI flow + 页面组件代码骨架
   - Cron / background jobs 内容

3. 骨架（按顺序）
   - Header: Product / Tagline / Stack / Repo / Last Updated
   - (可选) Golden Rules — 产品独有哲学铁律
   - Phase 0: Scaffold + Supabase + 目录 + env + 类型生成
   - Phase 1: Landing + 壳（按 STANDARD §2.5 做 scaffold 清理；
             metadata / favicon / 字体变量一次改对，不留到后面）
   - Phase 2..N: 按用户流程时间顺序，每 Phase 一个核心功能
   - 常见坑（继承 STANDARD + 项目专属）
   - 环境变量完整清单
   - 新项目 Checklist
   - **Human Work Budget**（文档末尾；按 STANDARD §10.5 模板）

4. Ownership 标注（按 STANDARD §0 约定）
   - 每个 Phase 开头加 "Ownership at a glance" 表，列出本 Phase
     的 🤖/🙋/👥 步骤和时间估算
   - 行文中 🤖（默认）不标；🙋 / 👥 必须显式标
   - 文档末尾的 Human Work Budget 汇总所有 🙋 步骤 + 总人工时间
```

**`<参考项目>` 选哪个：**

| 选 | 当 |
|----|---|
| `vibe-reading` | 产品哲学优先、技术复杂度低、无 Stripe |
| `teachloop` | 标准 SaaS + Stripe |
| `growpilot` | 多角色 / 多集成 / 多 cron |

写完你 review，批了再跑 `bash stack/new-project.sh <id> "<项目名>"`。

---

## 📁 项目结构

```
├── playbook/           # 产品开发方法论
│   ├── 01-find-demand.md
│   ├── 02-reverse-engineer.md
│   ├── 03-development.md
│   ├── 04-launch.md
│   ├── 05-marketing.md
│   ├── 06-metrics.md
│   ├── 07-success.md
│   ├── 08-failure.md
│   ├── 09-indie-resources.md
│   ├── 10-ai-workflow-plan.md  # AI多项目管理系统规划
│   ├── 11-meta-ads-setup.md   # Meta广告账号设置指南
│   ├── 12-domain-setup.md     # 域名购买与DNS配置指南
│   └── indie-roadmap-2026.md   # 2026年独立开发路线图
├── ideas/              # 产品想法库
│   ├── README.md
│   └── *-proposal.md
├── product-evaluation.md
├── weekly-review.md
└── README.md
```

## 📋 Playbook 目录

1. [找需求](playbook/01-find-demand.md) - 如何发现值得做的产品
2. [逆向工程](playbook/02-reverse-engineer.md) - 如何拆解竞品
3. [开发](playbook/03-development.md) - 如何快速开发MVP
4. [上线](playbook/04-launch.md) - 如何部署和发布
5. [推广](playbook/05-marketing.md) - 如何获取第一批用户
6. [数据分析](playbook/06-metrics.md) - 如何追踪关键指标
7. [成功后](playbook/07-success.md) - 产品有起色后怎么办
8. [失败后](playbook/08-failure.md) - 如何快速复盘和继续
9. [参考资料](playbook/09-indie-resources.md) - 参考工具和资源
10. [AI多项目工作流](playbook/10-ai-workflow-plan.md) - OpenClaw + Mac Mini 自动化调度系统
11. [Meta广告设置](playbook/11-meta-ads-setup.md) - Meta Business Manager / Pixel 账号设置与投放指南
12. [域名设置](playbook/12-domain-setup.md) - 域名购买、DNS配置、Vercel绑定全流程
13. [Vibe Strategy](playbook/13-vibe-strategy.md) - **当前战略原则**：Track A/B + 粉丝先行 + 真名原则

> ⚠️ Chapter 01-08 是 2026-03 前写的批量 niche 做法，多数与当前战略**冲突**，留作历史参考。
> 当前执行一律以 **[STRATEGY.md](./STRATEGY.md)** 和 **[Chapter 13](./playbook/13-vibe-strategy.md)** 为准。

## 🚀 当前状态（2026-04-21）

### 活跃项目（Track A）

| 项目 | 状态 | 下一步 |
|------|------|--------|
| **Vibe Reading** | 🔥 **当前唯一 Track A** | 完成 web MVP，自用 + 找 3-5 个朋友试用 |
| **Vibe Writing** | 🟢 自用中（Claude Skill，非 web 产品） | 继续用，暂不公开 ship |
| **Socrates Finds You** | 🟡 维护中 | 自用脚本，暂不主推 |

### 公开活动（Track 0 — 粉丝先行）

| 动作 | 目标 |
|------|------|
| 每日 1 条实质性推文（X 中文 / 即刻） | 3 个月 300-500 真实粉丝 |
| 用真名 + PhD + Amazon AI 身份 | 激活 Amazon / Nanjing / Seattle 中文 tech 网络 |
| 内容主题：vibe coding 实践 + Vibe OS 哲学 + Vibe Reading build-in-public | — |

### 搁置 / 已放弃的项目（不再投入）

移到 `ideas/` 作为历史档案：GrowPilot, TeachLoop, BeProfitly, Doppelgang, LaunchRadar, ProfitPilot 等。
**原因：** 全是 niche B2B，违反 self-use + 0.5 度人脉的 Track A 原则。

> 待办和阶段性 priority 见 [STRATEGY.md §7](./STRATEGY.md)。

---

## 🎯 核心理念（2026-04-21 更新）

**铲子来自挖过的坑，粉丝来自真名写过的内容。**

### 关键原则

- **self-use 是门票**：不自用 + 没 0.5 度人脉的产品不建
- **粉丝先行**：分发不是产品成功的副产品，是前置条件
- **真名 + 真实身份**：PhD + Amazon + 中文 tech 是资产，不是包袱
- **速度 > 完美**：70% 能 ship 就 ship，别等 100%
- **不预设 Track B**：shovel 从 friction log 浮现，不从空想规划
- **命中率 1/10-2/10**：10 个 Track A 产品 1-2 个 land，其他是学费

### 典型周期（Track A 产品）—— **1 周一个，流水线叠**

vibe coding 时代节奏：**构建 1-3 天，初步分发 3-4 天，下一个立刻起**。不要等上一个"验证完"才开下一个——分发是长尾，后台继续。

```
Day 1:   痛点识别 + 产品说明 + 技术步骤 + new-project.sh + vibe coding MVP
Day 2-3: buffer（修 bug + 打磨最小 UX，能自用即可）
Day 4-7: 自用 + 朋友试用 + 发推文讲过程（初步分发窗口）
Day 8+:  **下一个 Track A 立即启动**。上一个的分发、自用、friction 后台继续
Day 7:   上一个产品第一次检查点 — 5 天没自己开 = 杀
```

**公开活动是并行主线，不是附加项**：每日 1 条推文从 Day 1 开始，不等产品 ship 再说。

## 🛠 技术栈

**统一技术栈，不要每个产品换一套：**

- **开发工具**: Claude Code
- **框架**: Next.js + TypeScript + React
- **样式**: Tailwind CSS
- **数据库**: Supabase
- **支付**: Stripe
- **部署**: Vercel
- **分析**: Google Analytics 4

## 📊 成功标准（2026-04-21 重写）

**原则：** 早期不看 MRR，看**反馈回路是否形成**。付费用户是滞后信号，不是前置目标。

### Level 1: 有回路（0-3 月）

- ✅ Vibe Reading MVP 每周自用 ≥ 1 次
- ✅ 3-5 个朋友试用并留反馈
- ✅ friction log ≥ 30 条真实条目
- ✅ 真实粉丝 300-500（来自自然圈层，不是互推买粉）

### Level 2: 分发起步（3-6 月）

- ✅ 某 Track A 产品有 50+ 自然注册（不含朋友内测）
- ✅ 真实粉丝 1000-2000
- ✅ friction log 里至少浮现 1 个 Track B 候选（"这 3 次都手动做过 X"）
- ✅ 至少 1 次陌生人主动问"能不能合作 / 付费"

### Level 3: 商业化拐点（6-9 月）

- ✅ Track B 第一版 ship（可免费）
- ✅ Track A 某产品 MRR $200-1000（付费作为信号，不是目的）
- ✅ 真实粉丝 3000-5000
- ✅ 能点名 3 个"别人主动给你带解决方案"的具体问题

### Level 4: 公司形态（9 月+）

- ✅ Track B 有第一批付费用户（企业 / 团队）
- ✅ 不再是单人项目：有协作者或稳定外包
- ✅ 至少 1 条年化 revenue trajectory（非一次性收入）
- ✅ 战略选择点：专注化 vs 产品矩阵

## 🚫 常见错误

1. ❌ 过度打磨第一个产品
2. ❌ 做太复杂的功能
3. ❌ 花大钱做marketing
4. ❌ 不看数据，凭感觉
5. ❌ 对失败的产品不放手
6. ❌ 盲目做100个产品不复盘

## 📈 时间规划（2026-04-21 重写）

构建很快（1-3 天），慢的是分发 + friction 沉淀。时间尺度上：

### Month 1-3: Track A 流水线化 + 粉丝积累

- **每周 1 个 Track A 启动**（3 天构建 + 4 天初步分发 + 下周又起一个）
- 3 个月末累计 **10-12 个 Track A attempt**，1-2 个 land（1/10-2/10 命中率）
- 每日 1 条推文（真名）— **从 Day 1 开始**，不等产品
- friction log 边做边记
- 粉丝目标 300-500

### Month 3-6: 分发成肌肉记忆 + Track B 候选浮现

- 内容和人脉激活已经是日常
- friction log 里同一类摩擦 ≥ 3 次 → Track B 候选浮现
- 粉丝 1000-2000，开始有陌生人注册 / 提问

### Month 6-9: Track B 第一版 ship + 商业化拐点

- Track B 候选变成第一版 shovel
- Track A 某产品可能出现真实付费（付费是信号不是目的）
- 公司形态开始成形（协作者 / 外包）

**完整里程碑见 [STRATEGY.md §8](./STRATEGY.md)。**

## 🔗 模板

- [产品评估模板](product-evaluation.md)
- [周复盘模板](weekly-review.md)
- [产品想法库](ideas/README.md)
- [2026年独立开发路线图](playbook/indie-roadmap-2026.md)（含 Build in Public / X.com 策略）

## 📝 使用方法

1. **按顺序阅读** playbook/ 目录下的01-08章节
2. **执行时参考** 具体章节的checklist
3. **定期更新** 根据实际经验修改playbook
4. **复盘时使用** templates记录learnings
5. **记录想法** 在 ideas/ 目录下创建proposal

## ⚠️ 关于本仓库

本仓库从 2026-04-20 起公开（open source）。包含真实项目记录、失败复盘、策略反思——这是有意为之的 build-in-public 姿态，和 Track 0（粉丝先行）主线一致。

以下内容**不**放在这里：
- 环境变量 / API key（在各自项目的 `.env.local`，已 gitignore）
- 财务明细（如果将来有）
- 未公开的个人联系人 / 公司机密

---

Last Updated: 2026-04-21
Version: 2.0（战略重写）
