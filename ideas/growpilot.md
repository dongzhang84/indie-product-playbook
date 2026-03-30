# GrowPilot — 一周实现方案 v2

**项目代号**: GrowPilot（暂定）  
**目标**: 7天内上线可收钱的 MVP  
**Repo**: github.com/[your-username]/growpilot（private）  
**语言**: 全英文网站，面向国际用户  
**技术栈**: 全部复用 LaunchRadar 已有基础

---

## 产品定位

### 我们在卖什么

> **"You don't do SEO. You don't write content. You just get users."**

面向人群：**SaaS founders, indie hackers, small teams** — 任何有产品但没时间做内容营销的人，不限地区，英语为主。

### 核心价值主张

```
You build the product.
We handle the growth.

Every week, automatically:
- 40 buyer-intent keywords
- 10 SEO blog post drafts
- Social post drafts (X + LinkedIn)
- Conversion tracking: see what actually brings signups
```

### 定价

| Plan | Price | Notes |
|------|-------|-------|
| Founding Member | **$29 / month** | Early supporters lock in the lowest price forever |
| Future pricing | $49 / month | After public launch |

只有美元，不分国内国外，统一定价。

---

## 技术架构

### 复用 LaunchRadar 的部分

- Next.js 14 + App Router ✅
- Prisma ORM ✅
- OpenAI API ✅
- Stripe ✅
- Resend ✅
- Vercel ✅

### 新增的部分

- Twitter API Basic（$100/月）— V1 才开，MVP 先不用
- LinkedIn — 仅输出草稿，不需要 API，用户自己发
- Upstash QStash — 替代 Vercel Pro Cron（下面详述）

### 关于 Vercel Cron 替代方案

**不需要升级 Vercel Pro。** 两个免费方案：

**方案 A：GitHub Actions（推荐）**
```yaml
# .github/workflows/weekly.yml
name: Weekly Content Generation
on:
  schedule:
    - cron: '0 9 * * 1'  # 每周一 9am UTC
  workflow_dispatch:      # 也可以手动触发
jobs:
  run:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger weekly cron
        run: |
          curl -X POST https://growpilot.app/api/cron/weekly \
            -H "Authorization: Bearer ${{ secrets.CRON_SECRET }}"
```
- **完全免费**，GitHub Actions 每月 2000 分钟免费额度
- 比 Vercel Cron 更灵活，可以手动触发测试
- 只需要在 repo secrets 里加一个 `CRON_SECRET`

**方案 B：Upstash QStash**
- 免费版：500 次/天
- 适合更复杂的任务队列场景
- MVP 阶段用不上，GitHub Actions 够了

**结论：用 GitHub Actions，$0 成本。**

---

## 数据库 Schema（SQL）

直接写 SQL，restricted 权限。

```sql
-- Users
CREATE TABLE users (
  id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  email       TEXT NOT NULL UNIQUE,
  stripe_id   TEXT,
  plan        TEXT NOT NULL DEFAULT 'free', -- free | founding | pro
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Products (one per user)
CREATE TABLE products (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  user_id         TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  description     TEXT NOT NULL,
  url             TEXT NOT NULL,
  target_audience TEXT NOT NULL,
  seed_keywords   TEXT[],
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Keywords (generated weekly)
CREATE TABLE keywords (
  id         TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  keyword    TEXT NOT NULL,
  intent     TEXT NOT NULL CHECK (intent IN ('buyer', 'informational', 'navigational')),
  priority   TEXT NOT NULL CHECK (priority IN ('high', 'medium', 'low')),
  week_of    DATE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Content (blog posts + social drafts)
CREATE TABLE content (
  id           TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  user_id      TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  keyword_id   TEXT REFERENCES keywords(id) ON DELETE SET NULL,
  type         TEXT NOT NULL CHECK (type IN ('blog', 'tweet', 'linkedin')),
  title        TEXT,
  body         TEXT NOT NULL,
  status       TEXT NOT NULL DEFAULT 'draft'
                 CHECK (status IN ('draft', 'approved', 'published')),
  utm_code     TEXT UNIQUE,
  published_at TIMESTAMPTZ,
  week_of      DATE NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Conversion tracking
CREATE TABLE conversions (
  id         TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  content_id TEXT NOT NULL REFERENCES content(id) ON DELETE CASCADE,
  type       TEXT NOT NULL CHECK (type IN ('click', 'signup', 'paid')),
  ip_hash    TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Waitlist
CREATE TABLE waitlist (
  id         TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  email      TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_keywords_user_week ON keywords(user_id, week_of);
CREATE INDEX idx_content_user_week  ON content(user_id, week_of);
CREATE INDEX idx_content_utm        ON content(utm_code);
CREATE INDEX idx_conversions_content ON conversions(content_id);

-- Restricted: app user only has DML, no DDL
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
-- REVOKE CREATE ON SCHEMA public FROM app_user;
```

---

## API 路由

```
/api/auth/[...nextauth]       # Login / register
/api/waitlist                 # POST — join waitlist
/api/stripe/checkout          # POST — create checkout session
/api/stripe/webhook           # POST — payment success callback
/api/onboarding               # POST — save product info
/api/keywords/generate        # POST — trigger keyword generation
/api/content/generate         # POST — trigger content generation
/api/content/[id]/approve     # POST — user approves draft
/api/content/[id]/publish     # POST — publish to X (V1)
/api/track/[utmCode]          # GET  — click tracking redirect
/api/dashboard                # GET  — this week's summary
/api/cron/weekly              # POST — weekly automation (called by GitHub Actions)
```

---

## 页面结构

```
/                     Landing Page（最重要，全英文）
/waitlist             Join waitlist form
/login                Login
/register             Register
/onboarding           Product info form (post-payment)
/dashboard            Main user interface
  /dashboard/keywords   This week's keywords
  /dashboard/content    Content drafts (blog + social)
  /dashboard/analytics  Conversion data
```

---

## 七天执行计划

### Day 1 — Landing Page + 能收钱

**目标：落地页上线，Stripe 测试支付跑通**

Landing Page 文案结构（全英文，本土感）：

```
[Hero]
Get customers. Automatically.

You don't do SEO.
You don't write content.
You don't manage distribution.
You just get users.

→ [Join the waitlist — $29/mo founding price]

261 people already joined.

---

[Pain points]
SEO takes too long.
Content takes too much time.
Most teams never stay consistent.

---

[What you get every week]
✅ 40 buyer-intent keywords
✅ 10 SEO blog post drafts, ready to publish
✅ Social drafts for X and LinkedIn
✅ Conversion report: what actually brought signups

---

[Who it's for]
SaaS founders
Indie hackers
Small growth teams

---

[Founding offer]
$29 / month — founding member price
Locks in forever. Goes to $49 after launch.
Limited spots.

→ [Claim my spot]

---

[FAQ]
Q: Is the product ready now?
A: We're onboarding founding members now. 
   First batch gets access within 3 weeks.

Q: What channels do you publish to?
A: Blog (your domain or subdomain), X, and LinkedIn drafts.
   You approve everything before it goes live.

Q: Do I need to do anything?
A: Fill out a short form about your product. 
   We handle the rest.
```

**今天完成**：
- [ ] `app/page.tsx` — Landing page
- [ ] `app/waitlist/page.tsx`
- [ ] `app/api/waitlist/route.ts`
- [ ] `app/api/stripe/checkout/route.ts`
- [ ] `app/api/stripe/webhook/route.ts`
- [ ] Schema SQL → run on Neon
- [ ] Vercel deploy

---

### Day 2 — Auth + Onboarding

- [ ] NextAuth（email magic link）
- [ ] `/register` `/login` pages
- [ ] `/onboarding` form
- [ ] `app/api/onboarding/route.ts`
- [ ] 支付成功 → 自动跳 onboarding

**Onboarding 表单**：
```
Product name: ___
Product URL: ___
Describe your product in one sentence: ___
Who is your target customer: ___
What makes you different: ___
Any keywords you already know work (optional): ___
```

---

### Day 3 — 关键词引擎

- [ ] `lib/keywords/autocomplete.ts` — Google Autocomplete 爬虫
- [ ] `lib/keywords/analyzer.ts` — GPT 意图分析
- [ ] `app/api/keywords/generate/route.ts`
- [ ] 结果存入 `keywords` 表

**爬虫逻辑**：
```typescript
const prefixes = [
  'how to', 'best', 'alternative to', 'vs',
  'tool for', 'software for', 'app for', 'cheap'
]
// seed = 产品核心词，对每个 prefix + seed 爬 autocomplete
// 目标：拿到 60+ 原始词 → GPT 过滤到 40 个
```

**GPT Prompt（意图分析）**：
```
You are an SEO expert.

Product: {name} — {description}
Target customer: {targetAudience}

Given these keywords, classify each by search intent:
- buyer: user is ready to buy or compare products
- informational: user is learning
- navigational: user is looking for a specific brand

Also rate priority: high / medium / low based on relevance to this product.

Keywords: {keywords}

Return JSON only: [{"keyword":"...","intent":"buyer","priority":"high"}]
```

---

### Day 4 — 内容生成引擎

**输出：10 篇博客草稿 + X 草稿 + LinkedIn 草稿**

注意：LinkedIn 只输出草稿文本，用户自己去发，我们不需要 LinkedIn API。

- [ ] `lib/content/blog.ts`
- [ ] `lib/content/social.ts`（X + LinkedIn 都在这里）
- [ ] `app/api/content/generate/route.ts`
- [ ] 存入 `content` 表，status = `draft`

**博客 Prompt**：
```
You are a content marketer writing SEO blog posts for a software product.

Product: {name}
Description: {description}
Target customer: {targetAudience}
Target keyword: {keyword}

Write an 800-word blog post:
- Title must include the keyword naturally
- Open with a relatable problem the reader faces
- Provide 3-5 actionable tips or insights
- End with a soft mention of the product as one solution
- No fluff, no keyword stuffing
- Write like a smart human, not a marketing bot

Output the blog post only. No preamble.
```

**Social Prompt（X + LinkedIn 同时生成）**：
```
Based on this blog post, write:

1. A tweet (under 280 chars): data-driven angle, include {link}
2. A tweet (under 280 chars): pain point angle, include {link}  
3. A LinkedIn post (150-200 words): professional tone, 
   start with a hook, end with a question to drive comments, include {link}

Blog post: {blogContent}

Output JSON: {"tweet1":"...","tweet2":"...","linkedin":"..."}
```

---

### Day 5 — 仪表盘 + 邮件

- [ ] `app/dashboard/page.tsx` — 本周概览
- [ ] `app/dashboard/keywords/page.tsx`
- [ ] `app/dashboard/content/page.tsx` — 草稿列表（blog / tweet / linkedin 可筛选）
- [ ] `app/dashboard/content/[id]/page.tsx` — 预览 + 审核
- [ ] `lib/email/weekly-digest.ts` — 每周通知邮件
- [ ] `app/api/content/[id]/approve/route.ts`

**仪表盘数据**：
```
This week:
  Keywords found: 40 (12 high-intent)
  Content ready: 10 blog drafts + social posts
  Pending your review: 4

[View content] [View keywords] [View analytics]
```

**每周邮件**：
```
Subject: Your weekly content is ready — 10 posts waiting for review

Hey {name},

This week we generated for {productName}:
✅ 40 keywords (12 buyer-intent)
✅ 10 blog post drafts
✅ X and LinkedIn drafts for each post

Top 3 opportunities this week:
1. "{keyword1}" — buyer intent, high volume
2. "{keyword2}" — buyer intent, medium volume  
3. "{keyword3}" — informational, high volume

→ Review and approve your content
```

---

### Day 6 — UTM 追踪

X 自动发布先不做（等有付费用户再开 Twitter API）。  
这一天专注把追踪做好。

- [ ] `lib/tracker/utm.ts` — 生成唯一追踪码
- [ ] `app/api/track/[utmCode]/route.ts` — 点击记录 + 重定向
- [ ] `app/dashboard/analytics/page.tsx`

**追踪逻辑**：
```
每篇内容生成唯一 utm_code（nanoid 8位）
发布链接 = growpilot.app/track/{code}
用户点击 → 记录 conversion(type: click) → 302 redirect 到目标 URL
用户注册 → 如果 session 里有 utm_code → 记录 conversion(type: signup)
```

**Analytics 页面**：
```
This week:
  Total clicks: 234
  Signups from content: 12
  
Top performing content:
  1. "Best project tool for solo founders" — 89 clicks, 4 signups
  2. "How to reduce churn in SaaS" — 67 clicks, 3 signups
```

---

### Day 7 — GitHub Actions Cron + 上线

- [ ] `.github/workflows/weekly.yml` — 每周一触发
- [ ] `app/api/cron/weekly/route.ts` — 完整流程
- [ ] 全流程测试（自己的产品跑一遍）
- [ ] 更新 landing page 数据
- [ ] 发布

**GitHub Actions 配置**：
```yaml
name: Weekly Content Generation
on:
  schedule:
    - cron: '0 9 * * 1'
  workflow_dispatch:
jobs:
  trigger:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger weekly job
        run: |
          curl -X POST ${{ secrets.APP_URL }}/api/cron/weekly \
            -H "Authorization: Bearer ${{ secrets.CRON_SECRET }}" \
            -H "Content-Type: application/json"
```

**Cron 执行顺序**：
```
1. 查所有 plan IN ('founding', 'pro') 的用户
2. 对每个用户：
   a. 爬取 Google Autocomplete 关键词
   b. GPT 分析意图，存入 keywords 表
   c. 选 top 10 关键词生成博客
   d. 生成对应社交帖子草稿（X + LinkedIn）
   e. 存入 content 表（status: draft）
   f. 发每周邮件通知
3. 完成后发邮件给自己（运营确认）
```

---

## 获客方案（你在 Seattle，英文优先）

| 渠道 | 策略 |
|------|------|
| **Indie Hackers** | 发 Show IH 帖，讲"5天做完，第一批付费"的故事 |
| **Reddit r/SideProject** | 分享产品 + 真实数据，不硬广 |
| **Reddit r/entrepreneur** | 痛点帖："How I stopped manually doing SEO" |
| **Product Hunt** | 正式发布用，準備 upvote 群 |
| **X（推特）** | 等账号权重恢复后用，现在不是主渠道 |

**发帖公式（英文版）**：
```
[Hook]: I built a product nobody knew about for 3 months.
        Then I tried this. Here's what happened.

[Data]: 5 days to build → 3 days to market → 16 paying customers
        $29 × 16 = $464 MRR before writing a single line of "real" code

[Story]: I kept building features nobody asked for.
         The real problem was distribution, not the product.

[Product]: So I automated the part I was worst at — content and SEO.

[CTA]: If you're building something and struggling to get users,
       I'm opening 20 founding member spots at $29/mo.
       Link in comments.
```

---

## 成本估算

| 项目 | 月成本 |
|------|--------|
| Vercel Hobby | $0 |
| GitHub Actions（Cron）| $0 |
| Neon PostgreSQL（free tier）| $0 |
| OpenAI API（50 users）| ~$25 |
| Resend（free tier）| $0 |
| Twitter API（V1，先不开）| $0 |
| **总计 MVP 阶段** | **~$25/月** |

**盈亏平衡**：$29/月 × 1个用户 = 盈利。理论上第一个付费用户就回本。

---

## MVP 最小范围

**Day 1 必须有**：
- Landing page + Stripe 收钱

**内测版（Week 1 结束）必须有**：
- 用户填产品信息
- 关键词生成
- 内容生成（10 篇博客 + 社交草稿）
- 每周邮件发给用户

**V1 正式版再做**：
- X 自动发布
- UTM 追踪仪表盘
- LinkedIn API（如果申请下来）

---

*v2 更新：2026年3月30日*  
*修正：国际化定位 / 全英文 / $29定价 / SQL schema / GitHub Actions替代Vercel Cron / LinkedIn仅草稿 / 10篇博客*

## Sprint Summary

_Last updated: 2026-03-30_

Week 1 _(current)_ · 2026-03-30 to 2026-04-05
Status: ❌ Stalled
Active days: 1 / 7
Total commits: 3
