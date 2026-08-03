# AceRocket "Grounded Tutor" — RAG Q&A over the Question Bank

> 周末冲刺项目 #2（RAG）。和 agent 项目**不重叠**：agent 那个重"多步编排+自校验"，这个专攻**检索本身的功力**（chunking / embedding / hybrid search / reranking / faithfulness 评估）。
> 目标：① 给 AceRocket 加一个"带引用、不瞎编"的答疑功能；② 让你有一个能端到端讲清楚的 **RAG 项目**，面试直接用。

---

## 一句话产品

学生问"这道题怎么做 / 这个概念是什么"，系统从 **1500 题库 + 课程讲解**里检索最相关的内容，**带引用（cite 到具体题目/知识点）**地回答——有依据才答，没依据就说"我没有足够材料"，不瞎编。

---

## 为什么这个项目对面试"值钱"

RAG 面试官必问的每个考点，这里都真实覆盖：

| RAG 考点 | 这个项目里的体现 |
|---|---|
| **Chunking 策略** | 按"概念/题目"切，不是死板固定长度；数学 + LaTeX 要特殊处理 |
| **Embedding 选型** | 选哪个 embedding、为什么；存进向量库 |
| **Hybrid search** | BM25 关键词 + 稠密向量并用（数学有"quadratic formula"这种精确词，纯向量会漏） |
| **Reranking** | 检索完用 cross-encoder / Cohere rerank 提精度 |
| **防幻觉 / grounding** | 只用检索到的内容回答，带 citation；无相关内容就拒答 |
| **Evaluation** | 检索层 recall@k / MRR + 回答层 faithfulness（LM-as-judge） |

> 面试话术：**"我搭了一个 RAG 答疑系统，chunk 按概念切，检索用 hybrid（BM25+向量）再加 reranking，回答强制 grounding 到检索内容并带引用，还建了 eval 量化 recall 和 faithfulness。"**

---

## Pipeline（End-to-End）

```
学生提问
   ↓
[1] Retrieve  ── 关键词(BM25) + 稠密向量(embedding) 双路召回 top-N
   ↓
[2] Rerank    ── cross-encoder / Cohere rerank，把 top-N 精排成 top-k
   ↓
[3] Generate  ── LLM 只基于 top-k 内容回答；带 citation；无依据 → 拒答
   ↓
输出：答案 + 引用来源（哪道题/哪个知识点）
```

---

## 关键技术决策（面试会追问，提前想好）

- **Chunking：** 按"一道题 + 它的解法/涉及概念"为一个 chunk，而不是固定 500 字。数学公式用 LaTeX 保留，别被切碎。
- **Embedding：** 用 OpenAI `text-embedding-3-large` 或开源(BGE/e5)；讲清楚"为什么选它"（成本/效果/是否需自托管）。
- **为什么要 Hybrid：** 纯向量对"quadratic formula""FOIL"这种**精确术语**召回差，BM25 关键词能补上；两路结果融合（RRF）。
- **为什么要 Rerank：** 召回快但糙，cross-encoder 精排能显著提 precision，让 top-3 更干净。
- **防幻觉：** system prompt 强制"只用给你的 context 回答；没有就说不知道"；答案里标引用，方便学生核对。

---

## 技术栈（贴你现有的 + 周末能落地）

- **编排：** LangChain 或 LlamaIndex（RAG 现成组件多）
- **向量库：** Chroma / FAISS（本地）或 pgvector（Firebase 之外）
- **Embedding：** OpenAI text-embedding-3 或 BGE/e5（开源）
- **关键词：** BM25（rank_bm25 或 Elastic/OpenSearch）
- **Rerank：** Cohere Rerank API 或本地 cross-encoder（`ms-marco-MiniLM`）
- **LLM：** Claude / GPT，带 citation 输出
- **Eval：** ragas 或自写（recall@k、MRR、faithfulness = LM-as-judge）
- **前端：** AceRocket 现成的 Next.js 加一个问答框

---

## 周末冲刺范围（务实，别贪）

**Day 1 — 打通朴素 RAG（能带引用回答）**
- [ ] 把 1500 题库 + 讲解 chunk → embed → 存向量库
- [ ] 单路向量检索 top-k → LLM grounded 回答 + 引用
- [ ] 加"无相关内容就拒答"的 guardrail

**Day 2 — 加 hybrid + rerank + 量化**
- [ ] 加 BM25，双路召回 + RRF 融合
- [ ] 加 reranking，对比"加 vs 不加"的效果
- [ ] Eval：标 15–20 个问题，跑出 **recall@k** 和 **faithfulness** 两个数字（面试要能报数字）

> 范围守则：**Day 1 先要一个能跑、带引用的朴素 RAG**；hybrid / rerank / eval 是 Day 2。有两个 eval 数字就够撑一个面试故事。

---

## 面试话术（做完后能说的）

- "I built a RAG tutor over our question bank. Retrieval is **hybrid — BM25 plus dense embeddings with RRF fusion** — because math has exact terms that pure vector search misses. Then a **cross-encoder reranks** to clean up the top-k. Generation is **grounded with citations**, and it refuses when there's no relevant context."
- "I care most about **faithfulness** — I measure it with an LM-as-judge on a labeled set, alongside retrieval recall@k, so I can tell whether a bad answer is a retrieval problem or a generation problem."
- 报数字："recall@5 was X%, faithfulness was Y%."（做完填真实数字）

---

## ⚠️ 诚实边界（别过度包装）
- 周末做的**原型**，语料是 AceRocket 自己的题库，不是百万级企业文档。面试说 "prototype to make AceRocket's answers grounded and citable" —— 真实、显 initiative。
- 大规模、增量索引、生产监控没做；被问到就说"原型阶段，但 chunking/hybrid/rerank/eval 这套底层 pattern 我端到端做过"。
