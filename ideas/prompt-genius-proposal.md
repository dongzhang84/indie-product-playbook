# PromptGenius - AI Prompt Tool for SaaS Founders

## One-liner
"AI generates perfect prompts for your SaaS. Save to library, reuse with ⌘P."

## Problem

SaaS创始人每天用ChatGPT/Claude，但浪费大量时间：
- **写不好prompts** - "写个landing page" → AI输出太generic，要改10次
- **重复劳动** - 每次做user interview都要重新想问什么问题
- **没有context** - AI不知道你的SaaS是什么，每次都要解释一遍
- **碎片化** - Reddit/blog有prompts，但scattered，质量参差不齐

**真实场景：**
```
创始人Alex想做product positioning:
1. Google "ChatGPT prompt for product positioning" (5分钟)
2. 找到generic prompt，copy (2分钟)
3. 改prompt加上自己的product info (10分钟)
4. AI输出不够好，再调整prompt (15分钟)
5. 下周又要做一次，重复以上步骤 (32分钟)

Total: 32分钟 × 每周3次 = 96分钟/周浪费
```

**核心痛点：**
"我知道好的prompt能让AI输出质量10x，但我不是prompt engineer。我需要工具帮我生成针对我的SaaS的最佳prompts，然后保存下来反复用。"

## Solution

AI为你的SaaS生成定制化prompts，保存到library，一键复用

**核心流程：**
```
1. 一次性输入你的SaaS info:
   - 产品是什么? "B2B analytics platform"
   - 目标用户? "Data analysts at Series A startups"
   - 当前stage? "MVP with 50 users"

2. 选择场景 (15个预设):
   [ ] Product positioning
   [ ] User interview questions
   [ ] Feature prioritization
   [ ] Cold email outreach
   [ ] Pricing strategy
   [ ] Landing page copy
   ... 等

3. AI生成3个optimized prompts:
   → Conservative (稳妥，适合早期)
   → Aggressive (激进，适合快速增长)
   → Balanced (平衡)

4. 选一个 → 保存到library

5. 下次按⌘P，搜索"positioning" → 一键插入ChatGPT

AI already knows your product context!
```

**Example:**
```
场景: Product Positioning

你之前 (generic prompt):
"Help me write a product positioning statement"
→ AI输出: 泛泛而谈，要改5次

用PromptGenius:
AI生成的prompt (已包含你的SaaS context):
"You are a positioning strategist for B2B SaaS products. 

My product: [Your analytics platform name]
Target: Data analysts at Series A startups (10-50 employees)
Stage: MVP, 50 users, $5K MRR
Key differentiator: 10x faster than Google Analytics for event tracking

Create a positioning statement that:
1. Addresses the pain point: Current tools are too slow for real-time decisions
2. Highlights our speed advantage (benchmark data: 100ms vs 2s)
3. Speaks to their growth stage (need to move fast, limited budget)
4. Positions against Google Analytics (enterprise) and Mixpanel (expensive)

Format as: [For X, who Y, our product is Z that W. Unlike A, we B.]"

→ AI输出: 精准，一次OK ✅
```

## Target Users

**Primary: Indie SaaS Founders**
- Solo founders or 2-5 person teams
- B2B or B2C SaaS products
- MVP to early growth stage (idea - $100K ARR)
- Already using ChatGPT/Claude daily
- 愿意付费for productivity tools ($10-30/月)

**具体画像：**
- **Mike** - 独立开发者，做project management SaaS，每周要写marketing copy、用户调研、feature spec
- **Sarah** - 2人团队，做HR tech，用AI做everything但prompts质量不稳定
- **Tom** - 技术背景，做dev tools，会写代码但不会写marketing文案

**非目标用户：**
- 大公司（他们有专门的copywriter）
- 还没开始用AI的人
- 只想要免费工具的人

## Core Features

### MVP (Week 1)

**1. SaaS Profile Setup**
```
一次性输入，AI记住：
- Product name & description
- Target audience (具体到role, company size, stage)
- Current stage (idea/MVP/growth/scale)
- Key differentiators
- Competitors

→ 后续所有prompts自动包含这些context
```

**2. 15个预设场景**
```
Product:
- Product positioning
- Value proposition
- Feature prioritization

Marketing:
- Landing page copy
- Cold outreach email
- LinkedIn post ideas

User Research:
- User interview questions
- Survey questions
- Feedback analysis

Sales:
- Sales pitch
- Demo script
- Pricing strategy

Growth:
- Growth experiments
- Retention strategies
- Churn reduction
```

**3. AI Prompt Generator**
```
Input: 选择场景 + (optional)额外context
Output: 3个optimized prompts
- Conservative strategy
- Aggressive strategy  
- Balanced approach

用户选一个 → AI再优化 → 保存
```

**4. Prompt Library**
```
Features:
- Save unlimited prompts
- Tag system (positioning, outreach, pricing...)
- Search (fuzzy search by name/tag)
- Edit saved prompts
- Duplicate & modify
- Usage tracking (哪些prompts用得最多)
```

**5. 快捷键插入**
```
⌘P anywhere → search popup
→ 选prompt → copy to clipboard
→ paste到ChatGPT/Claude/Notion

支持:
- Plain text
- Markdown format
- 带{{variables}}的template
```

### Phase 2 (Month 2-3, 如果MVP成功)

- **AI Learning**: 分析你用哪些prompts最多，持续优化
- **Prompt Variants**: A/B test不同prompts，看哪个output最好
- **Team Sharing**: 团队共享prompt library
- **Chrome Extension**: 右键 → insert prompt
- **Templates Marketplace**: 分享/购买其他founders的prompts

## Tech Stack

**Frontend:**
- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS + shadcn/ui
- Zustand (state)

**Backend:**
- Next.js API Routes
- Supabase (database + auth)
- OpenAI GPT-4 API

**Storage:**
```
Tables:
- users (id, email, saas_profile)
- prompts (user_id, title, content, tags, usage_count)
- generations (user_id, scene, created_at) // track API usage
```

**Deploy:**
- Vercel (web app)
- Cloudflare (CDN)

**成本估算 (per user per month):**
```
AI Generation: ~$3
- 用户每周生成5个prompts × 4周 = 20次
- $0.15/次 (GPT-4) = $3

Infrastructure: ~$0.50
- Supabase free tier
- Vercel hobby tier

Total: ~$3.50/user/month
定价$19/月 → 81% margin
```

## Pricing

### Freemium模式

**Free:**
```
- 3 AI生成/月 (试用AI质量)
- 5 saved prompts
- 3个基础场景 (positioning, interview, outreach)
- No team features

目的: 让用户体验AI生成的质量
```

**Pro - $19/月** ⭐ 主推
```
- Unlimited AI生成
- Unlimited saved prompts
- 所有15个场景
- SaaS profile auto-fill
- Prompt optimization
- Priority support
- Export prompts (CSV/JSON)

目标: 100个用户 = $1,900 MRR
```

**Team - $49/月**
```
- Pro所有功能
- 5 team members
- Shared prompt library
- Team analytics
- Slack webhook (new prompts通知)

目标: 小团队
```

**为什么$19？**
- 比Notion ($10) 贵一点 → 定位为"serious tool"
- 比Jasper ($39) 便宜一半 → 对indie hacker friendly
- $19 = 每天$0.63 → "一杯咖啡都不到"
- 每月节省10小时 × $50/hr = $500价值 → ROI 26x

## Differentiation

### vs 免费prompt库 (saasprompts.com等)

| Feature | 免费库 | PromptGenius |
|---------|-------|--------------|
| **Prompts数量** | 500+ static | Unlimited AI生成 |
| **个性化** | ❌ 通用 | ✅ 根据你的SaaS定制 |
| **Context** | ❌ 你要手动加 | ✅ AI already knows |
| **学习** | ❌ 不会改进 | ✅ 越用越好 |
| **使用** | Copy-paste | ⌘P一键插入 |
| **价格** | 免费 | $19/月 |

**核心差异：**
- ✅ **AI动态生成** vs 死的库
- ✅ **记住你的SaaS** vs 每次解释
- ✅ **持续优化** vs 一次性

### vs 通用prompt generator (Feedough, Junia AI等)

| Feature | 通用Generator | PromptGenius |
|---------|--------------|--------------|
| **垂直** | ❌ All use cases | ✅ SaaS专用 |
| **质量** | ⚠️ Generic | ✅ SaaS-optimized |
| **保存** | ❌ No library | ✅ Full library |
| **复用** | ❌ 重新生成 | ✅ 一键插入 |
| **定价** | 大多免费 | $19/月 |

**核心差异：**
- ✅ **垂直专注** → 更精准
- ✅ **Library + 快捷键** → 真正省时间

## Why This Works

### ✅ 真实需求 (已验证)

**证据1: 已有免费资源存在**
- **saasprompts.com**: 500+ prompts免费
  → 说明需求存在
  → 但选择free model = monetization难

- **GitHub repos**: SaaS-GPT4-Prompts有stars
  → 社区在找这类prompts

- **Notion templates**: 有人在卖"20+ SaaS prompts"
  → 有付费意愿

**证据2: SaaS founders已经在用AI**
- 72% marketers用AI (HubSpot)
- Indie Hackers forum到处讨论ChatGPT
- r/SaaS频繁提到"best prompts for..."

**证据3: 现有方案都是静态的**
```
Current pain:
"我收藏了50个prompts在Notion，
但每次用还是要改，
还是要加我的product info，
还是很费时间。"

→ 我们解决这个gap
```

### ✅ 市场空白明确

**现有玩家：**
```
通用prompt库: God of Prompt, FlowGPT
→ 太杂，SaaS相关的只占10%

SaaS免费库: saasprompts.com
→ Static，不个性化，无UX

通用generator: Feedough, Junia AI
→ 不vertical，质量一般
```

**我们填补的gap：**
```
"SaaS专用 + AI生成 + Personal library + 快捷键"
= 没人做这个组合
```

### ✅ 技术可行 (Solo 1周)

**Day 1-2: AI生成逻辑**
```
- GPT-4 prompt templates (15个场景)
- SaaS profile → context injection
- Generate 3 variants logic
- Test quality
```

**Day 3-4: Library + 快捷键**
```
- Supabase setup
- CRUD for prompts
- Tag system
- Search (fuzzy)
- ⌘P popup (simple modal)
```

**Day 5-6: UI + Payment**
```
- Landing page
- Dashboard
- Stripe integration
- Deploy to Vercel
```

**Day 7: 测试 + Launch准备**

### ✅ 获客渠道清晰

**Primary: Indie SaaS社区**
```
Reddit:
- r/SaaS (launch post)
- r/microsaas
- r/entrepreneur

Indie Hackers:
- "Show IH: PromptGenius"
- 分享早期数据

Twitter:
- #buildinpublic
- Tag SaaS influencers
- Daily tips thread
```

**Content Marketing:**
```
- "10 prompts every SaaS founder should use"
- "How I validate ideas with AI in 10 minutes"
- "My AI workflow as a solo founder"
- Case study: "How [founder] saved 10h/week"
```

**Viral Mechanics:**
```
Referral: "邀请1个朋友 → 免费1个月"
Template sharing: "分享你的prompts → earn credits"
Word of mouth: "这帮我省了X小时" → 自然传播
```

## Success Metrics

### Week 4 (Decision Point)

**目标：**
```
Users:
- 50+ signups
- 20+ active (用了5次+)
- 10+ paying ($190 MRR)

Product:
- AI生成准确率 >70% (用户满意度)
- Average time saved: 15+ min/week
- <20% churn

Validation:
- 3+ testimonials
- "This is exactly what I needed"

如果达到 → 继续全力做
如果接近 → 优化1个月
如果差很远 → Pivot or stop
```

### Month 3 (PMF验证)

**目标：**
```
Revenue:
- $1,000 MRR
- 50-70 paying users
- 30%+ free→paid conversion

Product:
- 200+ total signups
- 100+ monthly actives
- <25% churn
- NPS >40

Growth:
- Organic开始 (no paid ads)
- 3+ case studies
- Reddit有人主动推荐

如果达到 → Scale up
如果接近 → 继续优化
如果差远 → Postmortem
```

## Timeline

### Week 1: MVP Development

```
Mon-Tue:
□ Supabase setup
□ GPT-4 API测试
□ 15个场景的prompt templates
□ SaaS profile → context injection logic

Wed-Thu:
□ Prompt library CRUD
□ Tag system
□ Search功能
□ ⌘P快捷键popup

Fri-Sat:
□ Landing page
□ Dashboard UI
□ Stripe integration
□ 响应式设计

Sun:
□ 测试
□ 修bugs
□ Deploy
□ Launch prep (Twitter thread, Reddit post文案)
```

### Week 2: Beta Launch

```
Mon-Tue:
□ 邀请5个founder朋友试用
□ 收集feedback
□ 快速iteration

Wed:
□ r/SaaS launch
□ Indie Hackers post
□ Twitter announcement

Thu-Sun:
□ 回复所有comments
□ 修明显bugs
□ 优化prompts (根据feedback)
□ 准备Product Hunt
```

### Week 3-4: 数据收集

```
每天check:
□ Signups
□ Active users
□ Paying users
□ Churn
□ Feedback

每周做:
□ 优化AI prompts
□ 修bugs
□ 1-2个content pieces
□ 联系用户要testimonial
```

## Investment

### 时间投入
```
Week 1: 40-50小时 (MVP开发)
Week 2-4: 10-15小时/周 (运营)

Total: 70-95小时 (2周全职 or 1个月part-time)
```

### 金钱投入
```
必需:
- Domain: $12/year
- OpenAI API: ~$30 (前50个用户测试)
- Vercel/Supabase: $0 (free tier)

可选:
- Logo: $30 (Fiverr)
- PH promote: $0 (organic)

Total: $42-72
```

### ROI估算

**Expected case:**
```
Week 4:
- 10 paying × $19 = $190 MRR

Month 3:
- 50 paying × $19 = $950 MRR

Month 6:
- 100 paying × $19 = $1,900 MRR

Year 1:
- 150 paying × $19 = $2,850 MRR
- Annual revenue: $34,200
- Cost: ~$72 + 100h
- 如果hourly rate $50 = $5,072 total cost
- Net: $29,128
- ROI: 574%
```

## Risks & Mitigation

### ⚠️ 风险1: AI生成质量不够好

**问题:** 如果prompts不够好，用户不会付费

**解决:**
```
1. 前期manual testing
   - 每个场景测试20+次
   - 优化prompt templates

2. 用户feedback loop
   - "这个prompt有用吗？" 👍👎
   - 收集差评，改进

3. Human review (早期)
   - 前100个用户手动check
   - 建立quality benchmark

4. 降级方案
   - 如果AI不work → 提供curated static prompts
   - 至少有baseline quality
```

### ⚠️ 风险2: 用户不付费

**问题:** 觉得free prompts够用

**解决:**
```
1. Free tier限制严格
   - 只3次AI生成/月
   - 让用户体验但不够用

2. 强调价值
   - "每月节省10小时"
   - Case studies
   - Before/after对比

3. Testimonials
   - "这比我自己找prompts省90%时间"
   - Social proof

4. 如果真的不work
   - 降价到$9/月
   - 或pivot到B2B (team版)
```

### ⚠️ 风险3: 市场太小

**问题:** 只有100个SaaS founders愿意付费

**解决:**
```
1. 快速验证 (Week 4数据)
   - 如果<10 paying → 明显太小
   
2. 扩展TAM
   - 不只indie hackers
   - 也做startup employees
   - 也做agencies

3. Pivot
   - 如果SaaS垂直太小
   → "AI Prompts for Marketers"
   → 或其他vertical

4. 接受现实
   - $1-2K MRR也可以
   - Side project很好
```

## Key Takeaways

### ✅ 为什么这个能work

**1. 真实痛点**
```
SaaS founders每周用AI 10+小时
但浪费30%时间在写prompts上
→ 明确的time-saving value prop
```

**2. 市场gap明确**
```
免费库: Static，不个性化
通用generator: 不vertical
→ 我们做: SaaS专用 + AI + Library
```

**3. 可防御**
```
Static prompts: 任何人可copy
AI + User data: 越用越好，难copy
```

**4. 快速验证**
```
1周MVP
2周看traction
4周决定continue/pivot
→ 低风险
```

### 💡 成功关键

**1. Prompt质量第一**
```
AI生成的prompts必须真的好
→ 前期投入时间优化templates
→ 持续收集feedback改进
```

**2. 快速迭代**
```
Week 1: Ship MVP
Week 2: 看数据
Week 3-4: 根据feedback优化
→ 不要过度build
```

**3. 社区驱动**
```
r/SaaS, Indie Hackers是核心
→ 真诚分享
→ 帮助其他founders
→ 自然获客
```

---

**Status**: 💡 Ready to Build  
**Priority**: ⭐⭐⭐⭐⭐ Very High  
**Next Action**: Weekend测试GPT-4生成质量 → Week 1 MVP → Week 2 launch

**Decision Point**: Week 4数据
- 如果10+ paying → 继续
- 如果<5 paying → Pivot
- 如果<2 paying → Stop

---

**Let's build! 🚀**
