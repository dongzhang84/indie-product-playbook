# Current Focus

*Last updated: 2026-05-12*
*Owner: @snowboat84*

This document captures what I'm actually working on right now, at what priority, and why. It's a living file — update it whenever priorities shift. For long-term vision, see [STRATEGY.md](./STRATEGY.md). For week-by-week output, see [weekly-logs/](./weekly-logs/).

---

## Priority Stack (as of 2026-05-12)

### P0 — Non-negotiable weekly commitment

**① snowboat-blog：100天100篇原创**

- **What**: 推特/知乎 中文原创内容，科技 + AI + Indie 方向
- **Cadence**: 每周 5 篇，共 20 周（约到 2026-08）
- **Why P0**: 时间窗口固定，断更对账号动能伤害不可逆；这是建立受众的关键期
- **状态**: 已发 ~26 篇，节奏稳定，限流问题在观察中
- **Repo**: [snowboat-blog](../snowboat-blog)

---

### P1 — Core products，需要持续迭代

**② Vibe Reading**

- **What**: 反偷懒的 AI 读书工具——拒绝一键摘要，强制先定义阅读目标，AI 做三色章节映射，费曼复述校验理解
- **URL**: vibe-reading.dev
- **状态**: MVP 上线，已有真实用户（Twitter 发布后 33 人注册），持续修 bug + 扩用户
- **近期重点**: 用户反馈闭环，下一个功能点待定
- **Repo**: [vibe-reading](../vibe-reading)

**③ PhysLit（Physics Elite Research）**

- **What**: 用 LLM 测试物理学归纳推理能力的研究项目——给模型看亚里士多德式现象集（无理论标签），看模型能否归纳出物理定律（Tier 1/2/3 难度分层）
- **状态**: v0.1 预注册已锁定（5/9），准备正式执行（预算 ≤ $50）
- **近期重点**: 跑 v0.1 实验，写结果分析报告
- **Repo**: [physlit](../physlit)

---

### P2 — Aligned，做但不占用 P0/P1 时间

**④ AIfy**

- **What**: 帮助任何流程/产品自动 AI 化，给出具体 suggestion（三层：个人 / 团队 / 行业）
- **状态**: 产品提案 + 实施指南已写入 playbook，尚未动工开发
- **Repo**: [AIfy](../AIfy)（仅文档）

**⑤ 宗教类 AI 监控**

- **What**: 监控宗教领域的 AI 应用动态（市场机会 / 竞品 / 趋势）
- **状态**: 持续观察中，尚未形成产品
- **形式**: 暂时作为 snowboat-blog 选题来源 + 未来潜在产品方向

---

### 暂停 / 待决策

| 产品 | 上次活跃 | 状态 | 待决策 |
|------|----------|------|--------|
| BeProfitly | ~Week 5 | Shopify 路线被否后搁置 | 继续 / 暂停 / 关闭？ |
| GrowPilot | ~Week 4 | 0 commit | 同上 |
| TeachLoop | ~Week 4 | 0 commit | 同上 |
| LaunchRadar | ~Week 2 | 0 commit | 同上 |
| Socrates Finds You | ~Week 3 | 0 commit | 同上 |
| LangChain Agents（学习） | 30+ 天 | 完全停滞 | 设 timebox 或正式放弃 |

---

## 可行性简析（2026-05-12 视角）

### snowboat-blog（100天原创）
**可行性：高。** 已证明能维持每周 5 篇节奏，且有爆款（14K 阅读），账号动能在建立。主要风险是 X 限流和持续选题压力。

### Vibe Reading
**可行性：中高。** 产品哲学清晰，有真实用户，技术债可控。瓶颈是冷启动分发——依赖内容端（snowboat-blog）导流，这条路已验证（Vibe Reading 文章 14K 阅读 → 33 用户）。增长上限取决于能否找到更大的分发渠道。

### PhysLit
**可行性：中。** 作为研究项目，目标不是商业化而是学术/社区认可。风险在于 LLM 归纳能力可能不足以通过严格测试，实验结果不确定。但预算 ≤ $50 的约束让风险可控。价值在于内容：无论结果好坏都是高质量的 snowboat-blog 选题。

### AIfy
**可行性：待验证。** 产品想法合理，但分发和变现路径不清晰。当前优先级下应保持"想清楚再动手"的节奏，不要让它抢占 P1 的时间。

### 宗教类 AI
**可行性：未知，但值得关注。** 该赛道竞争相对少，但用户付费意愿和产品形态都不明确。当前以观察为主是正确选择。

---

## 工作节奏原则

1. **每周 5 篇文章优先于一切**——哪怕 Vibe Reading 有紧急 bug，文章不能断
2. **PhysLit 实验设时间盒**——每次执行 + 分析 ≤ 1 周，结果写成文章
3. **暂停产品不等于放弃**——但必须给每个暂停产品一个明确的"复盘截止日"，不能无限期搁置
4. **BeProfitly 等产品**：在 Week 9（5/9–5/15）给出明确结论，不再拖

---

*下次更新建议：Week 9 结束后（5/15），更新暂停产品决策结果 + PhysLit v0.1 实验结果*
