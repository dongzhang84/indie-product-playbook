# Current Focus

*Last updated: 2026-06-10*
*Owner: @snowboat84*

This document captures what I'm actually working on right now, at what priority, and why. It's a living file — update it whenever priorities shift. For long-term vision, see [STRATEGY.md](./STRATEGY.md). For week-by-week output, see [weekly-logs/](./weekly-logs/). For the May 2026 retrospective, see [weekly-logs/monthly-2026-05.md](./weekly-logs/monthly-2026-05.md).

---

## 当前三件事（as of 2026-06-10）

### ① 百日百篇 — 持续输出

- **是什么**：snowboat-blog 上的 20 周 × 5 篇 = 100 篇原创长文系列
- **进度**：截至 Week 12（6/5），已发 ~#46，约 46%。预计完结在 Week 27 ≈ 2026-08-15
- **为什么是它**：时间窗口固定，断更对账号动能伤害不可逆；这是建立受众的关键期
- **5月已验证的三条主线**：美国系统深度（教育/医疗/移民/法律/税收）、物理视角看AI（PhysLit + #40/#45互文）、数学与科学哲学
- **后半程要警惕**：美国系列已出现边际递减（移民103K → 法律15K → 税收16K），剩下 ~50 篇要给新主线（华人vs犹太人、物理AI、世界模型）更多权重
- **Repo**：[snowboat-blog](../snowboat-blog)

### ② PhysLit 论文 — 把那篇文章写完

- **是什么**：用 LLM 测试物理学归纳推理的研究项目，目前有中文论文初稿 `paper_draft.zh.md`（Week 11 完成），需要写完
- **当前状态**：§1（Introduction）已完成学术规范精修（Week 12，35 commits），§2 待起草，中英双版本 LaTeX 输出准备中
- **三个实验版本闭环已完成**：v0.1（Newton Leak + judge 分歧率）/ v0.2（F=mv 框架）/ v0.3（能量衰减，4/4 predictions confirmed）
- **为什么是它**：研究方法论本身是结果（LLM judge 36.67% 分歧率是对现有 benchmark 的具体质疑），论文是这套方法学术化的载体
- **写完的标准**：§1–§4 + Methods + Discussion 全部完成，中英双版本可发布
- **Repo**：[physlit](../physlit)

### ③ Vibe Reading — 回过头去做

- **是什么**：反偷懒的 AI 读书工具，URL：vibe-reading.dev
- **当前状态**：MVP 已上线（5/4 自定义域名），33 个真实新用户，EPUB 全格式支持完成（Week 9），之后**连续 4 周 0 commit**（Week 10–13）
- **原本的约束**：当时计划是百日百篇期间三周内发布产品；产品已上线，三周 deadline 自动失效
- **现在的状态**：deadline 没了，但活还得做。需要在百日百篇并行的节奏里给 Vibe Reading 留出固定时段
- **下一步明确的事**：(a) 系统化梳理 33 个真实用户的使用反馈，(b) 决定下一个功能点（不是凭感觉，要有数据或反馈支撑），(c) 排出可执行的 sprint 节奏
- **Repo**：[vibe-reading](../vibe-reading)

---

## 暂停 / 待决策（不占当前心智）

- **BeProfitly / GrowPilot / TeachLoop / LaunchRadar / Socrates Finds You**：5 个产品连续 6+ 周 0 commit。百日百篇期间的策略是统一暂停，不做单独决策。计划在百日百篇结束（~2026-08-15）后统一评估关闭/归档/重启
- **AIfy**：MVP scaffold 已完成（Week 9 Phase 0–9），之后未推进。同样推迟到百日百篇结束后再决定

---

## Notes

- 百日百篇是 P0，PhysLit 和 Vibe Reading 在剩余时间里争夺剩余带宽
- 不再设"三周内发布产品"这类硬 deadline，但 Vibe Reading 必须有可见的周节奏，不能再像 5 月那样连续多周 0 commit
- 这三件事的优先级在 100 篇完结后会重新洗牌——届时 PhysLit 论文应该已完成，Vibe Reading 应该已有清晰的用户验证数据
