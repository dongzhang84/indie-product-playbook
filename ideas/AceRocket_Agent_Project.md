# AceRocket "Snap & Practice" — Upload-Driven Tutoring Agent

> 周末冲刺项目。目标有两个：
> 1. 给 AceRocket 加一个真有用的功能（拍照/上传题 → 自动诊断 → 生成针对性练习）。
> 2. 让你拥有一个**真做过的、能端到端讲清楚的 AI Agent 项目**，面试直接用。

---

## 一句话产品

学生**上传一张作业照片 / 一份练习卷 PDF / 一道做错的题**，系统用一个 **multi-agent 工作流**：抽取题目 → 求解并用代码验证 → 诊断薄弱知识点 → 生成针对性练习题，自动加进他的个性化练习集。

---

## 为什么这个项目对面试"值钱"

它把面试官问 AI Agent 时想听的每个能力都**真实覆盖**了：

| Agent 能力 | 这个项目里的体现 |
|---|---|
| **Planning / 编排** | LangGraph 状态机协调 4 个 agent，有分支和重试 |
| **Tool use / function calling** | 视觉 OCR、代码执行(sympy)、向量检索都是工具 |
| **Self-correction / 自验证** | 解题答案用 Python/sympy 验证，不信 LLM 的算术；抽取低置信度就重试 |
| **RAG grounding** | 分类和出题都用课程标准 + 1500 题库做检索 grounding |
| **Multi-agent** | Extractor / Solver / Diagnostician / Generator 各司其职 |
| **Human-in-the-loop** | 抽取不确定时让用户确认 |
| **Evaluation** | 有一个小 eval harness 量化抽取准确率和解题正确率 |

> 面试时你就能说："我搭了一个多 agent 的辅导系统，用 LangGraph 编排，工具包括视觉抽取、sympy 代码验证和 RAG 检索，关键是每步都有自校验——解题答案我用代码验证而不是信模型。"

---

## 用户流程（End-to-End）

```
上传图片/PDF
   ↓
[1] Extractor Agent  ── 视觉/OCR 工具 → 把每道题抽成结构化 LaTeX
   ↓  (自检：重渲染确认解析对；低置信 → 问用户)
[2] Solver Agent     ── LLM 解题 + sympy 代码工具验证数值/符号答案
   ↓  (自校验：答案和代码不一致 → 重解)
[3] Diagnostician    ── RAG 检索课程 taxonomy + 题库 → 标注 topic/subtopic + 判断薄弱点
   ↓
[4] Generator Agent  ── 针对薄弱点生成 N 道相似题（RAG grounding）
   ↓  (复用你已有的 generate→solve→verify 验证闭环)
输出：个性化练习集 + 一段诊断小结，写回学生账户
```

---

## Agent 架构（4 个 agent + 1 个 orchestrator）

- **Orchestrator（LangGraph）**：状态机，管流程、重试、human-in-the-loop 检查点。
- **Extractor Agent**：输入图片/PDF，工具 = 视觉模型（Claude / GPT vision）。输出结构化题目（LaTeX）。自检：把 LaTeX 重渲染，低置信度标记。
- **Solver Agent**：解题。**工具 = Python + sympy 代码执行**，用来独立验证答案（这是关键的 self-correction，别让 LLM 自己算）。
- **Diagnostician Agent**：工具 = 向量检索（题库 + 课程 taxonomy 的 embedding）。输出：每题的 topic/subtopic + 学生薄弱概念。
- **Generator Agent**：针对薄弱点出题，RAG grounding，复用你现有的验证 pipeline。

---

## 技术栈（贴你现有的 + 周末能落地）

- **前端**：Next.js / TypeScript（AceRocket 现成）+ 上传到 **Firebase Storage**
- **编排**：**LangGraph**（Python）—— 面试关键词，一定要用这个
- **LLM**：Claude（Anthropic）+ vision；tool / function calling
- **视觉抽取**：Claude vision 或 GPT-4o vision，输出 LaTeX
- **验证工具**：Python + **sympy** 做符号/数值验证（代码执行）
- **RAG**：现有 1500 题库 + 课程 taxonomy 存进向量库（Chroma / FAISS，或 Firestore + embeddings）
- **后端**：一个小 FastAPI 或 Firebase Functions 跑 LangGraph
- **Eval**：小 harness —— 抽取准确率（人工抽查一批）+ 解题正确率（sympy 对照）

---

## 周末冲刺范围（务实，别贪）

**Day 1 — 打通主干（单题走通）**
- [ ] 上传 → Firebase Storage
- [ ] Extractor：一张图 → LaTeX（vision）
- [ ] Solver：解一道题 + sympy 验证答案
- [ ] LangGraph 骨架把这两步串起来（含一次重试逻辑）

**Day 2 — 补齐 agent + 出练习 + 量化**
- [ ] Diagnostician：RAG 检索 taxonomy，标 topic + 薄弱点
- [ ] Generator：针对薄弱点出 3 道相似题，过验证闭环
- [ ] 简单 UI：显示诊断小结 + 生成的练习集
- [ ] Eval：跑 10–20 张样本，记录抽取准确率 / 解题正确率两个数字（**面试要能报数字**）

> 范围守则：**先只做数学、只做"上传单张图"**。多页 PDF、多学科、多 agent 并行都是 Day 2 有余力再说。能跑通 + 有两个 eval 数字，就足够撑起一个面试故事。

---

## 面试话术（做完后你能说的）

- "I built a multi-agent tutoring system where a student uploads a photo of a problem, and a LangGraph-orchestrated pipeline extracts it with vision, solves it with an LLM but **verifies the answer with a sympy code tool**, diagnoses weak concepts via RAG over our curriculum, and generates targeted practice."
- "The design principle I care about most is **self-verification** — I never trust the model's arithmetic; a code-execution tool checks it, and the agent retries when they disagree."
- 报数字："On my eval set, extraction accuracy was X% and verified solution correctness was Y%."（做完填真实数字）

---

## ⚠️ 诚实边界（别过度包装）
- 这是**周末做的原型**，不是跑了半年的生产系统。面试可以说 "I built this as a working prototype to push AceRocket toward agentic workflows" —— 真实、且展示 initiative。
- 规模、并发、生产监控这些没做，被问到就说"原型阶段，但底层 pattern 我端到端做过"。
