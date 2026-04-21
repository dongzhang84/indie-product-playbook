# GrowPilot — Implementation Guide

**Product**: GrowPilot  
**Tagline**: Get customers. Automatically.  
**Model**: Weekly SEO content generation + auto-publishing  
**Pricing**: $29/mo founding, $49/mo after launch  
**Stack**: Follow STANDARD.md — Next.js 14, Supabase, Prisma, Stripe (Subscription), Resend, Vercel  
**Repo**: github.com/[your-username]/growpilot (private)  
**Last Updated**: March 2026

---

## ⚠️ Golden Rule

> **山寨优先。** 每一个功能决策先问：GoShipFast 是怎么做的？按他的做。不要发明新功能。

Reference: https://goshipfast.com

---

## Phase 0 — 项目初始化（Day 1 第一件事）

按 STANDARD.md Section 11 Checklist 操作，以下是 GrowPilot 的定制部分：

```bash
npx create-next-app@latest growpilot --typescript --tailwind --app
cd growpilot
npx shadcn@latest init
npm install @supabase/supabase-js @supabase/ssr stripe resend \
  @react-email/components react-email nanoid
```

**Stripe 模式**：选 **模式 B（Subscription）**，见 STANDARD.md Section 6。

**Build Command（Vercel）**：
```
npx prisma generate && next build
```

**环境变量**（按 STANDARD.md Section 5.1，GrowPilot 额外需要）：
```bash
OPENAI_API_KEY=
CRON_SECRET=          # openssl rand -base64 32
TWITTER_API_KEY=      # V1 再填
TWITTER_API_SECRET=   # V1 再填
```

---

## Phase 1 — Landing Page（Day 1 核心任务）

> **Landing page 决定能不能收到钱。先做这个，其他一切都排后面。**
> 
> 完全对照 goshipfast.com 结构，文案重写，UI 不同即可。

### 文件位置
```
app/page.tsx
```

### 页面完整结构

---

#### Section 1: Nav

```
[GrowPilot logo]                    [Founding Offer]  [Login]  [Get started — $29/mo →]
```

- Logo 左上角，纯文字即可（GrowPilot）
- "Founding Offer" anchor link → #founding
- "Get started — $29/mo" → 未登录跳 `/auth/register`，已登录直接触发 Stripe Checkout，高亮按钮

---

#### Section 2: Hero

```
Autopilot growth

Get customers. Automatically.

You don't do SEO.
You don't write content.
You don't manage distribution.
You just get users.

[Get started — $29/mo →]

Founding member pricing — $29/mo, locked in forever.
Goes to $49 after launch.

SEO, content, distribution, and tracking — done for you.
```

**实现细节**：
- 背景白色，字体黑色，干净极简（照 goshipfast.com）
- CTA 按钮逻辑：
  ```
  未登录 → /auth/register（注册成功后自动跳 Stripe Checkout）
  已登录未付费 → POST /api/stripe/checkout（直接开 Checkout）
  已登录已付费 → /dashboard
  ```
- 按钮文案：`Get started — $29/mo`

---

#### Section 3: Dashboard Preview（本周数据卡片）

```
This week

┌─────────────────────────────────────────────────────┐
│  GrowPilot dashboard                                 │
│  Founding preview                                    │
│                                                      │
│  Keywords found    Content ready    Posts scheduled  Signups tracked │
│  this week         this week                                          │
│                                                      │
│  48                12               8                31               │
│  14 high-intent    Blog posts and   Published        Clear            │
│  opportunities     social drafts    across blog,     attribution to   │
│                    queued           X, and LinkedIn   what converted  │
└─────────────────────────────────────────────────────┘
```

**实现细节**：
- 用 Shadcn Card 组件做这个预览框
- 四个数字（48 / 12 / 8 / 31）写死，视觉展示用
- 整体有轻微边框 + shadow，像一个真实的 dashboard 截图

---

#### Section 4: What you get every week

```
What you get every week

✓  Buyer keywords to target
✓  Content ready to publish  
✓  More traffic and signups
✓  Less manual work
```

简单四行，带 checkmark，左对齐。

---

#### Section 5: Built for

```
Built for

People who need users, not more SEO chores

[SaaS founders]  [Indie hackers]  [Small teams]  [Growth-focused teams]
```

四个 tag / badge，横排。

---

#### Section 6: How it works（四步）

```
How it works

From buyer keywords to signups

1  We find buyer keywords
   Not random traffic keywords.

2  We create content around them
   Blog posts, social posts, and landing pages.

3  We publish across your channels
   So you stay visible without doing the work.

4  We track what brings users
   Traffic, signups, and real results.
```

数字 1-4 大字，每步两行文字，纵向排列。

---

#### Section 7: Why this is different

```
SEO takes too long.
Content takes too much time.
Most teams never stay consistent.

Other tools give you ideas. This one does the work.

We don't stop at keyword suggestions. We turn them into content,
distribute it, and show you what actually converts.
```

---

#### Section 8: Founding Offer（id="founding"）

```
Become a founding member

Future users will pay more. Founding members won't.

┌──────────────────────────────┐
│  BEST PRICE YOU'LL EVER GET  │
│                              │
│  ✓ Lifetime discount         │
│  ✓ Priority access           │
│  ✓ Better pricing than       │
│    future users              │
│  ✓ Direct input on product   │
│    direction                 │
│                              │
│  [Get started — $29/mo →]    │
└──────────────────────────────┘

Limited founding spots. Get in early. Pay less forever.
Founding pricing ends when spots fill up.

[Get started — $29/mo →]
```

**实现细节**：
- 卡片用 border + 深色背景（参考 goshipfast.com 的黑色卡片）
- 两个 CTA 按钮逻辑同 Hero：未登录 → `/auth/register`，已登录未付费 → Stripe Checkout

---

#### Section 9: Footer

```
Stop doing SEO by hand.
Start getting users on autopilot.

[Get started — $29/mo →]
Limited founding spots. Founder pricing ends when spots fill up.

GrowPilot    [Login]
```

---

### CTA 按钮组件（复用于整个 landing page）

```typescript
// components/CTAButton.tsx
'use client'
import { useRouter } from 'next/navigation'

export function CTAButton() {
  const router = useRouter()

  async function handleClick() {
    // 检查是否已登录
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) {
      // 未登录 → 注册页，注册成功后自动跳 Stripe
      router.push('/auth/register?next=checkout')
      return
    }

    // 已登录 → 直接触发 Stripe Checkout
    const res = await fetch('/api/stripe/checkout', { method: 'POST' })
    const { url } = await res.json()
    window.location.href = url
  }

  return (
    <button onClick={handleClick}>
      Get started — $29/mo →
    </button>
  )
}
```

注册成功后，检查 `?next=checkout` 参数，自动触发 Stripe Checkout：
```typescript
// app/auth/register/page.tsx 注册成功后
const next = searchParams.get('next')
if (next === 'checkout') {
  const res = await fetch('/api/stripe/checkout', { method: 'POST' })
  const { url } = await res.json()
  window.location.href = url
} else {
  router.push('/dashboard')
}
```

---

## Phase 2 — 数据库 Schema

> 使用 STANDARD.md Section 4.6 **Supabase-only 方案**（不用 Prisma）。
> 直接在 Supabase SQL Editor 里跑以下 SQL。

```sql
-- =====================
-- Core Tables
-- =====================

-- Profiles (extends Supabase auth.users)
CREATE TABLE profiles (
  id            TEXT PRIMARY KEY,  -- = auth.users.id
  email         TEXT NOT NULL UNIQUE,
  plan          TEXT NOT NULL DEFAULT 'free'
                  CHECK (plan IN ('free', 'founding', 'pro')),
  stripe_id     TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Products (one per user)
CREATE TABLE products (
  id               TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  user_id          TEXT NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name             TEXT NOT NULL,
  description      TEXT NOT NULL,
  url              TEXT NOT NULL,
  target_audience  TEXT NOT NULL,
  differentiator   TEXT NOT NULL,
  seed_keywords    TEXT[] DEFAULT '{}',
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Keywords (generated weekly per user)
CREATE TABLE keywords (
  id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  user_id     TEXT NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  keyword     TEXT NOT NULL,
  intent      TEXT NOT NULL CHECK (intent IN ('buyer', 'informational', 'navigational')),
  priority    TEXT NOT NULL CHECK (priority IN ('high', 'medium', 'low')),
  week_of     DATE NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Content (blog posts + social drafts)
CREATE TABLE content (
  id            TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  user_id       TEXT NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  keyword_id    TEXT REFERENCES keywords(id) ON DELETE SET NULL,
  type          TEXT NOT NULL CHECK (type IN ('blog', 'tweet', 'linkedin')),
  title         TEXT,
  body          TEXT NOT NULL,
  status        TEXT NOT NULL DEFAULT 'draft'
                  CHECK (status IN ('draft', 'approved', 'published')),
  utm_code      TEXT UNIQUE,
  published_at  TIMESTAMPTZ,
  week_of       DATE NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Conversion tracking
CREATE TABLE conversions (
  id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  content_id  TEXT NOT NULL REFERENCES content(id) ON DELETE CASCADE,
  type        TEXT NOT NULL CHECK (type IN ('click', 'signup', 'paid')),
  ip_hash     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================
-- Indexes
-- =====================
CREATE INDEX idx_keywords_user_week   ON keywords(user_id, week_of);
CREATE INDEX idx_content_user_week    ON content(user_id, week_of);
CREATE INDEX idx_content_utm          ON content(utm_code);
CREATE INDEX idx_content_status       ON content(user_id, status);
CREATE INDEX idx_conversions_content  ON conversions(content_id);

-- =====================
-- Enable RLS on all tables
-- =====================
ALTER TABLE profiles   ENABLE ROW LEVEL SECURITY;
ALTER TABLE products   ENABLE ROW LEVEL SECURITY;
ALTER TABLE keywords   ENABLE ROW LEVEL SECURITY;
ALTER TABLE content    ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversions ENABLE ROW LEVEL SECURITY;

-- =====================
-- profiles: 只能读写自己的行
-- =====================
CREATE POLICY "profiles: select own" ON profiles
  FOR SELECT USING (auth.uid()::TEXT = id);

CREATE POLICY "profiles: insert own" ON profiles
  FOR INSERT WITH CHECK (auth.uid()::TEXT = id);

CREATE POLICY "profiles: update own" ON profiles
  FOR UPDATE USING (auth.uid()::TEXT = id);

-- =====================
-- products: 只能读写自己的产品
-- =====================
CREATE POLICY "products: select own" ON products
  FOR SELECT USING (auth.uid()::TEXT = user_id);

CREATE POLICY "products: insert own" ON products
  FOR INSERT WITH CHECK (auth.uid()::TEXT = user_id);

CREATE POLICY "products: update own" ON products
  FOR UPDATE USING (auth.uid()::TEXT = user_id);

CREATE POLICY "products: delete own" ON products
  FOR DELETE USING (auth.uid()::TEXT = user_id);

-- =====================
-- keywords: 只能读写自己的关键词
-- =====================
CREATE POLICY "keywords: select own" ON keywords
  FOR SELECT USING (auth.uid()::TEXT = user_id);

CREATE POLICY "keywords: insert own" ON keywords
  FOR INSERT WITH CHECK (auth.uid()::TEXT = user_id);

CREATE POLICY "keywords: delete own" ON keywords
  FOR DELETE USING (auth.uid()::TEXT = user_id);

-- =====================
-- content: 只能读写自己的内容
-- =====================
CREATE POLICY "content: select own" ON content
  FOR SELECT USING (auth.uid()::TEXT = user_id);

CREATE POLICY "content: insert own" ON content
  FOR INSERT WITH CHECK (auth.uid()::TEXT = user_id);

CREATE POLICY "content: update own" ON content
  FOR UPDATE USING (auth.uid()::TEXT = user_id);

CREATE POLICY "content: delete own" ON content
  FOR DELETE USING (auth.uid()::TEXT = user_id);

-- =====================
-- conversions: 通过 content 关联验证所有权
-- =====================
CREATE POLICY "conversions: select own" ON conversions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM content
      WHERE content.id = conversions.content_id
      AND content.user_id = auth.uid()::TEXT
    )
  );

CREATE POLICY "conversions: insert" ON conversions
  FOR INSERT WITH CHECK (true);
  -- 任何人可以插入（点击追踪不需要登录）

-- =====================
-- service_role 绕过 RLS（给 server-side cron 用）
-- =====================
-- supabaseAdmin 用 service_role key，自动绕过所有 RLS
-- 不需要额外配置, we need RLS and restricted tables.
```

---

## Phase 3 — Auth（按 STANDARD.md 原样复制）

按 STANDARD.md Section 3 完整实现：

- `lib/supabase/client.ts` — 原样复制
- `lib/supabase/server.ts` — 原样复制
- `lib/supabase/admin.ts` — 原样复制
- `app/auth/login/page.tsx` — Email + Google + GitHub
- `app/auth/register/page.tsx`
- `app/auth/callback/route.ts`
- `middleware.ts`

**Protected routes for GrowPilot**：
```typescript
const PROTECTED_ROUTES = ['/dashboard', '/onboarding', '/settings']
```

**Register 成功后**：
```typescript
// 创建 profile 后，判断跳转
// 如果有 product → /dashboard
// 如果没有 product → /onboarding
```

---

## Phase 4 — Stripe（Subscription 模式）

按 STANDARD.md Section 6 模式 B 原样复制。

**GrowPilot 定制部分**：

```typescript
// app/api/stripe/checkout/route.ts
// 价格：$29/mo founding

// webhook 成功后：
await supabaseAdmin.from('profiles').update({
  plan: 'founding',
  stripe_id: session.customer as string,
}).eq('id', session.metadata!.profileId)

// 然后 redirect 到 /onboarding（如果没填产品信息）
// 或 redirect 到 /dashboard
```

**Stripe Dashboard 设置**：
1. 创建产品 "GrowPilot Founding"
2. 价格：$29/mo，recurring，monthly
3. 复制 Price ID → `STRIPE_PRICE_ID`
4. Webhook → `checkout.session.completed` + `customer.subscription.deleted`

---

## Phase 5 — Onboarding

**文件**：`app/onboarding/page.tsx`

付费成功后第一次进入的表单，用户填写产品信息。

```
Tell us about your product

Product name *
[                              ]

Product URL *
[  https://                    ]

Describe your product in one sentence *
[                              ]
(This is used to generate content. Be specific.)

Who is your target customer? *
[                              ]
(e.g. "SaaS founders who struggle with churn")

What makes you different from competitors? *
[                              ]

Keywords you already know work (optional)
[                              ]
(Comma separated)

[Save and continue →]
```

**API**：`POST /api/onboarding`

```typescript
export async function POST(request: Request) {
  // 1. 验证 session（必须）
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return new Response('Unauthorized', { status: 401 })

  // 2. 解析 body
  const { name, url, description, targetAudience, differentiator, seedKeywords } = await request.json()

  // 3. upsert product（用 upsert 防止重复）
  await supabaseAdmin.from('products').upsert({
    user_id: user.id,
    name, url, description,
    target_audience: targetAudience,
    differentiator,
    seed_keywords: seedKeywords ? seedKeywords.split(',').map((k: string) => k.trim()) : [],
    updated_at: new Date().toISOString(),
  }, { onConflict: 'user_id' })

  return Response.json({ success: true })
}
```

成功后 redirect → `/dashboard`

---

## Phase 6 — 核心引擎

### 6.1 关键词引擎

**文件**：`lib/keywords/generate.ts`

```typescript
import OpenAI from 'openai'

const openai = new OpenAI()

// Step 1: 爬取 Google Autocomplete
async function getAutocompleteSuggestions(query: string): Promise<string[]> {
  const url = `https://suggestqueries.google.com/complete/search?client=firefox&q=${encodeURIComponent(query)}&hl=en`
  const res = await fetch(url, {
    headers: { 'User-Agent': 'Mozilla/5.0' }
  })
  const data = await res.json()
  return data[1] as string[]
}

// Step 2: 用产品描述生成种子词变体，爬取自动完成
export async function fetchRawKeywords(product: {
  name: string
  description: string
  targetAudience: string
  seedKeywords: string[]
}): Promise<string[]> {
  const prefixes = [
    'best', 'how to', 'tool for', 'software for',
    'alternative to', 'vs', 'app for', 'cheap',
    'free', 'top', 'easy'
  ]

  // 核心种子词
  const seeds = [
    product.name.toLowerCase(),
    ...product.seedKeywords,
    // GPT 先生成 5 个核心词
  ]

  const allKeywords = new Set<string>()

  for (const seed of seeds.slice(0, 3)) {
    for (const prefix of prefixes) {
      const suggestions = await getAutocompleteSuggestions(`${prefix} ${seed}`)
      suggestions.forEach(s => allKeywords.add(s))
    }
  }

  return Array.from(allKeywords)
}

// Step 3: GPT 过滤意图 + 优先级
export async function analyzeKeywordIntent(
  keywords: string[],
  product: { name: string; description: string; targetAudience: string }
): Promise<Array<{ keyword: string; intent: string; priority: string }>> {
  const prompt = `You are an SEO expert.

Product: ${product.name} — ${product.description}
Target customer: ${product.targetAudience}

Classify each keyword by search intent:
- buyer: user is ready to buy or compare products
- informational: user is learning about a topic
- navigational: user is looking for a specific brand

Rate priority (high/medium/low) based on relevance to this specific product.
Focus on keywords that would bring paying customers.

Keywords:
${keywords.slice(0, 80).join('\n')}

Return JSON array only, no other text:
[{"keyword":"...","intent":"buyer","priority":"high"}]`

  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [{ role: 'user', content: prompt }],
    response_format: { type: 'json_object' },
  })

  const result = JSON.parse(response.choices[0].message.content!)
  // 取 top 48，buyer/high 优先
  return result.keywords
    .sort((a: any, b: any) => {
      const priorityScore = { high: 3, medium: 2, low: 1 }
      const intentScore = { buyer: 3, informational: 2, navigational: 1 }
      return (priorityScore[b.priority as keyof typeof priorityScore] + intentScore[b.intent as keyof typeof intentScore])
           - (priorityScore[a.priority as keyof typeof priorityScore] + intentScore[a.intent as keyof typeof intentScore])
    })
    .slice(0, 48)
}
```

---

### 6.2 内容生成引擎

**文件**：`lib/content/generate.ts`

```typescript
// 生成博客文章（每个关键词一篇）
export async function generateBlogPost(
  keyword: string,
  product: { name: string; description: string; targetAudience: string; differentiator: string }
): Promise<{ title: string; body: string }> {
  const prompt = `You are a content marketer writing SEO blog posts for a software product.

Product: ${product.name}
Description: ${product.description}
Target customer: ${product.targetAudience}
Differentiator: ${product.differentiator}
Target keyword: "${keyword}"

Write an 800-word SEO blog post:
- Title must include the keyword naturally
- Open with a relatable problem the reader faces
- Provide 3-5 actionable tips or insights
- End with a soft, natural mention of the product as one solution
- No fluff, no keyword stuffing
- Write like a smart human, not a marketing bot
- Use short paragraphs

Output JSON only:
{"title": "...", "body": "full article text here"}`

  const response = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [{ role: 'user', content: prompt }],
    response_format: { type: 'json_object' },
  })

  return JSON.parse(response.choices[0].message.content!)
}

// 生成社交帖子（X + LinkedIn 草稿）
export async function generateSocialPosts(
  blogTitle: string,
  blogBody: string,
  keyword: string
): Promise<{ tweet1: string; tweet2: string; linkedin: string }> {
  const prompt = `Based on this blog post, write social media content.

Blog title: ${blogTitle}
Keyword: ${keyword}
Blog excerpt: ${blogBody.slice(0, 500)}

Write:
1. tweet1 (under 260 chars): data-driven angle, ends with "{LINK}"
2. tweet2 (under 260 chars): pain point angle, ends with "{LINK}"
3. linkedin (150-200 words): professional tone, hook opening,
   ends with a question to drive comments, includes "{LINK}"

Output JSON only:
{"tweet1":"...","tweet2":"...","linkedin":"..."}`

  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [{ role: 'user', content: prompt }],
    response_format: { type: 'json_object' },
  })

  return JSON.parse(response.choices[0].message.content!)
}
```

---

### 6.3 Weekly Cron 主流程

**文件**：`app/api/cron/weekly/route.ts`

```typescript
import { NextRequest } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase/admin'
import { fetchRawKeywords, analyzeKeywordIntent } from '@/lib/keywords/generate'
import { generateBlogPost, generateSocialPosts } from '@/lib/content/generate'
import { nanoid } from 'nanoid'

export async function GET(request: NextRequest) {
  // 1. 验证 cron secret
  const authHeader = request.headers.get('authorization')
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return new Response('Unauthorized', { status: 401 })
  }

  const weekOf = new Date().toISOString().split('T')[0] // YYYY-MM-DD

  // 2. 取所有付费用户
  const { data: paidUsers } = await supabaseAdmin
    .from('profiles')
    .select('id, email')
    .in('plan', ['founding', 'pro'])

  if (!paidUsers?.length) return Response.json({ message: 'No paid users' })

  // 3. 对每个用户跑完整流程
  for (const user of paidUsers) {
    try {
      // 3a. 取产品信息
      const { data: product } = await supabaseAdmin
        .from('products')
        .select('*')
        .eq('user_id', user.id)
        .single()

      if (!product) continue

      // 3b. 生成关键词
      const rawKeywords = await fetchRawKeywords({
        name: product.name,
        description: product.description,
        targetAudience: product.target_audience,
        seedKeywords: product.seed_keywords || [],
      })

      const analyzedKeywords = await analyzeKeywordIntent(rawKeywords, {
        name: product.name,
        description: product.description,
        targetAudience: product.target_audience,
      })

      // 3c. 存入 keywords 表
      const keywordRows = analyzedKeywords.map(k => ({
        user_id: user.id,
        keyword: k.keyword,
        intent: k.intent,
        priority: k.priority,
        week_of: weekOf,
      }))

      const { data: savedKeywords } = await supabaseAdmin
        .from('keywords')
        .insert(keywordRows)
        .select()

      // 3d. 取 top 12 生成内容（buyer + high/medium 优先）
      const topKeywords = (savedKeywords || [])
        .filter(k => k.intent === 'buyer' || k.priority === 'high')
        .slice(0, 12)

      // 3e. 生成博客 + 社交帖子
      for (const kw of topKeywords) {
        // 博客
        const blog = await generateBlogPost(kw.keyword, {
          name: product.name,
          description: product.description,
          targetAudience: product.target_audience,
          differentiator: product.differentiator,
        })

        const { data: blogRow } = await supabaseAdmin
          .from('content')
          .insert({
            user_id: user.id,
            keyword_id: kw.id,
            type: 'blog',
            title: blog.title,
            body: blog.body,
            status: 'draft',
            utm_code: nanoid(8),
            week_of: weekOf,
          })
          .select()
          .single()

        // 社交帖子（tweet + linkedin）
        const social = await generateSocialPosts(blog.title, blog.body, kw.keyword)

        await supabaseAdmin.from('content').insert([
          {
            user_id: user.id,
            keyword_id: kw.id,
            type: 'tweet',
            body: `${social.tweet1}\n\n${social.tweet2}`,
            status: 'draft',
            utm_code: nanoid(8),
            week_of: weekOf,
          },
          {
            user_id: user.id,
            keyword_id: kw.id,
            type: 'linkedin',
            body: social.linkedin,
            status: 'draft',
            utm_code: nanoid(8),
            week_of: weekOf,
          }
        ])
      }

      // 3f. 发每周邮件通知
      await sendWeeklyDigestEmail(user.email, product.name, analyzedKeywords.length)

    } catch (err) {
      console.error(`Failed for user ${user.id}:`, err)
      // 单个用户失败不影响其他用户
      continue
    }
  }

  return Response.json({ success: true, processed: paidUsers.length })
}
```

---

### 6.4 Vercel Cron 配置

```json
// vercel.json
{
  "crons": [
    {
      "path": "/api/cron/weekly",
      "schedule": "0 9 * * 1"
    }
  ]
}
```

每周一 9am UTC 自动触发。Vercel Hobby plan 支持每日一次，每周一次完全在免费范围内。

---

## Phase 7 — 用户仪表盘

### 文件结构

```
app/dashboard/
  page.tsx               ← 主概览
  keywords/page.tsx      ← 本周关键词列表
  content/page.tsx       ← 内容草稿列表
  content/[id]/page.tsx  ← 单篇内容详情
  analytics/page.tsx     ← 转化数据
```

### Dashboard 主页展示

```
This week                                    [Week of Mar 24]

┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│    48    │ │    12    │ │    8     │ │    31    │
│ Keywords │ │ Content  │ │  Posts   │ │ Signups  │
│  found   │ │  ready   │ │scheduled │ │ tracked  │
│14 high   │ │drafts    │ │blog+X+LI │ │          │
│intent    │ │queued    │ │          │ │          │
└──────────┘ └──────────┘ └──────────┘ └──────────┘

[View keywords →]  [View content →]  [View analytics →]
```

### Content 列表页

- 可筛选：All / Blog / Tweet / LinkedIn
- 可筛选：Draft / Approved / Published
- 每行：title / keyword / type / status / [Preview] [Approve]

### Content 详情页

```
[← Back]

"Best project management tool for indie hackers"
Keyword: best project management tool
Type: Blog post
Status: Draft

─────────────────────────────────────────────

[Full blog content rendered here]

─────────────────────────────────────────────

Social posts:

Tweet 1: [tweet text with {LINK} placeholder]
Tweet 2: [tweet text with {LINK} placeholder]
LinkedIn: [linkedin text]

─────────────────────────────────────────────

[Approve and schedule →]  [Edit]  [Delete]
```

### Approve API

```typescript
// app/api/content/[id]/approve/route.ts
export async function POST(request: Request, { params }: { params: { id: string } }) {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return new Response('Unauthorized', { status: 401 })

  // 确认这条内容属于这个用户
  const { data: content } = await supabaseAdmin
    .from('content')
    .select('user_id')
    .eq('id', params.id)
    .single()

  if (content?.user_id !== user.id) return new Response('Forbidden', { status: 403 })

  await supabaseAdmin
    .from('content')
    .update({ status: 'approved' })
    .eq('id', params.id)

  return Response.json({ success: true })
}
```

---

## Phase 8 — UTM 追踪

**文件**：`app/api/track/[utmCode]/route.ts`

```typescript
export async function GET(request: Request, { params }: { params: { utmCode: string } }) {
  // 1. 找到对应内容
  const { data: content } = await supabaseAdmin
    .from('content')
    .select('id, user_id')
    .eq('utm_code', params.utmCode)
    .single()

  if (!content) return new Response('Not found', { status: 404 })

  // 2. 记录点击（IP hash 匿名化）
  const ip = request.headers.get('x-forwarded-for') || 'unknown'
  const ipHash = Buffer.from(ip).toString('base64').slice(0, 16)

  await supabaseAdmin.from('conversions').insert({
    content_id: content.id,
    type: 'click',
    ip_hash: ipHash,
  })

  // 3. 取用户的产品 URL，拼 UTM 参数，重定向
  const { data: product } = await supabaseAdmin
    .from('products')
    .select('url')
    .eq('user_id', content.user_id)
    .single()

  const targetUrl = `${product!.url}?utm_source=growpilot&utm_medium=content&utm_campaign=${params.utmCode}`

  return Response.redirect(targetUrl, 302)
}
```

---

## Phase 9 — 邮件

### 每周 Digest 邮件

**文件**：`lib/email/weekly-digest.tsx`

```typescript
import { Html, Text, Button, Hr } from '@react-email/components'

export function WeeklyDigestEmail({
  productName,
  keywordCount,
  highIntentCount,
  dashboardUrl,
}: {
  productName: string
  keywordCount: number
  highIntentCount: number
  dashboardUrl: string
}) {
  return (
    <Html>
      <Text>Your weekly content for {productName} is ready.</Text>
      <Text>
        This week: {keywordCount} keywords ({highIntentCount} high-intent),
        12 blog drafts, and social posts queued.
      </Text>
      <Button href={dashboardUrl}>Review and approve →</Button>
      <Hr />
      <Text style={{ fontSize: 12, color: '#999' }}>
        GrowPilot · Unsubscribe
      </Text>
    </Html>
  )
}
```

**发送函数调用**：
```typescript
async function sendWeeklyDigestEmail(email: string, productName: string, keywordCount: number) {
  await sendEmail({
    to: email,
    subject: `Your weekly content is ready — ${productName}`,
    react: WeeklyDigestEmail({
      productName,
      keywordCount,
      highIntentCount: Math.round(keywordCount * 0.29), // ~14 of 48
      dashboardUrl: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard/content`,
    }),
  })
}
```

---

## Phase 10 — Publishing（V1，MVP 之后）

> MVP 阶段先跳过，只输出草稿。用户手动发布。
> V1 再做 X 自动发布。

**当 V1 做时**：
- Twitter API Basic：$100/mo
- `lib/publisher/twitter.ts` — 调用 Twitter v2 API 发推
- LinkedIn：只输出草稿，用户自己发（LinkedIn API 申请周期长，不做自动发布）

---

## 七天日程

| Day | 任务 | 完成标志 |
|-----|------|----------|
| **Day 1** | Phase 0 初始化 + Phase 1 Landing Page | 落地页上线，Stripe 测试支付成功 |
| **Day 2** | Phase 2 数据库 + Phase 3 Auth | 能注册登录，profile 创建成功 |
| **Day 3** | Phase 4 Stripe + Phase 5 Onboarding | 付费后能填产品信息 |
| **Day 4** | Phase 6.1 关键词引擎 | 输入产品信息，能生成 48 个关键词 |
| **Day 5** | Phase 6.2 内容生成引擎 | 能生成 12 篇博客 + 社交草稿 |
| **Day 6** | Phase 7 仪表盘 + Phase 6.3 Cron | 用户能看到本周内容，Cron 跑通 |
| **Day 7** | Phase 8 UTM 追踪 + Phase 9 邮件 + 收尾 | 全流程端到端跑通，发布上线 |

---

## 常见坑（继承 STANDARD.md + GrowPilot 专属）

| 坑 | 解法 |
|----|------|
| Stripe webhook 签名验证失败 | 用 `request.text()` 不是 `request.json()` |
| Vercel → Supabase 超时 | 用 Transaction Pooler port 6543 |
| Google Autocomplete 被 block | 加 User-Agent header，限制请求频率（每次间隔 200ms）|
| OpenAI JSON 解析失败 | 用 `response_format: { type: 'json_object' }` |
| Cron 在 preview deployment 不跑 | Vercel Cron 只在 production 跑 |
| 单用户内容生成超时 | Vercel function timeout 默认 10s，改为 60s：`export const maxDuration = 60` |

---

## 环境变量完整清单

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Stripe
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PRICE_ID=               # $29/mo founding price

# App
NEXT_PUBLIC_APP_URL=https://growpilot.app

# OpenAI
OPENAI_API_KEY=

# Email
RESEND_API_KEY=
RESEND_FROM_EMAIL=noreply@growpilot.app

# Cron
CRON_SECRET=                   # openssl rand -base64 32

# Twitter (V1 — 先不填)
TWITTER_API_KEY=
TWITTER_API_SECRET=
TWITTER_ACCESS_TOKEN=
TWITTER_ACCESS_SECRET=
```

---

*GrowPilot Implementation Guide v1.1 — March 2026 (no waitlist, direct Stripe checkout)*
