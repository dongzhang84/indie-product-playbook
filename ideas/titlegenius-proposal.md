# TitleGenius - Product Proposal

## Original Product
**AI Product Title Generator**  
https://theresanaiforthat.com/ai/ai-product-title-generator/

**问题：**
- 免费无商业模式
- 功能简单
- 有用户反馈"doesn't work"
- 仅1K views，没做大

## One-liner
"Generate SEO-optimized product titles that sell - in 3 seconds"

## Problem
E-commerce卖家（Amazon/Shopify/Etsy）每天要写大量产品标题：
- 手动写太慢
- 不知道什么标题convert好
- SEO优化很难
- 需要多语言版本

## Solution
输入产品信息 → AI生成3个优化标题 → 选择最好的 → 一键复制
- 3个变体可A/B测试
- SEO评分
- 多语言支持
- 保存历史记录

## Target Users
- Amazon sellers（主要）
- Shopify店主
- Etsy手工艺者
- 电商运营人员

## Core Features (MVP - 3天)

### Day 1-2: 核心功能
1. **输入表单** - 产品名、类别、关键特点
2. **AI生成** - 3个标题变体（短/中/长）
3. **结果显示** - 标题 + 字符数 + SEO评分
4. **一键复制**

### Day 3: 商业化
5. **用户系统** - Supabase Auth
6. **Free tier** - 5 titles/天
7. **付费tier** - $5/月

## Tech Stack
- Next.js + TypeScript + Tailwind
- OpenAI API (GPT-4o-mini)
- Supabase (auth + database)
- Stripe (payment)
- Vercel (deploy)

## Pricing
| Tier | Price | Limit | Target |
|------|-------|-------|--------|
| Free | $0 | 5 titles/天 | 试用者 |
| Pro | $5/月 | 50 titles/天 | 小卖家 |
| Business | $15/月 | Unlimited | 大卖家 |

**成本分析：**
- AI cost: ~$0.01/title
- 如果用户用50 titles/月 → $0.50 cost
- $5收入 - $0.50 = $4.50 profit (90% margin)

## Differentiation

| Feature | 原版 | TitleGenius |
|---------|------|-------------|
| 价格 | 免费 | Freemium |
| 变体数 | 1个 | 3个 |
| SEO评分 | ❌ | ✅ |
| 多语言 | ❌ | ✅ (英/西/中) |
| 历史记录 | ❌ | ✅ |
| 可靠性 | 有bug | 稳定 |

## Why This Works
✅ 极简单（3天MVP）
✅ 明确付费意愿（B2B工具，时间=金钱）
✅ 低成本高利润（90% margin）
✅ 可快速验证（E-commerce sellers容易找到）
✅ 可扩展（今天title，明天description，后天整个listing）

## Success Metrics

**Week 1:**
- 50+ visits
- 10+ signups
- 2+ paid users ($10 MRR)

**Week 4:**
- 200+ visits
- 30+ signups
- 8+ paid ($40 MRR)

## Competition
**原版AI Product Title Generator:**
- 免费但没做大
- 1K views = 小众
- 有bug

**其他竞品：**
- TextBrew: 9.5K views - 专注EAN codes
- RewriteSomething: 9K views - 免费
- 都不专注"title generation"

**优势：**
- 我们收费但更好
- 专注title这一个场景
- 有商业模式

## Risk
⚠️ 市场规模中等（E-commerce sellers）
⚠️ 需要找到distribution渠道（Reddit r/AmazonSeller）
⚠️ AI cost可能上升（但可调价）

## Phase 2 (如果成功)
- 多平台优化（Amazon vs Shopify不同规则）
- Bulk generation（上传CSV）
- Chrome extension
- Description + bullets生成
- 竞品标题分析

## Timeline
- **Week 1**: 3天MVP开发 + 4天PH准备
- **Week 2**: Product Hunt launch
- **Week 3-4**: 观察数据，决定继续/放弃

---

**Status**: Proposal  
**Original**: https://theresanaiforthat.com/ai/ai-product-title-generator/  
**Created**: 2026-02-02  
**Decision**: TBD

## Next Steps
1. 确认要做
2. 设计Prompt engineering（如何生成好标题）
3. Day 1开始开发
4. 准备PH launch文案
