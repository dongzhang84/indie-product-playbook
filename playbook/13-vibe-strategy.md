# 13. Vibe Strategy — 产品双轨 + 粉丝先行 + 真名原则

> 这是 2026-04-21 后的当前战略原则篇。具体当期决策见根目录 [STRATEGY.md](../STRATEGY.md)，本篇写的是**为什么这样做**的方法论，适合下次迷茫时重读。
>
> 本篇 supersedes 了 [01-find-demand.md](./01-find-demand.md) 里"批量找 niche B2B"的思路——那种思路在无粉丝、无目标市场人脉、无自用时**结构性不可能成功**，本篇解释为什么。

---

## § 1. 两轨框架（For Human + For Agents）

灵感源于 Guo Yu / @turingou 的 13 产品矩阵。核心结构：

### Track A — For Human（个人实验田）

- 每个产品**必须**来自我亲身遇到的痛点（self-use 原则）
- 1-2 周 MVP，vibe coding 节奏
- **预期大多数不会爆**——这是正常结果，不是失败
- 真正的意义：每个 For Human 产品是下一轨的**原料**

### Track B — For Agents（真正的商业资产）

- 从做 For Human 的过程中真实遇到的摩擦中**提取**出来
- **不预先规划**——让它自然浮现
- 目标市场：认知增强类 AI 产品的基础设施
- 这一层才可能长成真正的公司

### 铁律

> **绝不在没有 Track A 经验的情况下直接跳 Track B。**
>
> 铲子必须来自真正挖过坑。没挖过坑的人卖的铲子，长得像铲子但不是铲子。

---

## § 2. Track A 纪律

### 原则 1：self-use 是门票

建一个产品之前，问两件事：
1. **我会每天/每周用它吗？**
2. **我的 0.5 度人脉里有至少 1 个会试用吗？**（Amazon 同事、Nanjing 校友、Seattle 中文 tech 圈）

**两条都不满足 → 不建。** 跑 `stack/new-project.sh` 之前自问这两个问题。

### 原则 2：不要提前规划下一个

写完 Vibe Reading 之前，不决定下一个 For Human 是什么。下一个会从两处浮现：

- 用 Vibe Reading 过程中遇到的新痛点
- friction log 里观察到的模式

**"规划"和"浮现"是两种完全不同的产品来源**。前者是假设，后者是证据。

### 原则 3：Pivot rule（何时杀掉一个 Track A 产品）

Track A 产品的存在前提是**我自用**。明确的杀产品触发器：

- **5 天没打开** → 要么修 self-use 问题，要么杀
- **朋友试用 2 周后没人自发继续用** → 杀，或者重新定义到底为谁做

Track A 是学习材料，不是感情承载物。留恋某一个 Track A 产品是在违反框架。

### 原则 4：命中率预期

vibe coding 时代的 Track A 命中率：**1/10 到 2/10**。
- 10 个产品里 1-2 个 land
- 剩下 8-9 个都是交学费（学费里包含：自己的摩擦 + Track B 的 hint）
- **不要在任何单个 Track A 产品上 all-in**

---

## § 3. Track B 纪律

### 原则 1：不预设

不要在做 Track A 之前写"我要做 5 个 shovel 产品"的列表。列表里的东西大概率都是假设出来的需求。

### 原则 2：从 friction log 浮现

维护两类日志：

| 类型 | 记什么 |
|------|--------|
| User-side | 我自己/朋友用 Track A 产品时**困惑、卡住、放弃**的地方 |
| Developer-side | 做 Track A 过程中**手动做了 3+ 次**的事、AI 失败的地方、重复造的轮子 |

每条目 4 列：日期 / 发生了什么 / 哪个产品 / 这能不能抽成 shovel？

**Track B 候选 = friction log 里出现 ≥ 3 次的模式**。不到 3 次不算信号。

### 原则 3：Track B 成熟度信号

Track B 可以开始做的信号（**全部满足**，不是满足一条就动手）：
- 同一类摩擦在 friction log 里出现 ≥ 3 次
- 我自己有 2+ 个项目已经手动解决过这个摩擦
- 我能说出具体哪 2-3 个外部 developer 会用（不是"一般 indie dev"）

---

## § 4. 粉丝先行排序

### 为什么粉丝是前置条件

Guo Yu 能 ship 13 个产品、每个都拿到真实用户反馈——因为 167k 粉丝。
我 0 粉丝 → 每个失败产品都是**孤立失败**，没有学习信号。

**没样本量 = 没学习。** ship 再快，反馈不进来，下一个还是盲人摸象。

### 粉丝不是结果，是基础设施

把粉丝积累从"产品成功的副产品"重新定义成"产品成功的前置条件"。每日写作不是 optional side quest，是关键路径上的第一个节点。

### 目标阶梯（见 root [README.md](../README.md) Level 1-4）

- Level 1（0-3 月）：300-500 自然圈层粉丝
- Level 2（3-6 月）：1000-2000 粉丝，开始吸引陌生人
- Level 3（6-12 月）：3000-5000 粉丝，陌生人主动带解决方案

### 冷启动是骗局

每个成功 indie 背后都有网络优势：
- Guo Yu：字节校友 + 在日中文圈 + 6 年内容沉淀
- Yu Bo / YouMind：阿里校友 + 中文 tech KOL
- 其他案例：付费 Discord growth 社群

**我的未激活网络：** Amazon AI 同事 / Nanjing 天体校友 / PhD cohort / Seattle 中文 tech。至少激活 1 个。

---

## § 5. 真名原则

我现有的 unique asset：**PhD（Nanjing 天体）+ Amazon AI 应用科学家 + 中文技术社区受众**。

这三条组合在中文 AI indie 圈里几乎独一无二。用化名 = 扔掉这个 asset。

**原则：** 所有公开活动用真名 + 真实背景。X 账号用真实 identity。内容引用真实经历（Amazon 工作场景、PhD 科研训练、vibe coding 实践）。

---

## § 6. 速度 > 完美

传统创业："一个产品 all-in 五年。"
vibe coding 时代："ship 20 个，留下 land 的 2 个。"

- 70% 质量能 ship 就 ship，别等 100%
- 过度规划是过去 5 周失败的根因之一
- 不要 Claude 帮我"优化到完美"，要 Claude 帮我"卡 70% 质量立即推出去"

---

## § 7. Claude 的执行守则

建 Vibe 系列产品时，Claude 应该：

1. **守哲学** — 每个 AI 输出必须服务于"compression-check"（校对理解），不是"compression-replacement"（替我理解）。我会 flag 违反。
2. **提醒记 friction log** — 特别是需要手动 workaround 的地方。
3. **不要让我 scope creep** — 功能偏离"AI 作为错误检查者"时，推回来。
4. **推着我 ship** — 70% 能推就推，不要陪我打磨到 100%。
5. **浮现 shovel 候选** — "这种工具我们已经写过 3 次了"—— 立刻 flag，那可能是 Track B 提取点。

---

## § 8. 指向

- 当前期决策和指标：[STRATEGY.md](../STRATEGY.md)
- 历史演进参考：[strategy-2026-early.md](../strategy-2026-early.md)
- 新项目落地流程：[stack/NEW-PROJECT.md](../stack/NEW-PROJECT.md)
- 代码层标准：[stack/STANDARD.md](../stack/STANDARD.md)

---

**本篇下次重读时机：** 当我又开始考虑一个 niche B2B SaaS / 想做个"shovel 公司"跳过 Track A / 觉得该快一点多 ship 时。
