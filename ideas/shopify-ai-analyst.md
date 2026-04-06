# Shopify AI Analyst - Product Proposal

## One-liner
"10分钟连接Shopify，AI自动告诉你：什么卖得好、为什么不出单、该进多少货"

## Problem
Shopify小卖家的数据困境：
- **Shopify自带分析太基础** - 只能看总销售额，看不出"为什么"
- **Google Analytics太复杂** - 需要懂转化率、跳出率，看不懂报表
- **数据散落各处** - 销售在Shopify、广告在Facebook、库存在另一个系统
- **雇不起数据分析师** - 小卖家年收入$50K-500K，请不起全职分析师（年薪$60K+）
- **现有BI工具太贵太复杂** - Triple Whale $129/月起，功能太多学不会

## Solution
电商专家系统，不是通用BI
- **30个预设问题** - 不需要学SQL，点一下就得到答案
- **只连Shopify** - 不做亚马逊，专注垂直
- **AI自动分析** - 不只展示数据，直接给建议
- **白话解释** - "上周卖得最好的是Product X，因为..."

## Target Users
**Primary: Shopify小卖家**
- 年收入 $50K-500K
- 1-3人团队
- 没有专职数据分析师
- 需要快速决策（进货、广告、定价）

**Secondary:**
- 新手卖家（刚开店，不懂数据）
- 副业卖家（没时间看复杂Dashboard）
- 代运营团队（管理多个客户店铺）

## Core Features (MVP - Week 1)

### 30个预设问题（分5类）

**销售分析 (10个):**
1. 上周卖得最好的3个产品是什么？
2. 哪个产品的利润率最高？
3. 哪些产品销量在下滑？
4. 哪些产品经常被加购物车但不结账？
5. 新客vs老客的比例？
6. 平均客单价是多少？比上月高还是低？
7. 哪个时间段订单最多？
8. 哪些产品经常被一起买？（捆绑销售机会）
9. 退货率最高的产品是什么？
10. 预测下个月销量（基于历史数据）

**广告ROI (7个):**
11. Facebook广告花了多少？带来多少销售？
12. Google Ads的ROI是多少？
13. 哪个广告活动最赚钱？
14. 哪些关键词转化率最高？
15. 广告成本占销售额的百分比？
16. 哪个渠道的客户LTV最高？
17. 要不要增加广告预算？AI建议

**库存优化 (6个):**
18. 哪些产品库存不足，需要补货？
19. 哪些产品卖不动，该清仓了？
20. 按当前销量，库存还能撑几天？
21. 下个月应该进多少货？
22. 哪些产品周转率最快？
23. 库存积压成本是多少？

**客户洞察 (5个):**
24. 复购率是多少？
25. 流失客户有什么特征？
26. 高价值客户的画像？
27. 哪些客户可能要流失了？（预警）
28. 如何提高复购率？AI建议

**运营健康度 (2个):**
29. 我的店铺健康度打分（综合评估）
30. 这周最应该关注的3件事是什么？

### Week 1 MVP Scope
- ✅ Shopify OAuth连接
- ✅ 前10个基础问题（销售分析）
- ✅ 简单Dashboard（卡片式）
- ✅ AI自然语言解释（GPT-4）
- ❌ Google Analytics集成（Week 2+）
- ❌ Facebook Ads集成（Week 2+）
- ❌ 高级预测算法（Phase 2）

## Tech Stack
**Frontend:**
- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS + shadcn/ui

**Backend:**
- Next.js API Routes
- Shopify API (OAuth + GraphQL)

**Database:**
- Supabase (PostgreSQL)

**AI:**
- OpenAI GPT-4 (自然语言生成)

**Payment:**
- Stripe Checkout

**Deploy:**
- Vercel (web app)
- Shopify App Store

## Pricing
```
Free Plan: $0/月
- 只连Shopify
- 10个基础问题
- 每天更新1次

Starter: $29/月 ⭐ 主推
- 30个问题全部解锁
- 每小时更新
- Email周报

Pro: $79/月
- 连接Google Analytics + Facebook Ads
- AI主动预警（库存不足、销量异常）
- WhatsApp/Slack通知
- 数据导出

Enterprise: $199/月
- 多店铺管理
- 团队协作
- 优先支持
```

**定价逻辑:**
- Shopify卖家平均月收入：$5K-50K
- $29-79 = 他们收入的<2%
- 比雇分析师便宜100倍（分析师年薪$60K+）

**目标收入:**
- 50个Starter用户 = $1,450 MRR
- 100个Starter用户 = $2,900 MRR
- 可接受的solo项目规模

## Differentiation

| Feature | Shopify AI Analyst | Triple Whale | Glew | Daasity | Shopify自带 |
|---------|-------------------|--------------|------|---------|-------------|
| **定价** | $29/月 | $129/月 | $79/月 | $299/月 | 免费-$299 |
| **复杂度** | ⭐ 极简 | ⭐⭐⭐⭐ 复杂 | ⭐⭐⭐ 中等 | ⭐⭐⭐⭐⭐ 企业级 | ⭐⭐ 简单 |
| **预设问题** | ✅ 30个 | ❌ 需自己配置 | ❌ 需自己配置 | ❌ 需自己配置 | ❌ 基础报表 |
| **AI建议** | ✅ 自动 | ⚠️ 部分 | ❌ 无 | ❌ 无 | ❌ 无 |
| **学习成本** | 0分钟 | 1-2周 | 3-5天 | 1个月+ | 1小时 |
| **多渠道** | ❌ 只Shopify | ✅ 全渠道 | ✅ 多渠道 | ✅ 企业级 | ❌ 只Shopify |
| **目标用户** | 小卖家 | 中型卖家 | 中型卖家 | 大企业 | 所有卖家 |

**核心差异化:**
1. **最便宜** - $29/月 vs 竞品$79-299
2. **最简单** - 30个预设问题，零学习成本
3. **AI驱动** - 自动给建议，不只是展示数据
4. **垂直专注** - 只做Shopify，不分散精力

## Why This Works
✅ **真实痛点** - Shopify卖家确实需要简单的分析工具
✅ **明确用户** - 500万Shopify卖家，1%愿意付费 = 5万潜在客户
✅ **技术可行** - Shopify API成熟，GPT-4足够好
✅ **一人可做** - Week 1能做出MVP，不需要团队
✅ **获客渠道** - Shopify App Store有天然流量
✅ **付费意愿** - $29/月对卖家不算贵（<2%收入）
✅ **快速验证** - 1个月就能知道有没有人要

## Success Metrics

**Week 1-2: MVP Launch**
- 10+ Shopify App Store installs
- 5+ active users
- 1+ paid user ($29)
- User feedback collected

**Week 4: Early Traction**
- 50+ installs
- 20+ active users
- 5+ paid users ($145 MRR)
- <50% churn rate

**Month 3: Decision Point**
- 200+ installs
- 50+ paid users ($1,450 MRR)
- Positive reviews (4+ stars)
- <30% churn rate

**如果达不到Month 3目标 → 放弃**
**如果达到 → 继续优化，加Phase 2功能**

## Competition

### 现有玩家分析:

**1. Triple Whale（强劲竞争者）**
- 融资: $50M+
- 优势: 功能强大，多渠道整合
- 劣势: 太贵($129/月起)，太复杂
- 威胁: 随时可以降价碾压

**2. Glew**
- 优势: 连接多渠道
- 劣势: 界面老旧，$79/月
- 威胁: 中等

**3. Daasity**
- 优势: 企业级功能
- 劣势: $299/月，小卖家用不起
- 威胁: 低（不同市场）

**4. Shopify自带分析**
- 优势: 免费，官方
- 劣势: 太基础，不智能
- 威胁: 如果Shopify加AI功能 = 游戏结束

**市场空白:**
- ✅ "$29/月 + 极简 + AI驱动" 的组合没人做
- ✅ 专注小卖家（年收入$50K-500K）这个细分市场

## Phase 2 (如果Month 3成功)

**功能扩展 (Month 4-6):**
- 📊 Google Analytics集成
- 📱 Facebook Ads集成
- 📧 Email/WhatsApp通知
- 🤖 AI主动预警（库存、异常）
- 📈 高级预测模型
- 📤 数据导出（CSV/PDF）
- 👥 团队协作功能

**增长策略:**
- YouTube教程（"How I analyze my Shopify store in 5 mins"）
- TikTok短视频（展示30个问题）
- Reddit/Facebook Groups推广
- 联盟计划（10% commission）

**目标 (6个月):**
- 500个付费用户
- $14,500 MRR
- 考虑招1个part-time CS

## Risks & Mitigation

### ⚠️ 风险1: Shopify API限制
**问题:** Rate limit（每秒2请求），大店铺拉数据慢
**解决:** 后台异步拉数据 + 用户预期管理（"初始化需30分钟"）

### ⚠️ 风险2: 数据质量差
**问题:** 小卖家数据不全，AI分析不准
**解决:** 数据质量报告 + 教用户改进 + 降低预期

### ⚠️ 风险3: 客服压力
**问题:** 电商卖家不懂技术，会问很多基础问题
**解决:** 详细FAQ + 视频教程 + Intercom自动回复

### ⚠️ 风险4: 竞争加剧
**问题:** Triple Whale可能降价，Shopify可能自己加AI
**解决:** 速度优势（快速获取1000用户）+ 口碑 + 考虑被收购

### ⚠️ 风险5: 市场太小
**问题:** 只有几千真正愿意付费的用户
**解决:** $29定价，100用户=$2,900 MRR，solo可接受

### ⚠️ 风险6: 用户不续费
**问题:** 用完一次就走（低留存）
**解决:** Weekly digest email保持engagement + 持续价值（预警通知）

## Acquisition Strategy

### 渠道1: Shopify App Store（最重要 🎯）
**策略:**
- 前100个用户免费（换5星好评）
- 标题: "Shopify AI Analytics - Simple Answers for Busy Sellers"
- 描述强调: "No SQL, No Dashboards, Just Answers"
- 关键词: analytics, reports, AI, simple, insights

**为什么有效:**
- Shopify App Store每天有流量
- 用户搜索"analytics" / "reports"能找到你
- Shopify处理支付（但抽20%）

### 渠道2: Reddit / Facebook Groups
**目标社区:**
- r/shopify (300K members)
- r/ecommerce (200K members)
- Facebook: "Shopify Entrepreneurs" (100K+ members)

**发帖策略:**
- 不要硬广，分享"我做了个工具帮自己分析店铺"
- 提供免费版，让他们试用
- 收集反馈，快速迭代

### 渠道3: YouTube / TikTok教程
**内容:**
- "How I analyze my Shopify store in 5 minutes"
- "3 Questions every Shopify seller should ask"
- 展示产品，留链接

**为什么有效:**
- 电商卖家爱看教程
- 你的产品本身就是教程（30个问题）

### 渠道4: Product Hunt Launch
**准备:**
- 录制Demo视频（2分钟）
- 准备好评用户（10个）
- 提供Product Hunt专属折扣（50% off首月）

**目标:**
- Top 5 of the day
- 100+ upvotes
- 50+ website visits

### 渠道5: 冷邮件（最后手段）
**方法:**
- 去Shopify Exchange看待售店铺
- 用Hunter.io找邮箱
- 发冷邮件："I noticed your store..."

**现实:**
- 冷邮件转化率很低（<1%）
- 不建议作为主要渠道

## Timeline

### Week 1: MVP Development
```
Day 1-2: Shopify OAuth + API集成
- 学习Shopify API文档
- 实现OAuth连接
- 拉取订单、产品、客户数据
- 存到Supabase

Day 3-4: 核心分析逻辑
- 写10个基础问题的SQL
- GPT-4生成自然语言解释
- 测试数据准确性

Day 5-6: Frontend Dashboard
- Next.js + Tailwind UI
- 卡片式问题展示
- 简单图表（Chart.js）
- Stripe支付集成

Day 7: 测试 + 部署
- 自己店铺测试
- 修关键bug
- 部署到Vercel
```

### Week 2: Shopify App Store上线
```
Day 1-2: App Store准备
- 录制Demo视频
- 写App描述
- 准备截图
- 提交审核（需1-2周）

Day 3-4: Beta测试
- 邀请5个Shopify卖家朋友
- 收集反馈
- 修bug

Day 5-7: Landing Page
- 写文案
- 做SEO
- 准备Product Hunt launch
```

### Week 3-4: Launch + 数据收集
```
Week 3:
- Product Hunt launch
- Reddit/Facebook推广
- 监控metrics
- 每天回复用户

Week 4:
- 分析数据
- 决定: 继续 or 放弃
```

### Month 2-3: 优化 or 放弃
**如果Week 4有5+付费用户:**
- 继续优化
- 加30个问题
- 准备Phase 2

**如果Week 4有0-2付费用户:**
- 写postmortem
- 果断放弃
- 下一个项目

## Investment

**时间:**
- Week 1: 40小时（MVP开发）
- Week 2-4: 20小时（launch + 数据收集）
- **Total: ~60小时**

**金钱:**
- Shopify Partner账号: $0（免费）
- Shopify测试店铺: $0（开发者免费）
- Supabase: $0（Free tier）
- Vercel: $0（Free tier）
- OpenAI API: ~$10（测试用）
- Domain: $10/year
- **Total: ~$20**

**Total Investment: 60小时 + $20**

## Founder-Market Fit

### ✅ Why Me?
**我不是Shopify卖家，但:**
1. ✅ **我理解痛点** - 和10+卖家聊过，问题清晰
2. ✅ **我懂技术** - 能快速做MVP
3. ✅ **我能执行** - 一周做出来，不拖延
4. ✅ **我能验证** - 4周判断继续/放弃，不纠结

### ⚠️ 风险:
- ❌ 不是domain expert（需要学习电商术语）
- ❌ 没有现成的Shopify卖家network（获客难）

### 解决:
- Week 1找5个卖家深度访谈
- 加入Shopify卖家Facebook Groups
- 用Product Hunt/Reddit补偿network不足

## Key Insights from Analysis

### ✅ 为什么比Supaboard AI / Sylvian更适合solo?
1. **垂直细分** - 只做Shopify，不做通用BI
2. **预设问题** - 不需要AI理解业务逻辑（已经预设好）
3. **目标用户明确** - Shopify卖家，不是所有企业
4. **定价合理** - $29/月，小卖家能接受
5. **获客渠道清晰** - Shopify App Store有天然流量

### ⚠️ 但要注意:
1. **竞争** - Triple Whale已经很强
2. **Shopify依赖** - 政策变化可能致命
3. **客服压力** - 电商卖家问题多
4. **市场天花板** - MRR可能到$5K-10K就卡住

### 🎯 核心策略:
**速度 > 完美**
- 1周做出MVP
- 4周验证需求
- 如果不行，立刻放弃
- 不要陷入"再优化一下"的陷阱

---

**Status**: 💡 Ready to Build
**Created**: 2026-02-05
**Priority**: High（真实痛点 + 技术可行 + 明确用户）
**Next Action**: Week 1 Day 1 - 注册Shopify Partner账号，学习API文档
**Decision Deadline**: Week 4末（2026年3月初）

## Sprint Summary

_Last updated: 2026-04-06_

Week 3 _(current)_ · 2026-04-06 to 2026-04-12
Status: ❌ Stalled
Active days: 1 / 7
Total commits: 8

Week 2 · 2026-03-30 to 2026-04-05
Status: ⚠️ Slow
Active days: 4 / 7
Total commits: 41

Week 1 · 2026-03-23 to 2026-03-29
Status: ⚠️ Slow
Active days: 4 / 7
Total commits: 46
