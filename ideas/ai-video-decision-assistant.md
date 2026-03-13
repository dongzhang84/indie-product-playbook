# AI Video Decision Assistant

## One-liner
"Stop wasting credits testing 10 AI video models. Get smart recommendations and side-by-side previews before you generate."

## Problem
- AI视频模型爆炸式增长（Sora 2, Veo 3, Kling 2.6, Runway, Luma...）选择困难
- 价格差异巨大（$0.25 vs $3.20/clip），用户不知道哪个性价比高
- 每个模型擅长不同场景（Veo擅长电影感，Kling擅长人像，Minimax擅长速度）
- 用户浪费大量credits试错（一个5秒视频可能要花$5-15测试）
- 现有聚合平台（Loova, Higgsfield）只提供访问，不提供决策支持

## Solution
Web平台：AI驱动的模型推荐 + 并行预览对比

**核心流程**：
1. 用户描述需求："产品广告，可乐瓶，水花特写，预算$5，10分钟内"
2. GPT-4分析场景，推荐最优模型（带理由 + 成本预估）
3. 一键并行生成2-3个模型的低清预览（1秒，总成本$0.3）
4. 用户选最满意的，生成正式5秒高清版

## Target Users
- **独立创作者** - 预算有限，需要性价比最高的选择
- **小型营销团队** - 需要快速决策，批量生产内容
- **内容创业者** - 一人身兼多职，没时间研究每个模型
- **Agency自由职业者** - 客户项目需要控制成本

**用户画像**：
- 已经知道AI视频，但被选择搞晕的人
- 每月生成10-50个视频
- 月预算$50-200
- 重视时间成本和避免浪费

## Core Features (MVP - Week 1-4)

### Week 1: 场景推荐引擎
**目标**：验证推荐逻辑是否有价值
- 用户输入：需求描述 + 参考图（可选）
- GPT-4分析关键词（流体、人像、产品、速度等）
- 显示Top 3推荐模型 + 理由 + 成本对比
- **不做实际生成**（先验证推荐准不准）

**技术**：
- Next.js前端 + OpenAI API
- 简单的规则引擎（关键词→模型映射）

### Week 2: 接入2个API
**目标**：能实际生成视频
- 整合Kling API（质量好但贵）
- 整合Minimax API（便宜快速）
- 用户充值系统（Stripe）
- 单次生成流程

**技术**：
- Kling/Minimax官方API
- Vercel PostgreSQL存储用户credits
- Stripe Checkout

### Week 3: 并行预览对比
**目标**：差异化核心功能
- 一键生成2-3个模型的1秒低清预览
- 并行API调用（30秒内全部返回）
- 对比界面（左右或上下排列）
- 选择后生成正式版

**技术**：
- Promise.all并行调用
- 视频预览组件
- 成本控制（预览用低分辨率）

### Week 4: 成本优化建议
**目标**：增加用户粘性
- 历史生成记录
- 成本分析（"你在Kling上花了$50，用Runway可省$30"）
- 批量生成折扣建议
- 模型性能统计（用户选择率）

## Tech Stack
- **Frontend**: Next.js 14 + TypeScript + Tailwind CSS + Shadcn UI
- **Backend**: Next.js API Routes (Serverless)
- **Database**: Vercel Postgres（用户、credits、生成历史）
- **Auth**: Clerk或NextAuth
- **Payment**: Stripe
- **AI APIs**: 
  - OpenAI GPT-4（推荐引擎）
  - Kling API（高质量生成）
  - Minimax API（快速低成本）
  - Runway API（可选，Week 5+）
- **Video Storage**: Cloudflare R2或Vercel Blob
- **Deploy**: Vercel

## Pricing

### Freemium模式
- **Free Tier**: 
  - 3次推荐（测试推荐准确度）
  - 1次并行预览（体验核心功能）
  - 看到成本对比但不能生成

- **Starter ($15/月)**:
  - 无限推荐
  - $10 credits included（约生成5-10个视频）
  - 并行预览（每月20次）
  - 成本分析报告

- **Pro ($40/月)**:
  - 无限推荐 + 预览
  - $30 credits included（约生成20-30个视频）
  - 批量生成折扣
  - API直连（高级用户自己的API key）
  - 优先队列（生成更快）

### Credit充值
- $10 = 10 credits
- $50 = 55 credits（10% bonus）
- $100 = 120 credits（20% bonus）

**成本结构**：
- Kling生成5秒 = 2.5 credits = $2.5
- Minimax生成5秒 = 0.5 credits = $0.5
- 预览（3个模型x1秒）= 0.3 credits = $0.3
- GPT-4推荐 = 0.02 credits = $0.02

**毛利**：
- API成本：~60%
- 平台费：~40%（包含推荐服务价值）

## Differentiation

| Feature | 我们 | Loova | Higgsfield | 直接用API |
|---------|------|-------|------------|-----------|
| 智能推荐 | ✅ | ❌ | ❌ | ❌ |
| 并行预览 | ✅ | ❌ | ❌ | ❌ |
| 成本优化 | ✅ | ❌ | ❌ | ❌ |
| 统一账户 | ✅ | ✅ | ✅ | ❌ |
| 多模型访问 | ✅ (2-3个) | ✅ (10+) | ✅ (5+) | ❌ |
| 复杂编辑 | ❌ | ✅ | ✅ | ❌ |
| 价格 | $15起 | $20-30 | $50+ | Free但复杂 |

**核心优势**：
- **唯一的"决策优先"平台** - 不是给你所有选择，而是告诉你该选什么
- **省钱神器** - 通过推荐和预览，避免浪费credits
- **专注痛点** - 不做大而全，只解决"选择困难"

## Why This Works
✅ **真实痛点** - 行业报告明确指出"decision making is the bottleneck"
✅ **市场空白** - Loova等聚合器只做访问，没人做推荐
✅ **时机完美** - 2026年初，聚合器刚爆发，用户刚开始感到痛苦
✅ **技术可行** - 不需要训练模型，调用现有API即可
✅ **快速验证** - Week 1只做推荐，先验证需求再投入开发成本
✅ **明确用户** - 独立创作者、小团队（愿意为省钱工具付费）
✅ **可防御性** - 核心是推荐算法和用户数据，不易被抄

## Success Metrics

**Week 1（推荐引擎）:**
- 100+ landing page访问
- 20+ 试用推荐功能
- 5+ 用户反馈推荐准确
- 1+ 用户预充值

**Week 4（完整MVP）:**
- 200+ signups
- 50+ 生成过至少1个视频
- 10+ paid users ($150-400 MRR)
- 推荐准确率 >70%（用户实际选择 vs 推荐）

**Month 3（决定继续/放弃）:**
- 500+ total users
- 100+ paid users ($1,500-4,000 MRR)
- Churn <30%
- NPS >40
- 单用户月均生成 >5个视频

## Competition

### 直接竞争
**无** - 目前没有"AI视频决策助手"

### 间接竞争
1. **聚合平台（Loova, Higgsfield）**
   - 优势：功能全面，模型多
   - 劣势：不解决选择困难，价格贵
   - 我们的应对：专注推荐，价格便宜15-30%

2. **比较文章/博客**
   - 优势：免费，信息详细
   - 劣势：静态，主观，不可操作
   - 我们的应对：实时推荐，可直接生成

3. **直接用单一模型**
   - 优势：熟悉，可能有订阅
   - 劣势：不知道是否最优，浪费钱
   - 我们的应对：展示成本对比，证明省钱

### 潜在竞争（6个月后）
- Loova可能加推荐功能
- **护城河**：我们的数据（哪些场景用户选了哪个模型）+ 先发优势

## Phase 2 (如果成功 - Month 4+)

### 功能扩展
- 🎯 **更多模型**：Runway, Pika, Luma（达到5-7个）
- 🧠 **AI学习**：基于用户选择优化推荐
- 📊 **高级分析**：哪些模型对你的风格最好
- ⚡ **Prompt优化**：自动翻译用户需求为各模型最优prompt
- 🔔 **降价提醒**：模型降价时通知用户
- 👥 **团队版**：共享credits，统一计费

### 商业模式扩展
- **API for Agencies**：批量价格，白标
- **模型方合作**：推荐返佣（类似联盟营销）
- **数据报告**：卖给模型公司（哪些场景他们弱）

## Risk

### 技术风险
⚠️ **API成本失控**
- 问题：预览功能可能导致API调用量暴增
- 解决：严格限制预览（免费1次，付费20次/月），用低分辨率

⚠️ **API不稳定**
- 问题：Kling/Minimax API可能down或限速
- 解决：多模型冗余，显示"该模型暂时不可用"

⚠️ **视频存储成本**
- 问题：大量视频可能导致存储费用高
- 解决：预览视频只保存24小时，正式版用户自行下载

### 市场风险
⚠️ **用户不愿付费**
- 问题：觉得直接用免费聚合器就够了
- 解决：Free tier验证，强调省钱（"本月为你节省$XX"）

⚠️ **市场太小**
- 问题：只有专业创作者需要，用户基数小
- 解决：100用户 x $15 = $1,500/月就可接受

⚠️ **Loova抄袭**
- 问题：他们看到后6个月内加推荐功能
- 解决：速度为王，6个月内做到500+ users，形成数据护城河

### 合规风险
⚠️ **API ToS违规**
- 问题：模型API可能禁止"对比"或"中间商"
- 解决：仔细阅读ToS，必要时直接联系商务

## Timeline

### Week 1: 推荐引擎MVP
- **Day 1-2**: Landing page + 需求输入表单
- **Day 3-4**: GPT-4推荐逻辑 + 规则引擎
- **Day 5**: 测试（用10个真实场景验证推荐）
- **Day 6-7**: 发布到Reddit/Twitter，收集反馈

### Week 2: 实际生成
- **Day 1-2**: 接入Kling API
- **Day 3-4**: 接入Minimax API
- **Day 5**: Stripe充值系统
- **Day 6-7**: 端到端测试（推荐→充值→生成）

### Week 3: 并行预览
- **Day 1-3**: 并行预览功能
- **Day 4-5**: 对比UI优化
- **Day 6-7**: Beta测试（邀请20个用户）

### Week 4: 优化 + 推广
- **Day 1-2**: 成本分析功能
- **Day 3-4**: Bug修复 + 性能优化
- **Day 5**: Product Hunt launch
- **Day 6-7**: 数据分析 + 用户访谈

### Month 2-3: 迭代
- 根据数据优化推荐算法
- 加更多模型（如果需求验证）
- 社区建设（Discord/Slack）

## Investment

### 时间
- Week 1: 40小时（推荐引擎）
- Week 2: 30小时（API接入）
- Week 3: 35小时（并行预览）
- Week 4: 25小时（优化推广）
- **总计**: ~130小时（可分散到4-6周）

### 金钱
- Vercel Pro: $0（免费tier够用）
- OpenAI API: ~$50（测试 + 前100个用户）
- Kling/Minimax API: ~$100（测试）
- Stripe: $0（按交易抽成）
- 域名: $12/年
- **总计**: ~$162

### 机会成本
- 如果失败：损失1个月时间 + $162
- 如果成功：Month 3达到$1,500 MRR，年收入$18K+

## Why Me / Founder-Market Fit

✅ **我经历过这个痛点**
- 2023年做AI短剧时，在Runway vs Pika之间纠结，浪费了大量credits

✅ **我懂技术**
- 能快速开发和迭代
- 之前做过AI工具（图片/视频生成）

✅ **我懂AI视频市场**
- 关注行业2年+
- 知道各个模型的优劣势

✅ **我是目标用户**
- 独立创作者
- 预算有限
- 需要性价比

✅ **我能快速验证**
- 不追求完美，先出MVP验证
- 敢于放弃（如果数据不好）

## Go/No-Go Decision Points

### Week 1结束
- ✅ GO: 20+ 用户觉得推荐有用
- ❌ NO-GO: <10个用户试用，或推荐被吐槽不准

### Week 4结束
- ✅ GO: 10+ paid users, 推荐准确率>70%
- ❌ NO-GO: <5 paid users, churn >50%

### Month 3结束
- ✅ SCALE: 100+ paid users, $1,500+ MRR, churn <30%
- ⚠️ PIVOT: 50-100 users, 考虑调整定价或功能
- ❌ SHUTDOWN: <50 paid users, 写postmortem并开源代码

---

**Status**: 🚀 MVP Launched
**Created**: 2026-02-06
**Launched**: 2026-02-17
**Priority**: High（市场空白 + 时机完美 + 技术可行）
**APIs Integrated**: Kling, Minimax
**Next Action**: 收集用户反馈，追踪 Week 4 success metrics


## Sprint Summary

_Last updated: 2026-03-13_

Week 6 _(current)_ · 2026-03-09 to 2026-03-15
Status: ⚠️ Slow
Active days: 3 / 7
Total commits: 4

Week 5 · 2026-03-02 to 2026-03-08
Status: ⚠️ Slow
Active days: 3 / 7
Total commits: 16

Week 4 · 2026-02-23 to 2026-03-01
Status: ❌ Stalled
Active days: 1 / 7
Total commits: 3

Week 3 · 2026-02-16 to 2026-02-22
Status: ❌ Stalled
Active days: 0 / 7
Total commits: 0

Week 2 · 2026-02-09 to 2026-02-15
Status: ✅ Good
Active days: 7 / 7
Total commits: 25

Week 1 · 2026-02-02 to 2026-02-08
Status: ❌ Stalled
Active days: 2 / 7
Total commits: 12

## Notes
- 这不是"又一个AI视频生成器"，是"AI视频的导航系统"
- 核心价值：帮用户省钱省时间，不是提供更多选择
- 竞争优势：数据（用户选择记录）+ 推荐算法，不易被抄
- 最坏情况：4周后发现没需求，损失$162 + 1个月，但学到完整产品开发流程
