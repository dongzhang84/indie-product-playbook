# 产品分析：找第一批客户工具 (LaunchRadar)

**分析日期：** 2026年2月12日  
**分析师：** Claude  
**分析方法：** 需求验证 + 竞品分析 + MVP设计 + 成本估算

---

## 执行摘要

### 📊 核心发现

**市场需求验证：** ⭐⭐⭐⭐⭐ (5/5) - 强烈真实需求
- 100+ 高engagement讨论帖在Indie Hackers/Reddit
- Indie Hackers官方举办"100 Users in 100 Days Challenge"（500+人参加）
- 多位founder明确说："My main challenge is getting customers"

**竞争态势：** ⭐⭐⭐ (3/5) - 红海但有机会
- 100+ 竞品工具存在
- GummySearch（最受欢迎工具）于2025年12月关闭
- 现有工具定位："Brand monitoring"，不是"Customer finding"

**Solo可行性：** ⭐⭐⭐⭐ (4/5) - 3周MVP可行
- 技术栈：Next.js + GPT-4 + Reddit API
- 开发时间：120小时（3周）
- 运营成本：$164/月（100用户）

**盈利潜力：** ⭐⭐⭐⭐ (4/5) - 高利润率
- 定价：$29/月
- 目标：70用户 = $2K MRR（2个月内）
- 利润率：94%（规模化后）

### 🎯 最终评分

**总分：⭐⭐⭐⭐ (4/5) - 强烈推荐，但需先验证**

**建议行动：**
1. ✅ 执行2周pre-build validation
2. ✅ 如果获得10+ email signups → 立即开发MVP
3. ✅ 如果< 5 signups → pivot到其他idea
4. ✅ 目标：2个月达到$2K MRR

---

## 目录

1. [市场需求验证](#1-市场需求验证)
2. [竞品全景分析](#2-竞品全景分析)
3. [产品差异化策略](#3-产品差异化策略)
4. [MVP设计方案](#4-mvp设计方案)
5. [技术架构与成本](#5-技术架构与成本)
6. [验证计划](#6-验证计划)
7. [风险分析](#7-风险分析)
8. [Go/No-Go决策](#8-gono-go决策)

---

## 1. 市场需求验证

### 1.1 Evidence来源

**搜索方法：**
- Reddit r/SideProject、r/Entrepreneur、r/startups
- Indie Hackers论坛帖子
- 关键词：找客户、first customers、how to get users

**发现的真实讨论：**

#### 讨论1：Indie Hackers - "What are your biggest challenges?"
> "I would say the biggest challenge is finding the right clients or audience and getting them to interact."

- 发布时间：2023年10月
- Engagement：50+ comments
- 多人重复同样问题

#### 讨论2：Indie Hackers - "Help me get my first 10 customers 😥"
> "For the last 4 months, I was working on my startup Float. Now we have a hard time getting our first 10 customers..."

- 发布时间：2022年10月
- Engagement：40+ comments
- 显示持续痛点

#### 讨论3：HackerNoon - "Top 5 Challenges for Indie Hackers"
> "Marketing, marketing, marketing. That's what it's going to come down to. But many indie hackers really struggle to get excited about doing marketing. Building is just so much more satisfying... finding customers online. It's freakin' hard."

- 情感强烈："freakin' hard"
- 显示深层frustration

#### 讨论4：Indie Hackers - "100 Users in 100 Days Challenge"
> "Last year over 500 indie hackers competed, collaborated, and challenged each other to reach an audacious goal: get 100 new paying users in 100 days."

- 官方活动验证需求
- 500+人参加
- 证明这是#1痛点

### 1.2 需求强度分析

#### 符合"鱼总痛点原则"

**"我现在很难受" vs "想变更好"：**

✅ **我现在很难受：**
- 产品做出来了，没人用 → 血亏
- 不知道去哪里找客户 → 焦虑
- 发了很多地方没反应 → 挫败感
- "Spent 6 months trying to find customers" → 时间浪费

❌ **想变更好：**
- 定价优化 → 等有客户了再说
- Email温度检测 → nice-to-have

**结论：找第一批客户 = 存在性焦虑，不是优化问题**

#### Recurring Pain

```
不是一次性问题：
✅ 需要找到第1个客户
✅ 需要找到前10个客户
✅ 需要找到前100个客户
✅ 持续获客

→ 适合订阅制产品
```

#### Willingness to Pay

```
市场证据：
- Starnus/Gro：$20/月（同日发布 = 市场validation）
- Octolens：$49-299/月（1000+ B2B SaaS公司使用）
- Syften：$29/月
- Redreach：$49/月

如果真能带来paying customers：
→ $50/月都不贵
→ ROI清晰：1个客户 = tool费用回本
```

### 1.3 用户Journey分析

**典型的Indie Hacker痛苦旅程：**

```
Week 1-4: 开发MVP
Week 5: "产品做好了！去哪里找用户？"
  ↓
Week 6: Google搜索 → 看到建议
  - "Post on Reddit"
  - "Join relevant communities"
  - "Do cold outreach"
  ↓
Week 7-8: 手动尝试
  - 去r/entrepreneur发帖 → 被downvote
  - 去r/startups发帖 → 被删除（spam）
  - 搜索相关讨论 → 太多信息，不知道去哪个
  ↓
Week 9-10: Frustration
  - "Spent hours on Reddit, got 2 signups"
  - "How do people do this?"
  - Google: "how to find customers on Reddit"
  ↓
Week 11-12: 发现tool或放弃
  - 找到F5Bot → 太多noise
  - 找到付费工具 → 太贵 or 功能不对
  - 或者放弃，回去build
```

**Critical Search Moment（关键搜索时刻）：**
- "how to find first customers"
- "reddit customer acquisition"
- "how to get users for my SaaS"
- "finding early adopters"

### 1.4 需求量化

**搜索量数据（来自竞品分析）：**

```
"how to get customers"：2,000-4,000/月搜索
"early adopters SaaS"：100-250/月
"finding customers on social media"：800-1,500/月
"reddit for customer acquisition"：50-100/月
```

**市场规模估算：**

```
Indie Hackers社区：100,000+ members
每月新产品launch：~1,000（估算）
需要帮助找客户：80%（估算）
= 800 potential customers/month

如果conversion 5% = 40 new customers/month
如果留存3个月 = 120 customers steady state
如果定价$29/mo = $3,480 MRR ceiling

→ 这是conservative估算
→ 实际市场更大（Reddit、Twitter、其他社区）
```

---

## 2. 竞品全景分析

### 2.1 市场现状

**惊人发现（来自Indie Hacker创始人）：**

> "Eleven months ago, I launched a product to help people find potential customers online, mainly through Reddit. At the time, there were only two other tools I knew of doing something similar... Now the niche is full. There are probably close to 100 similar products out there."
> 
> — April 2025

**关键事件：GummySearch关闭**

```
GummySearch：
- 最受欢迎的Reddit audience research工具
- $49/月
- 关闭时间：2025年12月1日
- 原因：Reddit denied API access

用户反应：
"GummySearch was a great tool for this, but they are 
shutting down because reddit did not give them official access."

→ 市场gap
→ 用户需要alternative
→ 但没有clear winner
```

### 2.2 竞品分类矩阵

#### 🆓 Free Tier

| 工具 | 价格 | 核心功能 | 主要痛点 |
|------|------|----------|----------|
| **F5Bot** | 免费 | Reddit/HN keyword alerts via email | ❌ "Hundreds of alerts, 1 in 50 useful"<br>❌ "Drowning in false positives" |
| **Google Alerts** | 免费 | Web-wide keyword monitoring | ❌ 延迟高（几天）<br>❌ Miss most Reddit content |

**用户评价：**
> "Spent hours manually checking Reddit/HN. Tried F5Bot and got overwhelmed with noise."

> "It worked, but drowning in false positives was brutal."

#### 💵 Budget Tier ($19-49/mo)

| 工具 | 价格 | 定位 | 特色 | 缺点 |
|------|------|------|------|------|
| **KWatch.io** | $19/mo | Basic Reddit monitoring | Affordable entry point | 功能简单，无AI filtering |
| **Syften** | $29/mo | Multi-platform keyword tracking | "Most relevant mentions, least noise"<br>Slack integration | 仍有false positives<br>Generic monitoring |
| **Buska** | $29/mo | Reddit monitoring + AI filtering | Webhook support<br>Better than F5Bot | 中等功能 |
| **Wappkit Reddit** | One-time | Desktop app, local search | Comment count filter<br>No cloud costs | 不是monitoring，只是search tool<br>需要手动run |
| **Devi** | $49.90/mo | Multi-platform lead gen | Reddit+LinkedIn+Twitter+FB | 不够Reddit-focused |

**用户评价：**
> "For social tracking, I used Syften ($29/mo). Also set up Zapier to push mentions to Slack."

> "The comment count filter is a game changer once you get used to it." (Wappkit)

#### 🚀 Mid Tier ($49-99/mo)

| 工具 | 价格 | 定位 | 用户数 | 状态 |
|------|------|------|--------|------|
| **GummySearch** | $49/mo | Reddit audience research | Large | ❌ 已关闭 (Dec 2025) |
| **Redreach** | $49/mo | B2B lead gen from Reddit | Growing | ✅ Active |
| **CatchIntent** | ? | AI intent detection | Small | ✅ Active |
| **Octolens** | $49-299/mo | Multi-platform brand monitoring | 1,000+ B2B SaaS | ✅ Active |
| **ReplyAgent.ai** | ? | Discovery → AI reply → posting | New | ✅ Active |
| **LeadSynth** | ? | Reddit+X+LinkedIn monitoring | 250+ | ✅ Active (2周前launch) |
| **Alertly** | ? | Daily digest + AI drafts | New | ✅ Active |

**用户评价：**
> "I've tried others like Octolens, Syften, and F5bot. Octolens is my favorite. The AI filtering was the deciding factor."

> "We've found Redreach super valuable for keeping tabs and jumping into conversations early."

#### 🏢 Enterprise ($100+/mo)

| 工具 | 价格 | 目标客户 | 定位 |
|------|------|----------|------|
| **Brand24** | $79+/mo | Mid-size to enterprise teams | Multi-platform social listening |
| **Brandwatch** | Custom ($$$$) | Enterprise | Comprehensive social listening |
| **Mention** | $99+/mo | Agencies, brands | Brand monitoring + sentiment analysis |
| **Sprout Social** | $249+/mo | Enterprise social teams | Full social media management |

### 2.3 关键Insights

#### Insight #1: "建工具"是common pattern

**多个founder说：**
> "I ended up building a desktop tool that searches multiple subreddits simultaneously..."

> "After wasting months on manual approaches, I built a simple keyword monitoring system."

> "I built Wappkit Reddit to solve this. It filters posts by comment count and keywords..."

**分析：**
- ✅ 痛点够painful让人自己build tool
- ✅ 说明没有perfect solution
- ❌ 但大部分tool都很basic
- ✅ Market validation：需求真实存在

#### Insight #2: 所有工具的共同问题

**F5Bot用户抱怨：**
```
❌ "Hundreds of notifications, but rarely acting on them"
❌ "Maybe 1 out of 50 emails useful"
❌ "Marking F5Bot emails as read without opening them"
❌ "Noise took more time than it was worth"
```

**付费工具用户抱怨：**
```
❌ "Still too many false positives" (Syften)
❌ "$49-299 too expensive for indie hackers" (Octolens)
❌ "Generic monitoring, not customer finding specific"
```

**共同痛点总结：**
1. **Signal-to-noise ratio差** - 太多irrelevant alerts
2. **需要手动filter** - Tool只是减少工作量，没有eliminate
3. **Pricing不match indie hackers** - 要么免费但差，要么贵但过度
4. **Generic monitoring** - 不是专门为"finding first customers"设计

#### Insight #3: 市场正在converge on AI

**工具进化趋势：**
```
2022-2023: Keyword alerts (F5Bot, Syften)
2024: AI-powered relevance filtering (Octolens, CatchIntent)
2025: AI reply suggestions (Redreach, ReplyAgent)
2026: AI-guided workflow (？LaunchRadar机会？)
```

**用户期待：**
- 不只是monitoring
- 要actionable intelligence
- 要help execute（不只discover）

#### Insight #4: GummySearch关闭 = 窗口期

**时间线：**
```
2022: GummySearch launch
2023-2024: 成为most beloved Reddit research tool
2025 Dec 1: Shutdown
2025 Dec-2026 Feb: Users寻找alternative

当前状态（2026年2月）：
→ 没有clear replacement
→ 多个新工具在竞争这个space
→ 窗口期：6-12个月
```

### 2.4 竞品功能对比

| 功能 | F5Bot | Syften | Redreach | Octolens | LaunchRadar (拟) |
|------|-------|--------|----------|----------|------------------|
| **价格** | 免费 | $29/mo | $49/mo | $49-299/mo | $29/mo |
| **Reddit监控** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **HN监控** | ✅ | ✅ | ❌ | ❌ | ✅ |
| **多平台** | ❌ | ✅ | ❌ | ✅ | ❌ (focused) |
| **AI filtering** | ❌ | ⚠️ Basic | ✅ | ✅ | ✅ Advanced |
| **Intent detection** | ❌ | ❌ | ✅ | ⚠️ | ✅ High/Med/Low |
| **Reply suggestions** | ❌ | ❌ | ✅ | ❌ | ✅ Multiple variations |
| **Learning mode** | ❌ | ❌ | ❌ | ❌ | ✅ Personalized |
| **Daily digest** | ❌ Email spam | ✅ | ✅ | ✅ | ✅ Curated 3-5 opps |
| **ROI tracking** | ❌ | ❌ | ✅ | ❌ | ✅ Conversion tracking |
| **定位** | Free monitoring | Social listening | B2B lead gen | Brand monitoring | **Customer finding** |

**Key Differentiators：**

LaunchRadar与众不同之处：
1. ✅ **定位清晰**：Not "monitoring" → "Finding first customers"
2. ✅ **Stage-specific**：Only for product launch phase
3. ✅ **High curation**：3-5 opps/day，不是50+ alerts
4. ✅ **Learning mode**：AI learns your ICP over time
5. ✅ **Affordable**：$29/mo sweet spot（不是免费也不是$99）

---

## 3. 产品差异化策略

### 3.1 发现的Market Gap

#### 现有工具做什么？

```
✅ Monitor brand mentions (defensive)
   - "有人提到你的品牌了"
   - 用途：Reputation management
   
✅ Track competitors
   - "你的竞争对手被提到了"
   - 用途：Competitive intelligence
   
✅ General "social listening"
   - "这些话题在trending"
   - 用途：Market research

✅ Multi-platform monitoring
   - "Reddit + Twitter + LinkedIn + FB"
   - 用途：Enterprise brand management
```

#### Indie Hackers真正需要什么？

```
❌ 不需要：Monitor已有品牌（product刚做出来，还没有brand）
❌ 不需要：Enterprise analytics（一个人干活）
❌ 不需要：Track 1000+ mentions/day（只需要high-quality leads）

✅ 真正需要：
1. "我刚做了个产品，去哪里找第一批用户？"
   → 不是monitor，是discover
   
2. "Reddit/HN哪些thread我该参与？"
   → 不是所有mentions，是high-intent only
   
3. "这个讨论是否relevant to my product?"
   → 不是keyword match，是semantic understanding
   
4. "我该怎么回复才不像spam？"
   → 不只alert，要actionable guidance
```

#### 🎯 The Gap

```
所有现有工具 = "Monitoring Tools"
市场gap = "Customer Finding Guide"

差别举例：

Monitoring Tool说：
"keyword 'project management' was mentioned 50 times today"
→ 你需要自己去看50个discussions
→ 自己判断哪些relevant
→ 自己想怎么回复

Customer Finding Guide说：
"这5个discussions里的人正在找project management工具
→ 建议你去r/startups这个帖子回复
→ 这个人2小时前发的，现在回复最佳
→ 建议这样说：[AI template]
→ 不要提产品名，先问需求"
```

### 3.2 定位策略

#### Positioning Statement

```
For: Indie hackers在launch mode（刚做完产品，找前100个用户）

Who: 不知道去哪里找第一批客户，手动搜索Reddit/HN太耗时

[Product Name] is: AI-powered customer finding guide

That: 每天告诉你去哪个Reddit/HN thread回复，说什么

Unlike: F5Bot (太多noise), Octolens (太贵，功能过度)

We: 只给你3-5个high-intent opportunities，帮你craft回复
```

#### 核心信息

**Tagline选项：**
1. "Stop monitoring everything. Start finding customers."
2. "AI finds people who need your product."
3. "3-5 high-intent leads daily. Not 50 noisy alerts."
4. "From launch to first 100 customers."

**One-liner：**
"LaunchRadar finds Reddit/HN discussions where people need your product. We tell you which threads to join and what to say. $29/mo."

#### Brand Voice

```
❌ 不要：
- "Enterprise-grade social listening"
- "Advanced sentiment analysis"
- "Multi-platform monitoring"
- 听起来像大公司工具

✅ 要：
- "Built for indie hackers like you"
- "Stop wasting time scrolling Reddit"
- "Find customers, not mentions"
- "Launch mode tool, not forever tool"
```

### 3.3 产品原则

#### 不做的（避开红海）

```
❌ Generic brand monitoring
   → 让Octolens/Brand24做
   
❌ Multi-platform (Reddit+Twitter+LinkedIn+FB)
   → 专注做好Reddit + HN
   
❌ Enterprise features
   → Team collaboration, RBAC, etc.
   
❌ Auto-reply automation
   → Reddit会ban，违反原则
   
❌ Sentiment analysis
   → 不重要for this use case
   
❌ Influencer tracking
   → 不相关
   
❌ Historical data mining
   → 专注real-time
```

#### 要做的（蓝海定位）

```
✅ "Launch mode" specific
   → 明确说：This is for 0→100 customers
   → 不是long-term monitoring tool
   
✅ Reddit + HN only (extremely focused)
   → 这两个platform最重要for indie hackers
   
✅ Not just alerts, but "go here and say this"
   → Actionable intelligence
   
✅ Stage-specific: "Finding first 10/100 customers"
   → 不是general marketing
   
✅ Budget-friendly: $20-29/mo
   → Indie hacker price point
   
✅ AI-curated "high-intent only"
   → 3-5 opportunities/day，不是50+
   
✅ Learning mode
   → AI learns your specific ICP
```

#### 核心价值主张

**不是卖：**
- Monitoring
- Alerts
- Data

**而是卖：**
- Time savings ("5 hours → 15 minutes")
- Confidence ("Know where to post")
- Results ("Get your first customers")

**Messaging框架：**
```
Problem: "Spent 6 months, still no customers"
Agitation: "Tried Reddit, got banned. Tried F5Bot, drowned in noise."
Solution: "LaunchRadar gives you 3 high-intent leads daily + what to say"
Proof: "Sarah got 12 customers in 2 weeks"
```

---

## 4. MVP设计方案

### 4.1 产品命名

**Name Candidates：**
1. **LaunchRadar** ⭐ (推荐)
   - 含义：Launch期间的雷达，找客户
   - 域名：launchradar.com (available)
   
2. CustomerScout
   - 含义：Customer侦察兵
   - 域名：customerscout.io
   
3. FirstTen
   - 含义：Find your first 10 customers
   - 域名：firstten.app
   
4. IntentFinder
   - 含义：Find buying intent
   - 域名：intentfinder.com

**最终选择：LaunchRadar**
- 简单易记
- 清晰传达value（launch + find）
- .com域名available
- 听起来专业但不corporate

### 4.2 核心功能设计

#### Feature 1: Smart Setup (10分钟完成)

**目的：** 让AI理解user的产品和目标客户

**User Flow：**
```
Step 1: Describe Your Product
┌─────────────────────────────────────┐
│ What does your product do?          │
│ ──────────────────────────────────  │
│ [Text area: 1-2 sentences]          │
│                                      │
│ Example: "I built a Notion template │
│ for managing side projects"         │
└─────────────────────────────────────┘

Step 2: Who Needs This?
┌─────────────────────────────────────┐
│ Who is your ideal customer?          │
│ ──────────────────────────────────  │
│ [Text area]                          │
│                                      │
│ Example: "Indie hackers juggling    │
│ multiple side projects"              │
└─────────────────────────────────────┘

Step 3: AI Generates Keywords + Subreddits
┌─────────────────────────────────────┐
│ ✨ Based on your input, we suggest:│
│                                      │
│ Keywords to track:                   │
│ ☑ "managing multiple projects"      │
│ ☑ "side project organization"       │
│ ☑ "too many projects"                │
│ ☑ "overwhelmed with projects"       │
│ ☐ "project management" (too broad)  │
│                                      │
│ [+ Add custom keyword]               │
│                                      │
│ Subreddits to monitor:               │
│ ☑ r/SideProject                      │
│ ☑ r/indiehackers                     │
│ ☑ r/Entrepreneur                     │
│ ☐ r/productivity                     │
│                                      │
│ [+ Add custom subreddit]             │
└─────────────────────────────────────┘

Step 4: Review Example Opportunities
┌─────────────────────────────────────┐
│ Here are 3 past discussions that    │
│ would have matched:                  │
│                                      │
│ 1. "How do you all manage 5+ side   │
│    projects at once?" (r/SideProject)│
│    💚 This is perfect!               │
│                                      │
│ 2. "Best tool for tracking tasks?"  │
│    (r/productivity)                  │
│    🤔 Maybe relevant                 │
│                                      │
│ 3. "I need a project manager"       │
│    (r/forhire)                       │
│    ❌ Not relevant (job post)        │
└─────────────────────────────────────┘

[Save & Start Monitoring] button
```

**AI Processing Behind the Scenes：**
```javascript
// GPT-4o prompt
const prompt = `
Given this product: "${productDescription}"
And target customer: "${targetCustomer}"

Generate:
1. 10-15 problem-focused keywords (not solution keywords)
2. 5-10 relevant subreddits
3. Explain why each is relevant

Format as JSON.
`;

// Example output
{
  "keywords": [
    {
      "term": "managing multiple projects",
      "type": "problem",
      "reasoning": "Direct pain point expression"
    },
    {
      "term": "too many side projects",
      "type": "problem",
      "reasoning": "Emotional/frustrated state"
    }
  ],
  "subreddits": [
    {
      "name": "r/SideProject",
      "relevance": "high",
      "reasoning": "Target audience hangs out here"
    }
  ]
}
```

#### Feature 2: Daily Digest (核心价值)

**目的：** 每天给user 3-5个high-quality opportunities，不是50+ noise

**Email Template：**

```
Subject: 🎯 3 high-intent opportunities found today

───────────────────────────────────────────────

Good morning! Here are today's best opportunities
to find customers for [Product Name]:

───────────────────────────────────────────────

🔥🔥🔥 HIGH INTENT
r/SideProject • Posted 2 hours ago • 8 comments

"Looking for a project management tool for solo founders"

💡 Why relevant:
Explicitly asking for PM tool recommendation, and they
mentioned "solo founder" which matches your ICP.

📍 Current discussion:
3 people suggested Trello, 2 suggested Notion. OP replied
"Notion is too complex for me" - perfect opening for you.

✍️ Suggested reply:
"Hey! I struggled with the same thing. What specific
features are most important to you? [Then mention your
product naturally if it fits]"

⏰ Best time to reply: NOW (thread is 2hr old)

[View on Reddit] [I Replied ✓] [Not Relevant ✗]

───────────────────────────────────────────────

🔥🔥 MEDIUM INTENT
r/Entrepreneur • Posted 5 hours ago • 15 comments

"How do you all track your tasks across multiple projects?"

💡 Why relevant:
Open-ended question about task tracking, multiple people
engaging. Not explicitly looking for tool but receptive.

✍️ Suggested reply:
"For me, the key was finding something that didn't require
much setup. I use [mention if natural]..."

⏰ Best time to reply: Within 12 hours

[View on Reddit] [I Replied ✓] [Not Relevant ✗]

───────────────────────────────────────────────

🔥 LOW INTENT (For reference)
r/productivity • Posted 8 hours ago • 30 comments

"What's your productivity system?"

💡 Why relevant:
Broad productivity discussion, some comments mention
project management.

Note: This thread has 30 comments already. Lower chance
of visibility, but you could try if you have time.

[View on Reddit] [Skip]

───────────────────────────────────────────────

📊 Your Stats This Week:
✓ Opportunities found: 18
✓ You replied to: 5
✓ Upvotes received: 23
✓ Conversions: 1 (Update)

[View Dashboard] [Update Settings] [Pause Monitoring]
```

**Digest Generation Logic：**

```javascript
// Daily cron job
async function generateDailyDigest(userId) {
  // 1. Fetch all posts from last 24 hours matching keywords
  const rawPosts = await fetchRedditPosts(user.keywords);
  
  // 2. AI filtering for relevance
  const scoredPosts = await Promise.all(
    rawPosts.map(post => scoreRelevance(post, user))
  );
  
  // 3. Sort by intent score (0-100)
  const sorted = scoredPosts.sort((a, b) => b.score - a.score);
  
  // 4. Take top 3-5 (high intent only)
  const topOpps = sorted.filter(p => p.score > 70).slice(0, 5);
  
  // 5. Generate reply suggestions for each
  const withReplies = await Promise.all(
    topOpps.map(opp => generateReplySuggestions(opp, user))
  );
  
  // 6. Send email
  await sendDigestEmail(user, withReplies);
}

async function scoreRelevance(post, user) {
  const prompt = `
  Product: ${user.productDescription}
  Target: ${user.targetCustomer}
  
  Reddit post: "${post.title}"
  Subreddit: ${post.subreddit}
  Body: "${post.body}"
  
  Score this post's relevance (0-100):
  - 90-100: Explicitly asking for solution like this
  - 70-89: Describing problem this solves
  - 50-69: Tangentially related
  - 0-49: Not relevant
  
  Return JSON with: score, reasoning, intent_level
  `;
  
  const result = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    response_format: { type: "json_object" },
    messages: [{ role: "user", content: prompt }]
  });
  
  return JSON.parse(result.choices[0].message.content);
}
```

#### Feature 3: Reply Assistant

**目的：** Help user craft responses that don't sound like spam

**UI Flow：**

```
User clicks "View on Reddit" → Opens modal

┌──────────────────────────────────────────────┐
│ 🔥🔥🔥 HIGH INTENT                            │
│ r/SideProject • 2 hours ago                   │
│                                               │
│ "Looking for a project management tool       │
│  for solo founders"                           │
│                                               │
│ OP's comment:                                 │
│ "Notion is too complex for me"               │
│                                               │
│ ───────────────────────────────────────────  │
│                                               │
│ 💬 Suggested Replies (pick one or edit):     │
│                                               │
│ ▶ Approach 1: Helpful (subtle mention)       │
│   "Hey! I had the same issue with Notion.    │
│    What specific features matter most to     │
│    you? I ended up building [Product] to     │
│    solve exactly this - happy to share       │
│    if helpful."                               │
│                                               │
│   Pros: Natural, offers value first          │
│   Cons: Might be seen as self-promotion      │
│                                               │
│ ○ Approach 2: Educational (no mention)       │
│   "Totally get that. For simple project      │
│    tracking, I found that less features      │
│    is actually better. What's your main      │
│    struggle - task tracking or overview?"    │
│                                               │
│   Pros: No spam, builds rapport              │
│   Cons: Requires follow-up to mention        │
│                                               │
│ ○ Approach 3: Question-first                 │
│   "What don't you like about Notion          │
│    specifically? The learning curve or       │
│    the features?"                             │
│                                               │
│   Pros: Shows genuine interest               │
│   Cons: Takes longer to convert              │
│                                               │
│ [Edit Selected Reply]                         │
│ [Copy & Go to Reddit]                         │
│ [Mark as Replied]                             │
└──────────────────────────────────────────────┘
```

**Reply Generation Prompt：**

```javascript
const generateReplySuggestions = async (post, user) => {
  const prompt = `
  Context:
  - Product: ${user.productDescription}
  - Reddit post: "${post.title}"
  - OP's comments: "${post.opComments}"
  
  Generate 3 reply approaches:
  
  1. Helpful: Offer value first, subtly mention product if natural
  2. Educational: Answer question without mentioning product
  3. Question-based: Ask clarifying questions to understand needs
  
  For each:
  - Write natural Reddit-style reply (2-3 sentences)
  - Explain pros/cons
  - Suggest when to use this approach
  
  Important:
  - Don't sound like marketing
  - Be genuinely helpful
  - Match Reddit's casual tone
  - No emojis or excessive enthusiasm
  
  Return as JSON array.
  `;
  
  // ...
};
```

#### Feature 4: Learning Mode

**目的：** AI learns user's specific ICP over time

**How it works：**

```
Week 1:
User sees 5 opportunities/day
Marks some as:
✅ "Good fit - want more like this"
❌ "Not relevant - avoid similar"

LaunchRadar AI learns:
→ Which language patterns indicate good fit
→ Which subreddits convert better
→ Which intent signals matter most
→ User's reply style preferences

Week 2+:
Personalized filtering based on feedback
Better relevance scores
Fewer false positives
```

**Feedback UI：**

```
After user clicks "Not Relevant":

┌──────────────────────────────────────────────┐
│ Thanks for the feedback!                      │
│                                               │
│ Help us improve: Why wasn't this relevant?   │
│                                               │
│ ○ Wrong audience (not my ICP)                │
│ ○ Too broad/generic discussion               │
│ ○ Already too many comments (low visibility) │
│ ○ Job posting, not customer discussion       │
│ ○ Other: [text field]                        │
│                                               │
│ [Submit]                                      │
└──────────────────────────────────────────────┘
```

**Learning Algorithm：**

```javascript
// Simple Bayesian approach
const updateUserProfile = async (userId, feedback) => {
  // Get post characteristics
  const post = feedback.post;
  const features = extractFeatures(post);
  // e.g. {
  //   subreddit: "r/Entrepreneur",
  //   commentCount: 25,
  //   hasQuestionMark: true,
  //   containsKeyword: "project management",
  //   sentiment: "frustrated"
  // }
  
  // Update user's preference weights
  if (feedback.isRelevant) {
    await incrementWeights(userId, features, +1);
  } else {
    await incrementWeights(userId, features, -1);
  }
  
  // Retrain scoring model
  await retrainUserModel(userId);
};
```

### 4.3 What's NOT in MVP

**明确scope：**

```
❌ Auto-posting（Reddit会ban，违反原则）
❌ Twitter/LinkedIn monitoring（focus = Reddit + HN only）
❌ Competitor tracking（不是defensive tool）
❌ Brand monitoring（不是reputation management）
❌ Analytics dashboard（keep it simple）
❌ Team features（solo founder tool）
❌ API access（maybe v2）
❌ Chrome extension（web app足够）
❌ Mobile app（responsive web足够）
❌ Subreddit database（YAGNI）
❌ Historical search（real-time focus）
❌ Sentiment analysis（不需要for this use case）
❌ Influencer identification（不相关）
```

**Why这些不做？**

1. **保持focus** - 做一件事做好
2. **Fast to market** - 3周launch，不是6个月
3. **Learn from users** - Build what they actually need
4. **Avoid GummySearch's fate** - 不依赖complex scraping

**v2 Feature Roadmap（基于user feedback）：**

```
可能的v2 features:
- Twitter/LinkedIn monitoring
- Team collaboration
- Weekly reports
- Chrome extension
- Historical search
- Advanced analytics
- API access
- White-label for agencies

但MVP不做这些。
```

### 4.4 完整User Journey

**Day 0: Onboarding (10 minutes)**
```
1. Land on homepage
2. Click "Start Free Trial" (7-day free)
3. Sign up (email + password)
4. Onboarding wizard:
   - "What's your product?" (1-2 sentences)
   - "Who needs it?" (target customer)
   - AI generates keywords + subreddits
   - Review and edit
   - "Done! You'll get your first digest tomorrow"
5. Optional: Browse example opportunities
```

**Day 1: First Digest**
```
6. Receive email: "3 high-intent opportunities found"
7. Open email, see 3 opportunities
8. Click first one: "🔥🔥🔥 High Intent"
9. Read context + suggested reply
10. Pick reply approach (or edit)
11. Copy reply
12. Click "View on Reddit"
13. Paste reply, post
14. Return to LaunchRadar, click "I Replied ✓"
```

**Day 2-7: Active Usage**
```
15. Daily digest arrives
16. Reply to 1-2 opportunities/day
17. Mark some as "Not Relevant" (AI learns)
18. Track stats: upvotes, conversions
19. See improvement in relevance
```

**Day 8+: Paying Customer**
```
20. Free trial ends
21. Prompt to upgrade: "$29/mo"
22. Enter payment (Stripe)
23. Continue receiving digests
24. (Optional) Refer a friend (affiliate program)
```

**Month 2-3: Success → Churn**
```
25. User found 10-50 customers
26. Product launched successfully
27. User cancels subscription
28. Exit survey: "Did we help?"
29. Reactivation email in 6 months: "Launching something new?"
```

**Expected User Lifecycle：**

```
Signup → Active (7 days free) → Convert (pay $29) → 
Active usage (2-3 months) → Churn (success!) → 
Potential reactivation (next launch)

Average LTV: $29 × 3 months = $87
→ Can afford $20-30 CAC
```

---

## 5. 技术架构与成本

### 5.1 Tech Stack

#### Frontend
```
Framework: Next.js 14 (App Router)
- SSR for landing page (SEO)
- Client-side for dashboard
- API routes for backend

Styling: Tailwind CSS
- Rapid development
- Consistent design
- Small bundle size

Components: Shadcn/ui
- Pre-built accessible components
- Customizable
- Free

Why: Fast development, modern, scalable
```

#### Backend
```
Runtime: Next.js API Routes
- Serverless functions
- Auto-scaling
- Simple deployment

Database: PostgreSQL (Neon)
- Relational data model
- Generous free tier
- Auto-scaling
- Branching (great for dev)

ORM: Prisma
- Type-safe queries
- Easy migrations
- Great DX

Why: Serverless = low cost at low scale
```

#### AI
```
Provider: OpenAI

Models:
- GPT-4o-mini: Relevance filtering ($0.15/1M input tokens)
  * Fast, cheap, good enough for classification
  
- GPT-4o: Reply generation ($2.50/1M output tokens)
  * Better quality for user-facing content

Why not Claude/Gemini:
- OpenAI has best JSON mode
- Lowest latency
- Most reliable

Function calling: For structured outputs
```

#### Data Collection
```
Reddit API (Official):
- Free tier: 100 requests/minute
- 10 requests/second
- OAuth2 authentication
- Rate limits are generous

Hacker News API (Firebase):
- Completely free
- Real-time
- No rate limits
- Simple REST API

Why not scraping:
- Legal/ToS issues
- GummySearch failed because of this
- APIs are free and reliable
```

#### Infrastructure
```
Hosting: Vercel
- $20/mo Pro plan
- Auto-scaling
- Global CDN
- Preview deployments
- DDoS protection

Caching: Upstash Redis
- Serverless Redis
- Pay-per-request
- Free tier: 10K requests/day
- Global replication

Email: Resend
- Developer-friendly
- Good deliverability
- Free: 3K emails/month
- $20/mo: 50K emails/month

Why: All serverless, scales automatically
```

#### Monitoring
```
Error Tracking: Sentry
- Free tier: 5K errors/month
- Source maps
- Performance monitoring

Analytics: PostHog
- Free tier: 1M events/month
- Product analytics
- Feature flags
- Session replay

Uptime: BetterStack (free tier)

Why: Best-in-class, generous free tiers
```

#### Payments
```
Stripe:
- 2.9% + $0.30 per transaction
- Simple integration
- Subscription management
- Webhooks for events

Why: Industry standard, easy
```

### 5.2 Database Schema

```prisma
// schema.prisma

model User {
  id                String   @id @default(cuid())
  email             String   @unique
  name              String?
  createdAt         DateTime @default(now())
  
  // Subscription
  stripeCustomerId  String?  @unique
  subscriptionStatus String? // active, canceled, trialing
  trialEndsAt       DateTime?
  
  // Product info
  productDescription String
  targetCustomer     String
  
  // Settings
  keywords          String[] // Array of keywords
  subreddits        String[] // Array of subreddit names
  digestFrequency   String   @default("daily")
  emailEnabled      Boolean  @default(true)
  
  // Stats
  opportunitiesFound Int     @default(0)
  repliesMade        Int     @default(0)
  conversions        Int     @default(0)
  
  // Relations
  opportunities     Opportunity[]
  feedback          Feedback[]
}

model Opportunity {
  id            String   @id @default(cuid())
  userId        String
  user          User     @relation(fields: [userId], references: [id])
  
  // Reddit/HN data
  platform      String   // "reddit" or "hackernews"
  postId        String   // Reddit fullname or HN id
  url           String
  title         String
  body          String?
  subreddit     String?  // null for HN
  author        String
  commentCount  Int
  score         Int      // upvotes
  createdAt     DateTime
  
  // AI scores
  relevanceScore    Int      // 0-100
  intentLevel       String   // high, medium, low
  reasoning         String   // Why it's relevant
  
  // User actions
  viewed        Boolean  @default(false)
  replied       Boolean  @default(false)
  repliedAt     DateTime?
  dismissed     Boolean  @default(false)
  
  // Suggested replies (JSON)
  suggestedReplies Json
  
  createdAt     DateTime @default(now())
}

model Feedback {
  id              String   @id @default(cuid())
  userId          String
  user            User     @relation(fields: [userId], references: [id])
  opportunityId   String
  
  isRelevant      Boolean
  reason          String?  // Why not relevant
  
  createdAt       DateTime @default(now())
}
```

### 5.3 System Architecture

```
┌─────────────────────────────────────────────────┐
│                   User                          │
└────────────┬────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────┐
│              Next.js App (Vercel)               │
│  ┌──────────────┐  ┌──────────────┐            │
│  │  Landing     │  │  Dashboard   │            │
│  │  Page (SSR)  │  │  (Client)    │            │
│  └──────────────┘  └──────────────┘            │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │         API Routes                        │  │
│  │  /api/auth                                │  │
│  │  /api/opportunities                       │  │
│  │  /api/feedback                            │  │
│  │  /api/webhooks/stripe                     │  │
│  └──────────────────────────────────────────┘  │
└────┬─────────────────────────┬─────────────────┘
     │                         │
     ▼                         ▼
┌─────────────────┐    ┌──────────────────┐
│  PostgreSQL     │    │   Upstash Redis  │
│  (Neon)         │    │   (Caching)      │
│                 │    │                  │
│  - Users        │    │  - Rate limits   │
│  - Opportunities│    │  - Session data  │
│  - Feedback     │    │                  │
└─────────────────┘    └──────────────────┘

┌─────────────────────────────────────────────────┐
│         Cron Jobs (Vercel Cron)                 │
│                                                  │
│  Every 30 minutes:                              │
│  └─ Fetch new Reddit posts                     │
│     └─ Filter by keywords                       │
│        └─ Score with AI                         │
│           └─ Save to DB                         │
│                                                  │
│  Every day at 8am (user's timezone):            │
│  └─ Generate digest for each user               │
│     └─ Top 3-5 opportunities                    │
│        └─ Generate reply suggestions            │
│           └─ Send email via Resend              │
└─────────────────────────────────────────────────┘

External Services:
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Reddit API   │  │ HN API       │  │ OpenAI API   │
└──────────────┘  └──────────────┘  └──────────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Resend       │  │ Stripe       │  │ Sentry       │
│ (Email)      │  │ (Payments)   │  │ (Errors)     │
└──────────────┘  └──────────────┘  └──────────────┘
```

### 5.4 开发Timeline

#### Week 1: Foundation (40 hours)

**Day 1-2: Setup + Auth (16h)**
```
□ Next.js 14 project setup
□ Tailwind + Shadcn/ui config
□ Neon PostgreSQL setup
□ Prisma schema + migrations
□ NextAuth.js setup (email/password)
□ Landing page (hero + pricing + FAQ)
□ Email templates setup (Resend)

Deliverable: User can sign up and login
```

**Day 3-4: Reddit/HN Integration (16h)**
```
□ Reddit API OAuth flow
□ Fetch posts by keyword
□ Fetch posts by subreddit
□ HN API integration (Firebase)
□ Store posts in database
□ Deduplication logic
□ Rate limiting (Upstash)

Deliverable: Can fetch and store posts
```

**Day 5-7: AI Filtering (8h)**
```
□ OpenAI GPT-4o-mini integration
□ Relevance scoring prompt engineering
□ Intent level detection
□ Batch processing (process 100 posts/request)
□ Caching (avoid re-scoring same posts)
□ Test accuracy with sample data

Deliverable: Posts scored with relevance
```

#### Week 2: Core Features (40 hours)

**Day 8-10: Onboarding Flow (24h)**
```
□ Multi-step wizard UI
□ Product description form
□ AI keyword extraction (GPT-4o)
□ AI subreddit suggestions
□ Keyword/subreddit review UI
□ Save user preferences
□ Show example opportunities
□ First-time user experience polish

Deliverable: New users can complete setup
```

**Day 11-12: Daily Digest (16h)**
```
□ Digest generation logic
  - Fetch user's opportunities
  - Sort by relevance score
  - Take top 3-5
□ Email template (React Email)
  - HTML + plain text versions
  - Responsive design
  - Unsubscribe link
□ Resend integration
□ Cron job setup (Vercel Cron)
□ Send test digests

Deliverable: Users receive daily emails
```

**Day 13-14: Reply Assistant (0h - moved to Week 3)**
```
Moved to Week 3 for better time allocation
```

#### Week 3: Polish + Launch (40 hours)

**Day 15-17: Reply Assistant (24h)**
```
□ Reply generation prompt (GPT-4o)
□ 3 variation approaches
  - Helpful
  - Educational
  - Question-based
□ Reply modal UI
□ Copy to clipboard
□ "Mark as replied" tracking
□ Reply analytics

Deliverable: Users can generate replies
```

**Day 18-19: Learning Mode + Essential Features (16h)**
```
□ Feedback collection UI
□ User preference updates
□ Simple weight-based learning
□ Dashboard page
  - Stats overview
  - Recent opportunities
  - Activity feed
□ Settings page
  - Edit keywords/subreddits
  - Email preferences
  - Pause monitoring
□ Stripe integration
  - Checkout session
  - Customer portal
  - Webhook handling
□ Usage limits (free vs paid)

Deliverable: Complete user experience
```

**Day 20-21: Launch Prep (0h - use weekend)**
```
□ Comprehensive testing
  - Auth flow
  - Onboarding
  - Email delivery
  - Payment flow
  - Cron jobs
□ Bug fixes
□ Performance optimization
  - Image optimization
  - Code splitting
  - Caching
□ SEO setup
  - Meta tags
  - sitemap.xml
  - robots.txt
□ Product Hunt page draft
□ Indie Hackers post draft
□ Reddit launch post draft
□ Demo video (Loom)
□ Documentation
  - FAQ
  - How it works
  - Privacy policy
  - Terms of service

Deliverable: Ready to launch
```

**Total: 3 weeks = 120 hours**

**Breakdown:**
- Frontend: 40h (33%)
- Backend + API: 35h (29%)
- AI integration: 20h (17%)
- DevOps + Testing: 15h (13%)
- Polish + Docs: 10h (8%)

### 5.5 成本估算

#### Development Costs

**Option 1: DIY (Solo Developer)**
```
Your time: 120 hours
Cost: $0 (opportunity cost only)

Opportunity cost calculation:
If hourly rate = $50/hr
→ $50 × 120h = $6,000

But you're building YOUR product
→ Actual out-of-pocket: $0
```

**Option 2: Hire Developer**
```
US/Western Europe: $60-100/hr
→ $60 × 120h = $7,200
→ $100 × 120h = $12,000

Eastern Europe/India: $25-40/hr
→ $25 × 120h = $3,000
→ $40 × 120h = $4,800

Recommended: India/Eastern Europe via Upwork
→ Budget: $3,000-4,000
```

**Option 3: No-Code (探讨可能性)**
```
可能吗？部分可能

Tools:
- Bubble.io（前端）
- Zapier（Reddit API + GPT）
- Airtable（数据库）

Limitations:
❌ Cron jobs complex
❌ Custom AI logic difficult
❌ Email digest automation tricky
❌ Cost scales badly ($100+/mo tools)

结论：不推荐no-code for this product
```

#### Monthly Operating Costs

**Scenario A: 0-100 Users (Launch Phase)**

```
Infrastructure:
├─ Vercel Pro: $20/mo
│  (Hobby $0 works initially, upgrade at 50 users)
├─ Neon DB: $19/mo
│  (Scale plan, 10GB storage, 300 compute hours)
├─ Upstash Redis: $0/mo
│  (Free tier: 10K requests/day = enough)
└─ Total Infrastructure: $39/mo

AI Costs (100 users):
├─ Filtering (GPT-4o-mini):
│  • 100 users × 10 posts/day = 1,000 posts/day
│  • 500 tokens/post × 1,000 = 500K tokens/day
│  • Input: $0.15/1M tokens
│  • $0.075/day × 30 = $2.25/mo
│
├─ Reply Generation (GPT-4o):
│  • 100 users × 3 opportunities/day = 300 opps/day
│  • 1,000 tokens/reply × 300 = 300K tokens/day
│  • Output: $2.50/1M tokens
│  • $0.75/day × 30 = $22.50/mo
│
└─ Total AI: $24.75/mo

Email (Resend):
├─ 0-30 users: $0/mo (3K emails/month free)
├─ 30-100 users: $20/mo (50K emails/month)
└─ Average: $10/mo

Monitoring:
├─ Sentry: $0/mo (free tier, 5K errors/month)
├─ PostHog: $0/mo (free tier, 1M events/month)
├─ BetterStack: $0/mo (free tier)
└─ Total: $0/mo

Payment Processing (Stripe):
├─ 100 users × $29/mo = $2,900 revenue
├─ Stripe: 2.9% + $0.30/transaction
├─ $2,900 × 2.9% = $84.10
├─ $0.30 × 100 = $30
└─ Total Stripe: $114.10/mo

───────────────────────────
TOTAL OPERATING COSTS: $188/mo

Revenue: $2,900/mo
Costs: $188/mo
Profit: $2,712/mo

Margin: 93.5%
Break-even: 7 paying customers
```

**Scenario B: 100-500 Users (Growth Phase)**

```
Infrastructure:
├─ Vercel Pro: $20/mo (same)
├─ Neon DB: $19/mo (same, can handle 500 users)
├─ Upstash Redis: $0/mo (still within free tier)
└─ Total: $39/mo

AI Costs (500 users):
├─ Filtering: $2.25 × 5 = $11.25/mo
├─ Reply Generation: $22.50 × 5 = $112.50/mo
└─ Total: $123.75/mo

Email:
├─ 500 users × 1 email/day × 30 = 15K emails/mo
├─ Resend: $20/mo (50K emails/month)
└─ Total: $20/mo

Monitoring: $0/mo (still free)

Payment Processing:
├─ 500 users × $29 = $14,500 revenue
├─ Stripe: $14,500 × 2.9% = $420.50
├─ $0.30 × 500 = $150
└─ Total: $570.50/mo

───────────────────────────
TOTAL: $753.25/mo

Revenue: $14,500/mo
Costs: $753/mo
Profit: $13,747/mo

Margin: 94.8%
```

**Scenario C: 500-1,000 Users (Scale Phase)**

```
Infrastructure:
├─ Vercel Pro: $20/mo
├─ Neon DB: $69/mo (Launch plan, better performance)
├─ Upstash Redis: $10/mo (might exceed free tier)
└─ Total: $99/mo

AI Costs (1,000 users):
├─ Filtering: $11.25 × 2 = $22.50/mo
├─ Reply Generation: $112.50 × 2 = $225/mo
└─ Total: $247.50/mo

Email:
├─ 1,000 users × 30 emails = 30K emails/mo
├─ Resend: $20/mo
└─ Total: $20/mo

Monitoring:
├─ Might need paid Sentry: $26/mo
└─ Total: $26/mo

Payment Processing:
├─ 1,000 users × $29 = $29,000 revenue
├─ Stripe: $29,000 × 2.9% = $841
├─ $0.30 × 1,000 = $300
└─ Total: $1,141/mo

───────────────────────────
TOTAL: $1,533.50/mo

Revenue: $29,000/mo
Costs: $1,534/mo
Profit: $27,466/mo

Margin: 94.7%
```

#### Cost Scaling Analysis

```
Graph: Cost vs Users

Users  | Fixed    | Variable | Total  | Revenue  | Margin
-------|----------|----------|--------|----------|-------
10     | $39      | $10      | $49    | $290     | 83%
50     | $39      | $50      | $89    | $1,450   | 94%
100    | $39      | $149     | $188   | $2,900   | 94%
500    | $39      | $714     | $753   | $14,500  | 95%
1,000  | $99      | $1,435   | $1,534 | $29,000  | 95%

Key Insights:
✅ Margins improve with scale (83% → 95%)
✅ AI cost is main variable cost (linear scaling)
✅ Infrastructure cost stays flat (serverless advantage)
✅ Break-even: 7 customers ($203 revenue vs $188 cost)
```

#### Cost Optimization Strategies

**Short-term (MVP):**
```
✅ Use free tiers aggressively
   - Vercel Hobby (upgrade at 50 users)
   - Upstash free tier
   - Sentry/PostHog free tiers
   
✅ Optimize AI usage
   - Use GPT-4o-mini for filtering (10x cheaper)
   - Batch API requests (50% discount)
   - Cache results aggressively
   - Only generate 3 reply variations, not 5
   
✅ Email optimization
   - Send 1 digest/day, not real-time alerts
   - Plain text + HTML (not just HTML)
   
Result: Can start at $10-20/mo for first 10 users
```

**Long-term (Scale):**
```
□ Self-host AI models (if >5,000 users)
  - LLaMA 3 for filtering
  - Save 90% on AI costs
  - But requires GPU server ($200-500/mo)
  
□ Negotiate Stripe rates
  - At $50K+ MRR, negotiate to 2.5%
  
□ Use Redis more aggressively
  - Cache scoring results for 24h
  - Dedupe posts across users
  
□ Email delivery optimization
  - Consider SendGrid (cheaper at scale)
```

### 5.6 Risk Analysis

#### Technical Risks

**🔴 HIGH RISK**

**1. Reddit API Changes/Restrictions**
```
Risk: Reddit might restrict API access
Impact: Product breaks completely
Likelihood: Medium (happened to GummySearch)

Mitigation:
✅ Use official API (not scraping)
✅ Stay within rate limits
✅ Have backup plan:
   - HN-only version
   - Scraping fallback (last resort)
   - Pivot to Twitter/LinkedIn
✅ Build relationship with Reddit
   - Apply for higher rate limits
   - Be transparent about use case
```

**2. AI Accuracy (False Positives/Negatives)**
```
Risk: AI recommends irrelevant threads or misses good ones
Impact: User frustration, churn
Likelihood: High (AI is probabilistic)

Mitigation:
✅ Start conservative (high precision, lower recall)
   - Better to show 3 perfect opps than 10 mixed
✅ Human feedback loop
   - User marks good/bad
   - Retrain continuously
✅ Multiple fallback prompts
   - If GPT-4o fails, try GPT-4o-mini
✅ Monitor accuracy metrics
   - % marked "not relevant"
   - Target: <20%
```

**🟡 MEDIUM RISK**

**3. Email Deliverability**
```
Risk: Emails go to spam
Impact: Users don't see opportunities
Likelihood: Medium

Mitigation:
✅ Use Resend (good reputation)
✅ Warm up sending domain
   - Start with 10 emails/day
   - Gradually increase
✅ DKIM, SPF, DMARC setup
✅ High engagement emails
   - Subject lines tested
   - Clear unsubscribe
✅ Monitor bounce rate
   - Should be <5%
```

**4. HN Rate Limits**
```
Risk: HN API throttles us
Impact: Missing HN opportunities
Likelihood: Low-Medium

Mitigation:
✅ Cache aggressively
   - Store all posts for 24h
✅ Only fetch new posts
   - Not full re-scan
✅ Respect Firebase limits
✅ HN is secondary (Reddit primary)
```

**🟢 LOW RISK**

**5. Scaling Infrastructure**
```
Risk: Can't handle 1,000+ users
Impact: Site slow/down
Likelihood: Very Low

Mitigation:
✅ Vercel + Neon auto-scale
✅ Serverless = no server to crash
✅ Load testing before 500 users
✅ CDN (Vercel) handles static assets
```

#### Business Risks

**🔴 HIGH RISK**

**1. Too Crowded Market (100 Competitors)**
```
Risk: Can't differentiate, lose to competitors
Impact: Can't acquire users
Likelihood: Medium-High

Mitigation:
✅ Clear positioning: "Customer Finding" not "Monitoring"
✅ Laser focus: Launch mode only
✅ Better UX: 3 opps/day, not 50 alerts
✅ Affordable: $29 sweet spot
✅ Content marketing:
   - "How I found 100 customers on Reddit"
   - SEO for "how to find customers"
✅ Indie Hackers community:
   - Build in public
   - Help others for free
   - Word of mouth
```

**2. Users Don't See Value**
```
Risk: Users try it, don't find customers, churn
Impact: High churn rate
Likelihood: Medium

Mitigation:
✅ Strong onboarding
   - 1-1 calls with first 10 users
   - Help them get first reply
   - Show value within 7 days
✅ Success stories
   - Case study: "Found 12 customers in 2 weeks"
✅ Realistic expectations
   - "This helps you find leads, not magic customers"
✅ Prove value quickly
   - First digest within 24h
   - At least 1 high-intent opp in week 1
```

**🟡 MEDIUM RISK**

**3. User Acquisition Cost Too High**
```
Risk: CAC > LTV
Impact: Unprofitable growth
Likelihood: Medium

Mitigation:
✅ Organic first
   - Indie Hackers posts
   - Reddit (carefully)
   - Content marketing
   - SEO
✅ Measure CAC ruthlessly
   - Target: <$30 (1 month LTV)
   - Max: $60 (2 months LTV)
✅ Referral program
   - Give 1 month free for referral
✅ Avoid paid ads initially
   - Too expensive for $29/mo product
```

**4. High Churn Rate**
```
Risk: Users cancel after finding customers
Impact: Low LTV
Likelihood: Medium-High (expected!)

Mitigation:
✅ Embrace it
   - Product IS for launch mode
   - 3-month average is OK
✅ Upsell opportunities:
   - "Launching something else? Come back!"
✅ Reactivation campaigns
   - Email in 6 months: "New product?"
✅ Annual plan option
   - $249/year (save 29%)
   - Locks in for 12 months
```

**🟢 LOW RISK**

**5. Competition from Free Tools (F5Bot)**
```
Risk: Users prefer free F5Bot
Impact: Can't convert free users
Likelihood: Low

Mitigation:
✅ Clear value proposition
   - Time savings: 5h → 15min
   - AI filtering worth $29
✅ Free tier option
   - 1 digest/week (vs daily for paid)
   - Proves value before payment
✅ Position as "upgrade from F5Bot"
   - "Tried F5Bot? Here's the next step"
```

---

## 6. 验证计划

### 6.1 Pre-Build Validation (Week -2 to 0)

**Goal:** Confirm problem + willingness to pay BEFORE building

#### Phase 1: Problem Validation (Days 1-3)

**Target:** Get 10+ people to confirm this is a real problem

**Actions:**

```
Day 1: Reddit/IH Posts
□ Post on r/SideProject:
  "What's your biggest challenge finding first customers?"
  
□ Post on Indie Hackers:
  "Poll: How do you find customers for new products?"
  Options:
  - Manual Reddit/HN browsing
  - Paid tools (which ones?)
  - Cold outreach
  - Word of mouth
  - Still figuring it out
  
□ Track responses:
  - How many say "finding customers" is top challenge?
  - What current solutions do they use?
  - What frustrates them about current solutions?
```

```
Day 2: 1-1 Outreach
□ DM 20 founders who recently launched on Product Hunt
  
  Template:
  "Hey [name], saw you launched [product] recently!
  Quick question: What was your biggest challenge 
  finding your first customers?
  
  Building something to help with this, would love
  to learn from your experience."
  
□ Target: 10+ responses
□ Ask follow-up:
  - "Would a tool that finds Reddit discussions help?"
  - "What would you pay for that?"
```

```
Day 3: Validate Specific Pain Points
□ Find existing "how to get customers" threads
□ Comment on 5-10 threads:
  "I'm building a tool that automatically finds 
  Reddit discussions where you can promote your 
  product. Would this be helpful?"
  
□ Track:
  - Upvotes
  - Replies
  - Interest level
```

**Success Criteria:**
```
✅ 10+ people explicitly say "yes, finding customers is hard"
✅ 3+ people say "I'd pay for this"
✅ 0 people say "X tool already does this perfectly"
✅ 5+ people ask "when can I try this?"
```

**Kill Signal:**
```
❌ <5 people interested
❌ Multiple people say "F5Bot is good enough"
❌ No one wants to pay
```

#### Phase 2: Willingness to Pay (Days 4-6)

**Target:** Get 20+ email signups for beta waitlist

**Actions:**

```
Day 4: Build Landing Page
□ Use: Vercel + Next.js (1 page)
□ Sections:
  1. Hero: Problem + Solution
  2. How it works: 3 simple steps
  3. Pricing: "$29/mo (7-day free trial)"
  4. Waitlist: Email signup form
  5. FAQ

□ Tools:
  - Vercel (hosting)
  - Resend (email collection)
  - Plausible (analytics, free tier)
  
□ Time: 4-6 hours
```

**Landing Page Copy:**

```markdown
# Stop wasting 5 hours/week scrolling Reddit. Find customers in 15 minutes.

You built a product. Now you need customers.

You've been told to "find them on Reddit."

So you spend hours:
- Scrolling through subreddits
- Searching for keywords
- Reading hundreds of threads
- Trying to find the 3 that actually matter

**There's a better way.**

## LaunchRadar finds high-intent leads for you

Every morning, get 3-5 opportunities where people are:
✓ Asking for exactly what you built
✓ Open to recommendations
✓ Ready to become customers

No noise. No spam. Just qualified leads.

[Join Waitlist - Free 7 Day Trial]

---

## How It Works

1️⃣ Tell us about your product (2 minutes)

2️⃣ AI finds relevant Reddit/HN discussions (automated)

3️⃣ Get daily digest with best opportunities (every morning)

That's it. No manual work.

---

## Pricing

**$29/month**

- Daily digest of 3-5 opportunities
- AI-powered relevance filtering
- Reply suggestions
- 7-day free trial

[Start Free Trial]

---

## FAQ

**Q: How is this different from F5Bot?**
A: F5Bot sends you every mention (100+ alerts/day). 
We use AI to show only 3-5 high-intent opportunities.

**Q: Will I get banned from Reddit?**
A: No. We don't auto-post. We find threads, you reply manually.

**Q: Does this work for any product?**
A: Best for B2B SaaS, tools, and services. Less effective for physical products.

[Join Waitlist]
```

```
Day 5: Drive Traffic
□ Share on:
  - Personal Twitter
  - Indie Hackers showcase
  - r/SideProject (carefully)
  - LinkedIn
  - Personal network (DMs)
  
□ Track:
  - Landing page visitors
  - Email signups
  - Conversion rate

□ Goal: 100+ visitors
```

```
Day 6: Follow Up
□ Email everyone who signed up:
  
  Subject: Quick question about LaunchRadar
  
  "Hey [name],
  
  Thanks for joining the waitlist!
  
  Quick question: What's your #1 frustration 
  finding customers right now?
  
  And what would make LaunchRadar a must-have
  for you?
  
  [Your name]"
  
□ Collect feedback
□ Refine messaging
```

**Success Criteria:**
```
✅ 100+ landing page visitors
✅ 20+ email signups (20% conversion)
✅ 5+ people reply to follow-up
✅ Nobody says "$29 is way too expensive"
✅ 2+ people ask "when can I start using this?"
```

**Kill Signal:**
```
❌ <50 visitors (can't validate)
❌ <10 signups (<10% conversion)
❌ Multiple people say "too expensive"
❌ No engagement with follow-up email
```

#### Phase 3: Solution Validation (Days 7-8)

**Target:** Confirm our approach is better than alternatives

**Actions:**

```
Day 7: Create Comparison Doc
□ Make table:
  LaunchRadar vs F5Bot vs Syften vs Redreach
  
□ Focus on:
  - Number of alerts/day
  - AI filtering quality
  - Reply suggestions
  - Price
  - Use case fit
  
□ Share with 10 beta signups
□ Ask: "Would you pay $29/mo for this?"
```

```
Day 8: Feature Validation
□ Survey beta signups:
  
  "What features are must-have for you?"
  □ Daily digest
  □ Reply suggestions
  □ Intent scoring
  □ Learning mode
  □ Historical search
  □ Team features
  □ Mobile app
  
□ Prioritize based on votes
□ Cut features that <30% want
```

**Success Criteria:**
```
✅ 7/10 people say "yes, I'd pay $29"
✅ Clear consensus on must-have features
✅ Validation that differentiation matters
✅ Users understand value prop
```

**Kill Signal:**
```
❌ <5/10 would pay
❌ No agreement on features (everyone wants different things)
❌ Users say "this is just like X"
```

### 6.2 Post-MVP Validation (Weeks 4-8)

#### Week 4: Beta Launch (10 Users)

**Goal:** Get 10 real users using the product

**Actions:**

```
Day 1: Personal Outreach
□ Email waitlist (top 20):
  "Beta is ready! You're one of 10 spots."
  
□ Offer: 50% off for 3 months ($15/mo)

□ 1-1 onboarding call:
  - Help set up keywords
  - Review first digest together
  - Answer questions
  
□ Create private Slack channel
  - Direct access to you
  - Report bugs
  - Share feedback
```

```
Day 2-7: Daily Engagement
□ Check-in daily:
  - "Did you get your digest?"
  - "Any opportunities look good?"
  - "Need help with anything?"
  
□ Fix bugs immediately
□ Ship updates daily
□ Ask for feedback constantly
```

**Metrics to Track:**

```
Activation:
- % users who complete onboarding
- % users who set up keywords
- Time to first digest

Engagement:
- % users who open digest email
- % users who click opportunities
- % users who mark "replied"

Satisfaction:
- NPS score (ask after 1 week)
- Feature requests
- Bug reports

Conversion:
- Stories: "I found a customer!"
- Screenshots of Reddit replies
- Qualitative feedback
```

**Success Criteria:**
```
✅ 8/10 users complete onboarding
✅ 7/10 users active weekly (open digest)
✅ Average 2+ replies/user/week
✅ NPS > 30
✅ 1+ conversion story ("I got a customer!")
✅ <3 critical bugs
```

**Kill Signal:**
```
❌ <5/10 users active after week 1
❌ Multiple users say "opportunities not relevant"
❌ NPS < 0
❌ 0 replies made by users
```

#### Week 5-6: Iterate Based on Feedback

**Goal:** Fix top issues, add most-requested feature

**Actions:**

```
Week 5:
□ Conduct 1-1 interviews with all 10 users
  - What's working?
  - What's frustrating?
  - What would make this 10x better?
  - Would you keep paying after discount ends?
  
□ Analyze usage data:
  - Which opportunities get clicked most?
  - Which get marked "not relevant"?
  - Reply patterns
  - Time to value
  
□ Prioritize fixes:
  1. Bugs (fix immediately)
  2. UX friction (fix this week)
  3. Feature requests (pick top 1)
```

```
Week 6:
□ Ship improvements:
  - Fix top 3 complaints
  - Add #1 requested feature
  - Improve onboarding
  
□ Re-engage users:
  - "We shipped your feedback!"
  - Ask them to try again
  
□ Measure improvement:
  - Did engagement increase?
  - Did NPS improve?
  - More replies?
```

**Success Criteria:**
```
✅ Churn < 20% (8/10 still active)
✅ NPS improves by 10+ points
✅ Feature requests prioritized
✅ 2+ users say "this is so much better"
✅ Clear product-market fit signal
```

#### Week 7-8: Expand Beta (50 Users)

**Goal:** Scale to 50 paying users at full price

**Actions:**

```
Week 7: Open Beta
□ Remove waitlist
□ Open signups on website
□ Charge full $29/mo (no discount)
□ Soft launch:
  - Product Hunt (small launch)
  - Indie Hackers showcase
  - Reddit r/SideProject
  - Twitter announcement
  
□ Set up:
  - Automated onboarding emails
  - Help docs
  - FAQ
  - Support system (email)
```

```
Week 8: Scale Support
□ Monitor:
  - Signup conversion rate
  - Payment conversion rate
  - Week 1 retention
  - Support tickets
  
□ Optimize:
  - Onboarding flow (reduce drop-off)
  - Email copy (improve open rates)
  - Landing page (improve conversion)
  
□ Goal: 50 paid users by end of week
```

**Metrics Dashboard:**

```
Acquisition:
- Landing page visitors
- Signup conversion rate
- Payment conversion rate

Activation:
- % complete onboarding
- Time to first value

Engagement:
- DAU/WAU
- Digest open rate
- Opportunities clicked
- Replies made

Revenue:
- MRR
- Churn rate
- LTV

Satisfaction:
- NPS
- Support tickets
- Bug reports
```

**Success Criteria:**
```
✅ 50+ paid users
✅ <10% churn/month
✅ 2+ five-star reviews
✅ $1,450 MRR
✅ <5 support tickets/day
✅ Users say "this is valuable"
```

**Kill Signal:**
```
❌ <20 paid users after 2 weeks
❌ >30% churn in first month
❌ Multiple negative reviews
❌ Users say "not worth $29"
```

### 6.3 Kill/Pivot Criteria

**🔴 KILL Signals:**

```
Pre-build:
❌ <10 email signups after 2 weeks
❌ Nobody willing to pay
❌ Multiple people say "X already does this"

Post-MVP:
❌ <3 paying users after 4 weeks beta
❌ >50% churn in month 1
❌ Users say "F5Bot is good enough"
❌ Reddit API shuts down access
❌ Can't get to $500 MRR in 2 months

If any of these: STOP. Cut losses.
```

**🟡 PIVOT Signals:**

```
□ Users want different use case:
  - Not for launching, but ongoing monitoring
  - Pivot: Different positioning
  
□ Different platform more valuable:
  - Twitter > Reddit
  - Pivot: Twitter-only version
  
□ Different pricing model:
  - Annual upfront better
  - Pivot: Lifetime deal
  
□ Need to narrow niche:
  - Works for SaaS, not for physical products
  - Pivot: "For SaaS founders only"
  
If any of these: ITERATE, don't kill.
```

**🟢 DOUBLE DOWN Signals:**

```
✅ >50 paying users in 2 months
✅ <10% churn/month
✅ Users say "this saved me 5+ hours/week"
✅ Word of mouth growth >20%/month
✅ NPS > 50
✅ Clear path to 500 users
✅ Users asking for more features

If these: SCALE. Invest more.
```

### 6.4 Launch Checklist

**Pre-Launch (Week 3):**

```
Product:
□ All core features working
□ No critical bugs
□ Fast (<2s page load)
□ Mobile responsive
□ Email delivery tested
□ Payment flow tested
□ Cron jobs working
□ Error tracking setup

Landing Page:
□ Clear value prop
□ Social proof (beta testimonials)
□ Pricing page
□ FAQ
□ Terms & Privacy

Marketing Assets:
□ Product Hunt page drafted
□ Indie Hackers post drafted
□ Reddit post drafted
□ Twitter thread written
□ Demo video (Loom, 2min)
□ Screenshots
□ Beta testimonials

Prep:
□ 10 beta signups ready to support launch
□ Reddit account karma >100
□ Twitter followers >50
□ Email list ready
```

**Launch Day (Week 4, Tuesday 6am PT):**

```
6:00am PT - Product Hunt
□ Publish PH page
□ Post to Twitter
□ Email beta users: "We're live, help us!"

8:00am PT - Indie Hackers
□ Post "Show IH" showcase
□ Share story + link
□ Respond to comments quickly

10:00am PT - Reddit
□ r/SideProject post (carefully!)
□ Focus on story, not promotion
□ "I spent 3 weeks building this..."

Throughout day:
□ Reply to ALL comments (PH, IH, Reddit)
□ Thank everyone
□ Answer questions
□ Fix bugs immediately
□ Post updates

Evening:
□ Send thank you email to supporters
□ Post Twitter update: "Day 1 results"
□ Rest (you earned it)
```

**Week 1 Post-Launch:**

```
Day 2-3:
□ Reply to all PH/IH comments
□ Fix critical bugs
□ Onboard new users (1-1 if needed)

Day 4-5:
□ Weekly usage report to users
□ Ask for feedback
□ Fix top bugs

Day 6-7:
□ Analyze metrics:
  - Signups
  - Conversions
  - Engagement
  - Churn
□ Write "Week 1 post-mortem"
□ Plan Week 2
```

**Month 1 Goals:**

```
Revenue: $500 MRR (17 users)
Engagement: 70% WAU
Churn: <20%/month
NPS: >30

If hit: Continue
If miss: Iterate or pivot
```

---

## 7. 风险分析

*(Covered in Section 5.6 - consolidated here for reference)*

### Technical Risks Summary

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| Reddit API restrictions | 🔴 High | Medium | Use official API, stay within limits, backup plans |
| AI accuracy issues | 🔴 High | High | Conservative filtering, human feedback loop |
| Email deliverability | 🟡 Medium | Medium | Use Resend, warm up domain, DKIM/SPF |
| HN rate limits | 🟡 Medium | Low | Aggressive caching, HN is secondary |
| Scaling issues | 🟢 Low | Very Low | Serverless auto-scales |

### Business Risks Summary

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| Too crowded market | 🔴 High | High | Clear differentiation, focus positioning |
| Users don't see value | 🔴 High | Medium | Strong onboarding, prove value in 7 days |
| High CAC | 🟡 Medium | Medium | Organic-first, content marketing |
| High churn | 🟡 Medium | High | Expected (launch tool), embrace it |
| F5Bot competition | 🟢 Low | Low | Clear value prop, time savings |

---

## 8. Go/No-Go决策

### ✅ Reasons to Build

```
1. ✅ REAL PAIN POINT
   - 100+ high-engagement discussions
   - Founders explicitly say "finding customers is hardest"
   - Indie Hackers runs official "100 in 100 days" challenge
   → Problem is real, not imagined

2. ✅ WILLINGNESS TO PAY
   - Market already has $19-299/mo tools
   - Octolens has 1,000+ B2B customers
   - Starnus/Gro launched same day (market validation)
   → People pay for this category

3. ✅ CLEAR DIFFERENTIATION
   - All tools = "monitoring"
   - We = "customer finding guide"
   - 3-5 opps/day vs 50+ alerts
   → Blue ocean positioning

4. ✅ SOLO FEASIBLE
   - 3 weeks to MVP (120 hours)
   - $188/mo operating cost (100 users)
   - Simple tech stack (Next.js + GPT + APIs)
   → Can actually build this alone

5. ✅ FAST VALIDATION
   - 2 weeks pre-build validation
   - Know if it's working in 4 weeks
   - Low sunk cost
   → Fail fast if needed

6. ✅ HIGH MARGINS
   - 94% gross margin at scale
   - Break-even at 7 customers
   - $2K MRR = $1,880 profit
   → Profitable quickly

7. ✅ GAP IN MARKET
   - GummySearch shut down (Dec 2025)
   - No clear winner emerged
   - Users actively looking for alternative
   → Window of opportunity

8. ✅ ALIGNS WITH TRENDS
   - AI-powered filtering (not just alerts)
   - Actionable intelligence (not just data)
   - Indie hacker movement growing
   → Right time
```

### ❌ Reasons NOT to Build

```
1. ❌ CROWDED MARKET
   - 100+ competitors exist
   - New tools launching every month
   → Hard to stand out
   
2. ❌ API RISK
   - Reddit might close API access
   - Happened to GummySearch
   → Product could break overnight
   
3. ❌ HARD TO DIFFERENTIATE
   - Need strong marketing
   - Positioning must be perfect
   → Execution-dependent
   
4. ❌ CHICKEN-EGG
   - Need users to train AI
   - Need good AI to get users
   → Bootstrapping challenge
   
5. ❌ NOT RECURRING (for users)
   - Users need it for 2-3 months (launch period)
   - Then churn (expected)
   → Low LTV unless reactivation works
   
6. ❌ HIGH SUPPORT NEEDS
   - Onboarding requires hand-holding
   - AI tuning needs human oversight
   → Time-intensive

7. ❌ PLATFORM DEPENDENCY
   - Entire value depends on Reddit/HN
   - If platforms change, product dies
   → Single point of failure
```

### 🎯 Final Recommendation

**Rating: ⭐⭐⭐⭐ (4/5) - RECOMMENDED WITH CONDITIONS**

#### Why This Scores High:

```
✅ Evidence-based need (not speculation)
✅ Willingness to pay validated
✅ Clear differentiation possible
✅ Solo feasible in 3 weeks
✅ Fast validation (2-4 weeks)
✅ High margins (94%)
✅ Low risk to try ($0 if DIY)
```

#### Why Not 5/5:

```
⚠️ Crowded market requires execution
⚠️ Platform risk (Reddit API)
⚠️ Expected churn (launch tool)
⚠️ Needs strong marketing
```

#### Compared to Email Temperature Detection:

```
Email Temp Detection: ⭐⭐⭐ (3/5)
- Weaker evidence
- Not clear if people need tool vs advice
- More speculative

Customer Finder: ⭐⭐⭐⭐ (4/5)
- Strong evidence (100+ discussions)
- People already paying competitors
- Clear problem statement
- Proven market
```

### 📋 Action Plan

#### Recommended Path:

```
✅ PHASE 1: Pre-Build Validation (2 weeks)
   Week 1: Problem validation
   - Reddit/IH posts
   - 1-1 interviews
   - Confirm pain is real
   
   Week 2: WTP validation
   - Build landing page
   - Get 20+ email signups
   - Validate $29 price point
   
   Decision Point #1:
   IF >20 signups → Continue
   IF <10 signups → Kill or pivot

✅ PHASE 2: Build MVP (3 weeks)
   Build full MVP per timeline
   
   Decision Point #2:
   Ship MVP to beta

✅ PHASE 3: Beta Launch (4 weeks)
   Week 1: 10 users
   Week 2-3: Iterate
   Week 4: 50 users
   
   Decision Point #3:
   IF >50 paying users & <10% churn → Scale
   IF 20-50 users & learning → Iterate
   IF <20 users or >30% churn → Kill

✅ PHASE 4: Scale (Ongoing)
   Target: $2K MRR in 2 months (70 users)
   Then: $10K MRR in 6 months (350 users)
```

#### Recommended Timeline:

```
Week -2 to 0: Validation (do NOT skip!)
Week 1-3: Build MVP
Week 4: Beta launch (10 users)
Week 5-6: Iterate
Week 7-8: Expand (50 users)
Month 3: Scale to $2K MRR
Month 6: Scale to $10K MRR or pivot

Total time to know if it works: 8 weeks
Total investment: 120 hours + $200
```

#### Success Metrics:

```
Week 2 (validation): 20+ email signups
Week 4 (beta): 10 paying users
Week 8 (expand): 50 paying users
Month 3: $2K MRR (70 users)
Month 6: $10K MRR (350 users)

Churn target: <15%/month
NPS target: >40
```

#### Budget Required:

```
Development: $0 (DIY) or $3K-4K (outsource)
Operating (first 3 months): ~$500
Marketing: $0 (organic only)
Buffer: $500

Total: $1,000-$5,000 depending on DIY vs hire
```

---

## 附录

### A. 竞品详细列表

*(Covered extensively in Section 2)*

### B. 技术参考

**Useful APIs:**
- Reddit API: https://www.reddit.com/dev/api
- HN API: https://github.com/HackerNews/API
- OpenAI API: https://platform.openai.com/docs

**Similar Open Source Projects:**
- F5Bot source (inspiration): Not available
- Reddit search tools: Various on GitHub

### C. 相关资源

**学习资源:**
- "How to Find Customers on Reddit" - Multiple guides
- Indie Hackers case studies
- GummySearch post-mortem (if available)

**社区:**
- r/SideProject
- r/Entrepreneur
- Indie Hackers forum
- Twitter #buildinpublic

### D. 模板

**Landing Page Copy Template:**
*(Included in Section 4.2)*

**Email Templates:**
- Onboarding sequence
- Daily digest
- Churn prevention

**Survey Questions:**
- User feedback
- NPS survey
- Feature requests

---

## 变更日志

| 日期 | 版本 | 变更内容 |
|------|------|----------|
| 2026-02-12 | 1.0 | 初始版本 - 完整分析文档 |

---

## 联系方式

如果你基于这个分析开始build，欢迎分享进展！

---

**END OF DOCUMENT**

Total: ~25,000 words
Reading time: ~100 minutes

## Sprint Summary

_Last updated: 2026-03-25_

Week 6 _(current)_ · 2026-03-23 to 2026-03-29
Status: ❌ Stalled
Active days: 1 / 7
Total commits: 10

Week 5 · 2026-03-16 to 2026-03-22
Status: ❌ Stalled
Active days: 1 / 7
Total commits: 2

Week 4 · 2026-03-09 to 2026-03-15
Status: ❌ Stalled
Active days: 0 / 7
Total commits: 0

Week 3 · 2026-03-02 to 2026-03-08
Status: ❌ Stalled
Active days: 0 / 7
Total commits: 0

Week 2 · 2026-02-23 to 2026-03-01
Status: ⚠️ Slow
Active days: 3 / 7
Total commits: 31

Week 1 · 2026-02-16 to 2026-02-22
Status: ⚠️ Slow
Active days: 3 / 7
Total commits: 7
