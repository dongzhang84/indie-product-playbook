# Facebook Groups Aggregator

## One-liner
"Stop clicking through 10 Facebook groups. See all your community updates in one feed."

## Problem
- 管理多个Facebook Groups效率低下(要一个个点进去)
- 错过重要讨论和机会
- Facebook原生界面体验差,没有统一视图
- 私密Groups无法用第三方工具整合(API限制)

## Solution
Chrome Extension + Web Dashboard
- 自动抓取你加入的所有Groups的帖子
- 统一时间线展示(按时间或重要性排序)
- 支持私密Groups(因为Extension在你浏览器运行)
- 过滤、搜索、标记功能

## Target Users
- **Community Managers** - 管理多个社区
- **Content Creators** - 监控话题和趋势
- **Parents** - 关注多个家长群(tutoring、homeschool、admissions)
- **Local Residents** - 本地社区、活动群
- **Marketers** - 追踪竞品和用户讨论

## Core Features (MVP - 3 Days)

### Day 1: Chrome Extension
- 检测用户在Facebook Group页面
- 抓取帖子(标题、作者、时间、摘要、链接)
- 发送到后端API

### Day 2: Backend + Database
- User auth(注册/登录)
- API接收Extension数据
- PostgreSQL存储Groups和Posts
- 统一Feed API

### Day 3: Web Dashboard
- Landing page
- Feed视图(时间排序)
- Settings(管理关注的Groups)
- Stripe支付集成

## Tech Stack
- Extension: Chrome Manifest V3 + JavaScript
- Frontend: Next.js + TypeScript + Tailwind
- Backend: Next.js API Routes
- Database: Supabase (PostgreSQL)
- Auth: Supabase Auth
- Payment: Stripe
- Deploy: Vercel (web) + Chrome Web Store (extension)

## Pricing
- **Free**: 关注3个Groups,保存7天
- **Pro**: $9/month - 无限Groups,永久保存,高级过滤

## Differentiation
| Feature | Our Tool | Reddit Tools | Native FB | Feedly |
|---------|----------|--------------|-----------|---------|
| FB私密Groups | ✅ | ❌ | ✅但体验差 | ❌ |
| 统一Feed | ✅ | ✅ | ❌ | ✅ |
| 自动抓取 | ✅ | ✅ | ❌ | ✅ |
| 支持私密内容 | ✅ | ❌ | ✅ | ❌ |
| 价格 | $9/月 | Free-$10 | Free | $8/月 |

**核心优势: 唯一能整合Facebook私密Groups的工具**

## Why This Works
✅ 真实痛点(创始人自己的需求 - 10+个Groups要管理)
✅ 技术可行(Chrome Extension可以访问私密Groups)
✅ 竞品空白(Reddit整合已饱和,Facebook整合几乎没人做)
✅ 明确用户(Community managers, parents, local residents)
✅ 合理定价($9/月,目标用户能接受)
✅ 3天MVP(技术栈简单,快速验证)

## Success Metrics
**Week 1:**
- 50+ Chrome Web Store installs
- 20+ signups
- 5+ daily active users
- 1-2 paid users ($9-18)

**Week 4:**
- 200+ installs
- 50+ signups
- 20+ daily active
- 10+ paid users ($90 MRR)

**Month 3 (决定继续/放弃):**
- 500+ installs
- 100+ paid users ($900 MRR)
- Positive user feedback
- <30% churn rate

## Competition
- **Reddit Aggregators (饱和)**: Reddit自带Multireddit, Feedly等工具成熟
- **Facebook Groups Tools (空白)**: 官方API严格限制,大部分工具做不了私密Groups
- **现有工具**: 主要是企业级(贵、复杂)

## Phase 2 (如果成功)
- 🔔 实时推送通知(重要帖子)
- 🏷️ Smart tags(AI自动分类)
- 📊 Analytics(哪些Groups最活跃)
- 🔍 高级搜索(跨Groups搜索关键词)
- 📱 Mobile app
- 🤖 AI摘要(每日digest)

## Risk
⚠️ Facebook可能封Extension
- 解决: Extension只读,用户主动,Backup方案是Bookmarklet

⚠️ 市场太小(只有几千潜在用户)
- 解决: $9/月定价,100 users = $900/月,可接受

⚠️ 用户不愿为此付费
- 解决: Free tier验证需求,看转化率再决定

⚠️ Facebook频繁改版,维护成本高
- 解决: 简单架构,易于更新;如果维护成本>收入,果断放弃

## Timeline
**Week 1: Development**
- Day 1: Extension (抓取功能)
- Day 2: Backend + DB
- Day 3: Web Dashboard + Payment

**Week 2: Testing + Launch**
- Day 1-2: 自己测试(10个真实Groups)
- Day 3-4: 5个朋友试用
- Day 5: Product Hunt launch

**Week 3-4: Data Collection**
- Monitor metrics daily
- Collect user feedback
- Fix critical bugs

**Week 5: Decision**
- Review metrics
- If good → continue optimization
- If bad → write postmortem, move on

## Investment
- **Time**: 3 days MVP + 2 weeks validation = ~60 hours
- **Money**: Chrome Web Store $5 one-time
- **Total**: ~$5

## Why Me / Founder-Market Fit
✅ 我自己有这个痛点(10+ Facebook Groups要管理)
✅ 我是第一个用户(可以持续dogfooding)
✅ 我懂技术(可以快速开发和迭代)

---

**Status**: 💡 Ready to Build
**Created**: 2026-02-05
**Priority**: High (真实痛点 + 技术可行)
**Next Action**: 开始Day 1 - 写Chrome Extension
