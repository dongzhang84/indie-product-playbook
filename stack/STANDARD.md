# STANDARD.md — Indie Project Standard Stack

> 这份文档是每个新项目的**唯一参照**。
> Claude 写 proposal 和实现计划时，标准模块部分严格按照此文档，不自由发挥。
> 只有业务逻辑部分（数据 schema、AI 功能、第三方 API）才做定制。

**Last Updated**: February 2026  
**Based on**: AI Video Assistant + LaunchRadar (两个已验证的项目)

📊 **所有权流程图**：[diagrams/standard-ownership-flowchart.svg](./diagrams/standard-ownership-flowchart.svg) — 从 scaffold 到 ship 的 14 步双泳道图，蓝=AI / 橙=Human / 紫=协作。一眼看清每步归属。

---

## 1. Tech Stack

| Layer | Choice | Notes |
|-------|--------|-------|
| Framework | Next.js 14 (App Router) | 不用 Pages Router |
| Language | TypeScript | strict mode |
| Styling | Tailwind CSS + Shadcn/ui | 不用 Radix 裸用 |
| Database | Supabase (PostgreSQL) | 通过 Prisma 访问 |
| ORM | Prisma v7 + @prisma/adapter-pg | 见 Section 4 |
| Auth | Supabase Auth | Email + Google + GitHub |
| Payments | Stripe | Credits 或 Subscription，见 Section 6 |
| Email | Resend + React Email | Optional，见 Section 7 |
| Deployment | Vercel | Hobby plan 起步 |

---

## 2. 项目目录结构

```
my-project/
├── app/
│   ├── api/
│   │   ├── stripe/
│   │   │   ├── checkout/route.ts
│   │   │   └── webhook/route.ts
│   │   └── [...business routes]
│   ├── auth/
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── callback/route.ts        ← OAuth callback，必须有
│   ├── dashboard/page.tsx
│   ├── page.tsx                     ← Landing page（已登录 → redirect /dashboard）
│   └── layout.tsx
├── components/
│   ├── Header.tsx
│   └── [...business components]
├── lib/
│   ├── supabase/
│   │   ├── client.ts               ← 浏览器端
│   │   ├── server.ts               ← 服务端组件
│   │   └── admin.ts                ← 绕过 RLS，服务端 only
│   └── db/
│       └── client.ts               ← Prisma singleton
├── prisma/
│   └── schema.prisma
├── middleware.ts                    ← 路由保护
├── vercel.json                      ← Cron jobs（如需要）
└── .env.local
```

---

## 3. Auth 模块

### 3.1 Supabase 三件套（每个项目必须完整创建）

> **AI 做**：三个文件直接生成（client.ts / server.ts / admin.ts）。

**lib/supabase/client.ts** — 浏览器端
```typescript
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

**lib/supabase/server.ts** — 服务端组件 / API route
```typescript
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function createServerSupabaseClient() {
  const cookieStore = await cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll() },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {}
        },
      },
    }
  )
}
```

**lib/supabase/admin.ts** — 服务端 only，绕过 RLS
```typescript
import { createClient } from '@supabase/supabase-js'

export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)
```

> ⚠️ `supabaseAdmin` 永远不能暴露给客户端，只在 API route 和 Server Component 里用。

---

### 3.2 Login 页（Email + Google + GitHub）

> **AI 做**：写登录页组件。**Human 做**：Google / GitHub 的 Client ID / Secret 从 Google Cloud Console / GitHub OAuth Apps 拿到之后，粘到 Supabase Dashboard（见 §3.6）——AI 不能代操作浏览器登录 Google / GitHub 控制台。

```typescript
// app/auth/login/page.tsx — 支持三种登录方式
'use client'

// Email/Password
const { error } = await supabase.auth.signInWithPassword({ email, password })

// Google OAuth
await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: { redirectTo: `${window.location.origin}/auth/callback` }
})

// GitHub OAuth
await supabase.auth.signInWithOAuth({
  provider: 'github',
  options: { redirectTo: `${window.location.origin}/auth/callback` }
})
```

#### UX 铁律：登录 + 创建账号是**同一个入口**，文案必须写清楚

只支持 Email/Password 的页面，sign-in 和 sign-up 是**两个不同动作**（`signInWithPassword` 失败不会自动创建账号）。但只要接了 OAuth（Google / GitHub），OAuth 第一次登录**等于注册**——用户不知道这个细节，只看到 UI 说 "Sign in" 会困惑："我没账号怎么办？点 Google 真的会帮我建吗？"

**任何同时支持 OAuth + Email 的登录 UI 必须满足 3 条**：

1. **Subtitle / 副标题**明说双用途：`Sign in, or create an account — same modal/page.`
2. **OAuth 按钮下方一行小字**：`First time? Continue with Google creates your account automatically.`
3. **给 Email 新用户明路**：底部必须有 `No account yet? [Sign up with email →](/auth/register?next=<path>)` 链接——Email path 不会 auto-create，必须显式跳到注册页。

忘了写会收到"我试了但没反应"这类投诉。vibe-reading 2026-04-23 踩过——用户试了 Google 之后困惑到以为流程坏了。

### 3.3 Register 页

> **AI 做**：写注册页 + Profile upsert 逻辑。

```typescript
// app/auth/register/page.tsx
const { data, error } = await supabase.auth.signUp({ email, password })

// 注册成功后，立即在 Prisma 创建 Profile（用 upsert，不用 create）
// 用 upsert 是因为 OAuth 用户可能已有 Profile
await prisma.profile.upsert({
  where: { id: data.user!.id },
  create: { id: data.user!.id, email },
  update: {},
})
// 然后 redirect('/onboarding') 或 redirect('/dashboard')
```

### 3.4 OAuth Callback

> **AI 做**：写 callback route。

```typescript
// app/auth/callback/route.ts — OAuth 登录后的跳转处理（必须有）
import { NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase/server'

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')

  if (code) {
    const supabase = await createServerSupabaseClient()
    const { data, error } = await supabase.auth.exchangeCodeForSession(code)

    if (!error && data.user) {
      // OAuth 用户也需要确保有 Profile 行
      await prisma.profile.upsert({
        where: { id: data.user.id },
        create: { id: data.user.id, email: data.user.email! },
        update: {},
      })
      return NextResponse.redirect(`${origin}/dashboard`)
    }
  }

  return NextResponse.redirect(`${origin}/auth/login?error=oauth`)
}
```

### 3.5 Middleware — 路由保护

> **AI 做**：写 `middleware.ts`；每个项目只需改 PROTECTED_ROUTES / AUTH_ROUTES 数组。

```typescript
// middleware.ts
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

const PROTECTED_ROUTES = ['/dashboard', '/onboarding', '/settings']
const AUTH_ROUTES = ['/auth/login', '/auth/register']

export async function middleware(request: NextRequest) {
  const response = NextResponse.next()
  const supabase = createServerClient(/* ... */)
  const { data: { user } } = await supabase.auth.getUser()

  const path = request.nextUrl.pathname

  if (!user && PROTECTED_ROUTES.some(r => path.startsWith(r))) {
    return NextResponse.redirect(new URL('/auth/login', request.url))
  }

  if (user && AUTH_ROUTES.includes(path)) {
    return NextResponse.redirect(new URL('/dashboard', request.url))
  }

  return response
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|api).*)'],
}
```

### 3.6 Supabase Dashboard 配置

> **Human 做**（整节都是 Dashboard 点击 + 粘 keys，AI 做不了）。配完每个 provider **回到 Providers 列表目视确认** toggle 是 ON，不要只看 Save 成功就假设生效。

- Authentication → Providers → **Email**: 关闭 "Confirm email"（开发阶段）
- Authentication → Providers → **Google**: 填入 Client ID + Secret（从 Google Cloud Console 获取）
- Authentication → Providers → **GitHub**: 填入 Client ID + Secret（从 GitHub OAuth Apps 获取）
- Redirect URL 填：`https://your-project.vercel.app/auth/callback`

---

## 4. Database 模块（Prisma）

### 4.1 安全模型

> **AI 遵循**：写每个 API route 时第一行必须包含 session 验证模板（见下）。这是写代码的铁规，不是独立步骤。

**所有表 RLS DISABLED。安全靠 API 层保证。**

规则：每个 API route 第一行必须验证 session：
```typescript
const supabase = await createServerSupabaseClient()
const { data: { user } } = await supabase.auth.getUser()
if (!user) return new Response('Unauthorized', { status: 401 })
```
> 这条规则没有例外。忘记写 = 安全漏洞。

### 4.2 Prisma 初始化（Prisma v7 必须用 adapter）

> **AI 做**：写 `lib/db/client.ts` + 生成 `npm install` 命令。**Human 做**：在 terminal 里执行 `npm install`（AI 也可以跑，但最终确认依赖装好是你）。

```typescript
// lib/db/client.ts
import { PrismaClient } from '@prisma/client'
import { PrismaPg } from '@prisma/adapter-pg'

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL!,
  ssl: { rejectUnauthorized: false },  // Vercel → Supabase 必须加
})

declare global { var __prisma: PrismaClient | undefined }
export const prisma = global.__prisma ?? new PrismaClient({ adapter })
if (process.env.NODE_ENV !== 'production') global.__prisma = prisma
```

安装依赖：
```bash
npm install prisma @prisma/client @prisma/adapter-pg pg @types/pg
```

### 4.3 schema.prisma 标准配置

> **AI 做**：写 `prisma/schema.prisma`；业务 model（除了必备的 `Profile`）按项目 spec 扩展。改完 **AI 跑** `npx prisma db push` 同步 schema 到数据库。

```prisma
generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["driverAdapters"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// 每个项目必须有 Profile 表，字段按需扩展
model Profile {
  id        String   @id                  // = Supabase auth.users.id
  email     String   @unique
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // 按项目需求添加字段...
}
```

### 4.4 DATABASE_URL 规范

> **Human 做**：在 Supabase Dashboard 里拿 Transaction Pooler URL，粘到本地 `.env.local` + Vercel env vars。AI 读不到你的 Dashboard。

**必须用 Supabase Transaction Pooler URL（port 6543）**，不用 Direct Connection（port 5432）。
Direct connection 在 serverless 环境会超时。

获取路径：Supabase Dashboard → Connect → Transaction pooler tab

```
DATABASE_URL=postgresql://postgres.[ref]:[PASSWORD]@aws-0-[region].pooler.supabase.com:6543/postgres
```

### 4.5 Build Command

> **Human 做**：在 Vercel Dashboard → Settings → Build & Development Settings 改 Build Command。AI 改不了 Vercel project 设置。

```bash
npx prisma generate && next build
```

> Vercel Build Settings 里要改这个，否则 Prisma client 不会生成。

### 4.6 Alternative: Supabase-only (No Prisma)

> **AI 做**：改依赖（装/去 prisma 相关包）、改 `.env.local`、改 Build Command、写 `supabase-js` 调用代码、产出建表 SQL。**Human 做**：在 Supabase Dashboard → SQL Editor 里粘 SQL 执行（AI 打不开浏览器 Dashboard）。

Use this approach when:
- Sharing a Supabase project across multiple apps
- Want to avoid Prisma complexity
- Prefer SQL-first schema management

Setup:
- Create tables directly in Supabase Dashboard → SQL Editor
- Use supabase-js client for all DB operations (no Prisma)
- No `DATABASE_URL` needed in `.env.local`
- Use `supabaseAdmin` (service role) for server-side writes

Remove from `.env.local`:
- `DATABASE_URL`

Remove from dependencies:
- `prisma`
- `@prisma/client`
- `@prisma/adapter-pg`
- `pg`
- `@types/pg`

Remove from Build Command:
- `"npx prisma generate &&"` prefix (just use `next build`)

### 4.7 文档解析（PDF / 其他）

> **AI 做**：写解析代码 + 装依赖。Human 什么都不用做。

**PDF 解析统一用 `unpdf`，不用 `pdf-parse`**。踩过的坑（vibe-reading 2026-04-23）：

- `pdf-parse@2.x` 在 **Next.js 16 + Turbopack** 下**双重翻车**：
  1. 先报 `Setting up fake worker failed: Cannot find module '.next/dev/server/chunks/pdf.worker.mjs'` —— Turbopack 无法解析 pdfjs-dist 用 `import.meta.url` 找 worker 的路径
  2. 加 `serverExternalPackages: ['pdf-parse', 'pdfjs-dist']` 后变成 `DataCloneError: Cannot transfer object of unsupported type` —— pdfjs fake-worker 的 `postMessage` 在 Node 20+ 序列化 Buffer 会崩
  3. 手动 `PDFParse.setWorker(file://...)` 后又是 `ERR_INVALID_ARG_TYPE: path must be string`
- `unpdf` 专为 **serverless / edge Node** 设计，内置针对这种环境编译的 pdfjs build，**零配置跑通**。

```bash
npm install unpdf
# 不要装 pdf-parse、也不要装 pdfjs-dist 单独
```

```typescript
// lib/pdf/parser.ts
import { extractText, getDocumentProxy, getMeta } from 'unpdf'

export async function parsePdf(buffer: Buffer) {
  const pdf = await getDocumentProxy(new Uint8Array(buffer))
  try {
    const [{ info }, { totalPages, text }] = await Promise.all([
      getMeta(pdf),
      extractText(pdf, { mergePages: true }),
    ])
    return {
      title: info?.Title ?? 'Untitled',
      author: info?.Author ?? null,
      text: text as string,
      pageCount: totalPages,
    }
  } finally {
    await pdf.destroy()
  }
}
```

API route 里记得 `export const runtime = 'nodejs'`（PDF 在 Edge runtime 跑不起来）。

---

## 5. Vercel 部署

### 5.1 环境变量清单

> **Human 做**：Vercel Dashboard → Settings → Environment Variables 粘贴。用 "Paste .env" tab 可以整块粘，不用一个个填。AI 不能访问 Vercel 控制台。**改完 env 必须手动 Redeploy**——Vercel 不会因为 env 改动自动重部（Dashboard → Deployments → 最新 deploy → `⋯` → Redeploy）。

每次新项目，在 Vercel Dashboard → Settings → Environment Variables 填入：

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Database（Transaction Pooler URL）
DATABASE_URL=

# Stripe（见 Section 6）
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
# Credits 模式额外需要：
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=
# Subscription 模式额外需要：
STRIPE_PRICE_ID=

# App URL
NEXT_PUBLIC_APP_URL=https://your-project.vercel.app

# Resend（Optional）
RESEND_API_KEY=
RESEND_FROM_EMAIL=

# OpenAI（如需要）
OPENAI_API_KEY=

# Cron Secret（如有 cron jobs）
CRON_SECRET=   # 生成方式：openssl rand -base64 32
```

### 5.2 Cron Jobs（Hobby plan）

> **AI 做**：写 `vercel.json` 和对应的 cron route 代码（含 `CRON_SECRET` 验证）。**Human 做**：生成 `CRON_SECRET`（`openssl rand -base64 32`）并加到 Vercel env vars。

```json
// vercel.json — Hobby plan 只支持每日一次
{
  "crons": [
    { "path": "/api/cron/your-job", "schedule": "0 1 * * *" }
  ]
}
```

所有 cron route 开头必须验证：
```typescript
if (request.headers.get('authorization') !== `Bearer ${process.env.CRON_SECRET}`) {
  return new Response('Unauthorized', { status: 401 })
}
```

### 5.3 部署流程

> **AI 做**：`git add` / `git commit` / `git push`（AI 可以跑这三步，但授权先于每次 push，尤其是首次）。**Human 做**：推完必须**打开线上 URL 实测** `/` 和一个保护路由——`Deploy Ready` 只代表 build 过，不代表 runtime OK。middleware / API route 要到首个请求才会暴露 env vars 缺失或 Supabase 连不上（症状常见是 `500 MIDDLEWARE_INVOCATION_FAILED`）。

**首次 deploy 时机：Phase 1 landing 做完之后立即触发**，不等 Auth / Stripe / 业务逻辑都写完（见 §11 Phase 2）。早部的好处：(1) 立刻暴露 env vars 漏配 / Build Command 错 / runtime 异常，省得几小时后才发现；(2) 之后每个 Phase 一推 commit 就自动 redeploy，每个 Phase 都能在生产 URL 立刻实测。只有 `/` 能显示 landing 就足够触发首次 deploy——其他路由跑不起来是正常的，因为业务代码还没写。

```bash
git add .
git commit -m "description"
git push   # Vercel 自动 deploy main 分支
```

---

## 6. Stripe 模块

> **整节分工**：**AI 做** 所有代码——checkout route、webhook handler、credit/subscription 逻辑、Prisma schema 的 Credit / Subscription 字段。**Human 做** Stripe 控制台相关的**一切**：建 Product、拿 Price ID、拿 Secret Key、配 Webhook URL、在生产部署后注册 webhook endpoint 拿 `STRIPE_WEBHOOK_SECRET`。AI 不能登录 Stripe Dashboard。

### 模式 A：Credits（一次性购买）

适用：AI Video Assistant 类产品，用户买 credits 消费

```typescript
// app/api/stripe/checkout/route.ts
import Stripe from 'stripe'
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(request: Request) {
  // 1. 验证 session
  const supabase = await createServerSupabaseClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return new Response('Unauthorized', { status: 401 })

  const { packageId } = await request.json()

  // 2. 定义 credit packages（按项目定制价格）
  const packages = {
    '10':  { amount: 1000, credits: 10 },
    '25':  { amount: 2500, credits: 25 },
    '50':  { amount: 5000, credits: 50 },
  }
  const pkg = packages[packageId as keyof typeof packages]

  // 3. 创建 Stripe Checkout Session（一次性付款）
  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    payment_method_types: ['card'],
    line_items: [{
      price_data: {
        currency: 'usd',
        unit_amount: pkg.amount,
        product_data: { name: `${pkg.credits} Credits` },
      },
      quantity: 1,
    }],
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard?success=true`,
    cancel_url:  `${process.env.NEXT_PUBLIC_APP_URL}/dashboard`,
    metadata: { userId: user.id, credits: pkg.credits.toString() },
  })

  return Response.json({ url: session.url })
}
```

```typescript
// app/api/stripe/webhook/route.ts — Credits 版
export async function POST(request: Request) {
  const body = await request.text()   // ← 必须用 text()，不能用 json()
  const sig = request.headers.get('stripe-signature')!

  const event = stripe.webhooks.constructEvent(body, sig, process.env.STRIPE_WEBHOOK_SECRET!)

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object as Stripe.Checkout.Session
    const { userId, credits } = session.metadata!

    // 加 credits 到用户 Profile
    await prisma.profile.update({
      where: { id: userId },
      data: { credits: { increment: parseInt(credits) } },
    })
  }

  return new Response('ok')
}
```

**需要的环境变量**：
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`（如果用 Stripe Elements 自定义表单）

---

### 模式 B：Subscription（月付）

适用：LaunchRadar 类产品，月订阅制

```typescript
// app/api/stripe/checkout/route.ts — Subscription 版
export async function POST(request: Request) {
  const supabase = await createServerSupabaseClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return new Response('Unauthorized', { status: 401 })

  const profile = await prisma.profile.findUnique({ where: { id: user.id } })

  // 用 Stripe Hosted Checkout，不需要 publishable key
  const session = await stripe.checkout.sessions.create({
    mode: 'subscription',
    line_items: [{ price: process.env.STRIPE_PRICE_ID!, quantity: 1 }],
    customer_email: profile!.email,
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard?upgraded=true`,
    cancel_url:  `${process.env.NEXT_PUBLIC_APP_URL}/dashboard`,
    metadata: { profileId: profile!.id },
  })

  return Response.json({ url: session.url })
}
```

```typescript
// app/api/stripe/webhook/route.ts — Subscription 版
if (event.type === 'checkout.session.completed') {
  const session = event.data.object as Stripe.Checkout.Session
  await prisma.profile.update({
    where: { id: session.metadata!.profileId },
    data: { subscriptionStatus: 'active' },
  })
}

// 可选：处理取消、续费
if (event.type === 'customer.subscription.deleted') {
  // 更新 subscriptionStatus: 'canceled'
}
```

**需要的环境变量**：
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_PRICE_ID`（从 Stripe Dashboard → Products 复制）
- ~~`NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`~~（Hosted Checkout 不需要）

**Stripe Dashboard 配置**：
1. Products → 创建产品 → 设置价格 → 复制 Price ID
2. Developers → Webhooks → Add endpoint → 填 `https://your-project.vercel.app/api/stripe/webhook` → 选 `checkout.session.completed`
3. 复制 Signing Secret → 填入 `STRIPE_WEBHOOK_SECRET`

**本地测试 Webhook**：
```bash
brew install stripe/stripe-cli/stripe
stripe login
stripe listen --forward-to localhost:3000/api/stripe/webhook
# CLI 会给你一个临时 STRIPE_WEBHOOK_SECRET，填入 .env.local
```
测试卡号：`4242 4242 4242 4242`，任意未来日期，任意 CVV

---

## 7. Email 模块（Optional）

> **AI 做**：写 email templates（React Email）+ 发送函数 + `npm install` 命令。**Human 做**：去 Resend Dashboard 拿 `RESEND_API_KEY`（首次注册 Resend 账号）；上线前在 Resend Dashboard 验证自己的域名，把 `RESEND_FROM_EMAIL` 从 `onboarding@resend.dev` 改成真域名。AI 打不开 Resend 控制台。

> 按需加入，不是每个项目必须有。加之前在 .env.local 和 Vercel 加上 RESEND_API_KEY。

安装：
```bash
npm install resend @react-email/components react-email
```

**邮件模板**（React Email）：
```typescript
// lib/email-templates/welcome.tsx
import { Html, Text, Button } from '@react-email/components'

export function WelcomeEmail({ name }: { name: string }) {
  return (
    <Html>
      <Text>Hi {name}, welcome!</Text>
      <Button href="https://your-app.com/dashboard">Go to Dashboard</Button>
    </Html>
  )
}
```

**发送函数**：
```typescript
// lib/email.ts
import { Resend } from 'resend'
const resend = new Resend(process.env.RESEND_API_KEY!)

export async function sendEmail({
  to, subject, react
}: {
  to: string
  subject: string
  react: React.ReactElement
}) {
  return resend.emails.send({
    from: process.env.RESEND_FROM_EMAIL!,
    to,
    subject,
    react,
  })
}
```

**开发阶段**：用 `onboarding@resend.dev` 作为 FROM（不需要域名验证）。
**上线前**：在 Resend Dashboard 验证自己的域名，换成 `noreply@yourdomain.com`。

---

## 8. API Route 写法规范

> **AI 遵循**：每个 API route 按这个顺序写。Human 不需要做什么，只需要在 code review 时对照这个规范。

每个 API route 都遵循这个顺序：

```typescript
export async function POST(request: Request) {
  // Step 1: 验证 session（必须第一步，无例外）
  const supabase = await createServerSupabaseClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return new Response('Unauthorized', { status: 401 })

  // Step 2: 解析 request body
  const { field1, field2 } = await request.json()

  // Step 3: 业务逻辑（Prisma 操作）
  const result = await prisma.someModel.create({ ... })

  // Step 4: 返回结果
  return Response.json({ success: true, data: result })
}
```

---

## 9. 常见坑（已踩过，不要再踩）

| 坑 | 原因 | 解法 |
|----|------|------|
| Prisma v7 空 constructor 报错 | v7 不再接受无参数 | 必须用 `@prisma/adapter-pg`，见 Section 4.2 |
| Vercel → Supabase P1001 超时 | 用了 Direct Connection | 改用 Transaction Pooler（port 6543） |
| Stripe webhook 签名验证失败 | 用了 `request.json()` | 必须用 `request.text()` |
| OAuth 登录后没有 Profile 行 | 只在 register 创建了 Profile | callback route 里也要 upsert Profile |
| Email 注册后无法登录 | Supabase 要求邮件验证 | 开发阶段关闭 Email Confirmation |
| Stripe webhook 404 | 文件路径错误 | 必须是 `app/api/stripe/webhook/route.ts` |
| Build 时 Prisma client 找不到 | next build 前没有 generate | Build command 改为 `npx prisma generate && next build` |

---

## 10. Sprint Tracking

> **一般情况（用 `new-project.sh` 建 repo）**：Step 1（复制 workflow）+ Step 2（替换 `project_id` / `project_name`）**已由 `bash stack/new-project.sh` 自动做掉**。你只需要做 Step 3（加 `PLAYBOOK_TOKEN` secret，30 秒）。
>
> **分工**（仅参考；手动初始化场景才用到 Step 1-2）：**AI 做** Step 1-2 + Step 4 的 `git commit` / `git push`。**Human 做** Step 3（GitHub Settings → Secrets，纯 GitHub UI）+ Step 4 推完**去 GitHub Actions 看两个 workflow 是否绿灯**。

每个项目标配，用来追踪每周进度。自动生成 SPRINT.md，记录每周 commit 活跃度。

### 设置（4步，新项目建立后立即做）

**Step 1: 复制 workflow 文件**
```bash
mkdir -p .github/workflows
cp ../indie-product-playbook/stack/sprint-report.yml .github/workflows/
cp ../indie-product-playbook/stack/notify-playbook.yml .github/workflows/
```

**Step 2: 更新 notify-playbook.yml**

编辑 `.github/workflows/notify-playbook.yml`，将 `project_id` 和 `project_name` 改为匹配 `indie-product-playbook/ideas/README.md` 中的项目行（`project_id` 必须是该行中出现的字符串，通常是 proposal 文件名去掉 `-proposal.md`）：
```yaml
--arg project_id "your-project-id" \
--arg project_name "Your Project Name" \
```

**Step 3: 添加 PLAYBOOK_TOKEN**

GitHub repo → Settings → Secrets and variables → Actions → New repository secret，添加 `PLAYBOOK_TOKEN`（与其他项目相同的 token）。

**Step 4: 提交并验证**
```bash
git add .github/workflows/ scripts/
git commit -m "feat: add sprint tracking"
git push
# 在 GitHub Actions 确认两个 workflow 都成功
git pull  # 拉取 SPRINT.md
```

### 常见问题
- Push 被拒绝 → `git pull --rebase` 再 push
- notify-playbook 失败退出码1 → 检查 PLAYBOOK_TOKEN 是否已设置
- ideas/shopify-xx.md 只有 Sprint Summary → 文件不存在时会新建空文件；需手动填入 proposal 内容后 Sprint Summary 才会追加更新

----

## 11. 新项目 Checklist

> 每一行前面标 **[AI]** 或 **[Human]**。[AI] 是 Claude 可以自动做（写代码 / 装依赖 / 改文件 / 跑 npx / git 操作）；[Human] 是你必须亲自做（Dashboard 点击 / 浏览器授权 / 粘 secret / 控制台配置）。

**核心原则**：
- **landing 早做**：Phase 1 就把壳 + 首屏做出来，别埋到最后
- **首次 deploy 早触发**：Phase 2 landing 能看就部到 Vercel，不等 Auth/Stripe 写完
- **deploy 之后立刻 v0 抛光**：Phase 3 用 v0 重做 landing 的视觉 + 落地 token 系统，**赶在写业务代码之前**。后面所有屏 free 复用 token，免得最后一次性大改
- **Stripe 独立**：Phase 5，仅付费项目需要；MVP 可跳过
- **每 Phase 完都 push**：触发 Vercel 自动 redeploy，每 Phase 能在生产 URL 实测

### Phase 0 — Bootstrap（`new-project.sh` 已自动完成）

`bash stack/new-project.sh <id> "<name>"` 一条命令搞定：创建 GitHub repo、复制 `docs/product-spec.md` + `docs/implementation-guide.md`、写入 `.github/workflows/sprint-report.yml` + `notify-playbook.yml`（含 `project_id` 替换）、初始 commit + push。

```
[Human]  GitHub repo → Settings → Secrets and variables → Actions → 加 PLAYBOOK_TOKEN（一次性 30 秒）
```

### Phase 1 — Scaffold + Landing 壳

```
[AI]     npx create-next-app@latest my-project --typescript --tailwind --app
[AI]     npx shadcn@latest init
[AI]     npm install @supabase/supabase-js @supabase/ssr <其他 deps by project>
[AI]     Scaffold 清理（照 §2.5）：layout.tsx metadata / favicon / 字体变量
[AI]     写 app/page.tsx landing 页（真设计，不是 scaffold 残留）
[Human]  创建 / 复用 Supabase project → 复制 URL / anon key / service role key 到 .env.local
```

### Phase 2 — 首次 Vercel 部署（landing 能看就部）

**关键点**：landing 一可见就立刻部署。早部 = 早发现 env vars 漏配 / Build Command 错 / runtime 问题。之后每个 commit push 都自动 redeploy，每个 Phase 完都能在生产 URL 实测。

```
[Human]  Vercel Dashboard → Import Git Repository → 选 repo → Deploy
[Human]  Settings → Environment Variables → "Paste .env" tab 粘 .env.local 内容
[Human]  Settings → Build Command → 改 `npx prisma generate && next build`（如用 Prisma）
[Human]  打开 Vercel URL 实测 landing 页渲染正常（Deploy Ready ≠ runtime OK）
```

> **Custom domain 不在这一步做**。Phase 2 用 Vercel 自动给的 `*.vercel.app` 即可——产品名 / brand 还可能改。等 MVP 跑通、§12.A UAT 通过后再换 custom domain，详见 **§12.B**（一次性操作，含 Namecheap DNS + Supabase Auth + 第三方 config 全套迁移步骤）。

### Phase 3 — v0 Polish + Token Lockin

**这一步赶在写业务代码之前**。Phase 1 出来的 landing 是 raw shadcn 模版，跟正式产品的视觉气质有距离。用 v0 重做一版 landing，**把 token 系统在这一步定型**：颜色（含 dark mode）、radius scale、字体层级、按钮 / 卡片基样式。后面 Phase 4-N 写每个新屏直接复用同一组 token，不用回头大改。

vibe-reading 的反例：跳过这一步直接做完所有业务屏，再大改一次视觉，回头改了 5+ 个屏，重活。

```
[Human]  v0.dev → 给 prod URL（Phase 2 已经部上去了）+ 一段 design brief
         brief 必须包含：
           - locked constraints：单 accent / no framer-motion / 用 CSS token 而非 hardcoded color / sentence case
           - desired vibe：选一个参照（Notion / Linear / Vercel docs / Stripe / etc）
           - 必保留：上传 / 登录入口 / 现有交互
[Human]  从 v0 拿 .tsx 全文，paste 给 Claude
[AI]     转译集成（关键 4 步，每一步都不能省）：
           1. hardcoded color (slate-500 / blue-500 等) → CSS token (text-muted-foreground / bg-primary 等)
           2. 拆 page / Screen 分层（v0 输出是单文件 + mock data；page 留 server-side fetch，Screen 留 'use client'）
           3. 接真实数据 / 交互（v0 用 mock）
           4. 删冗余依赖（framer-motion / 多余 lucide icon / react-confetti 等 v0 自动引的）
[AI]     落地到 globals.css：
           - `:root` 完整 light tokens
           - `.dark` 完整 dark tokens（即使现在不开 toggle，也先写好，后面加 toggle 是 5 分钟事）
           - --radius / --font / 其他基础变量
[AI]     加 dark mode toggle（可选，但建议同步做）：sun/moon 按钮在 nav；inline <head> 脚本防 FOUC
[AI]     git push → Vercel 自动 redeploy
[Human]  浏览器实测 light + dark 各过一遍，prod URL 看视觉是否到位
```

**Phase 3 的 lock-down 规则**（写进 design brief 也好，集成时强制也好）：

- v0 输出 ≠ 直接 commit。**永远**经过转译 pass
- 不引第二条 accent ramp（保持单 accent）
- 不引动画库（只用 Tailwind 自带 hover transition）
- v0 的 hero illustration / SVG 装饰元素默认删掉
- 现有 auth 流 / upload 流的交互**不能动**（功能优先）

**何时跳过 Phase 3**：
- 内部工具 / 不公开的项目（直接用 shadcn 默认即可）
- 已有强设计系统的项目（v0 会和现有 token 打架）
- 极简 CLI / API 类项目（无前端需要抛光）

### Phase 4 — DB + Auth

```
[AI]     写 lib/supabase/{client,server,admin}.ts（照 §3.1）
[AI]     写 middleware.ts + /auth/{login,register,callback}（照 §3.2–3.5）
[AI]     写 lib/db/client.ts（如用 Prisma，照 §4.2）
[AI]     写 prisma/schema.prisma + npx prisma db push（Prisma 路径）
[AI→Human] 或产出建表 SQL → [Human] 粘到 Supabase Dashboard SQL Editor 跑（Supabase-only 路径，见 §4.6）
[Human]  Supabase Dashboard → Authentication → 关 Email Confirmation
[Human]  Supabase Dashboard → Auth → Providers → 开 Google / GitHub（如需要，粘 Client ID/Secret）
[AI]     git push → Vercel 自动 redeploy
[Human]  浏览器实测 Email 注册 / 登录 / Google OAuth + middleware 保护路由重定向
```

### Phase 5 — Stripe（**rare case**：仅 Day 1 就要付费的项目）

> **典型路径走 §12.D Post-MVP Stripe，不在这里做**。99% 的 indie 项目应该 free MVP 跑出来 → UAT 通过 → 域名定型 → 再考虑加付费。在 build 阶段就接 Stripe 会让 user feedback 受"价格"干扰，也增加在产品方向还没定型时迁移用户的成本。
>
> **只有极少数情况在 Phase 5 做 Stripe**：
> - SaaS 订阅类，免费完全没有意义（必须付费才能跑核心 feature）
> - 你做的是 Stripe / 计费 SDK 本身，不接付费就无法 dogfood
>
> 满足以上才在 build 阶段做。其它一律走 §12.D。

如果确实是 Day 1 接：

```
[Human]  Stripe Dashboard → 建 Product → 复制 Price ID + Secret Key → 加到 Vercel env vars
[AI]     写 /api/stripe/{checkout,webhook} + 前端付费按钮（照 §6 模式 A 或 B）
[Human]  Stripe test mode 付款实测（test card 4242 4242 4242 4242）
[Human]  Stripe Dashboard → Webhooks → 用生产 URL 创建 endpoint → 复制 STRIPE_WEBHOOK_SECRET
[Human]  加 STRIPE_WEBHOOK_SECRET 到 Vercel env → Redeploy
```

### Phase 6-N — 业务逻辑

按 `docs/implementation-guide.md` 的 Phase 顺序逐个做。每 Phase 完：

```
[AI]     git push
         (Vercel 自动 redeploy)
[Human]  线上 URL 实测本 Phase 新增功能（浏览器走一遍 user flow）
```

#### 🧠 Human-in-the-loop 批量原则（不要每 phase 都叫 Human 测）

**默认不要做**：写完 Phase N → ping Human "去浏览器测一下" → Human 点进去发现**下一个按钮 404**（因为 Phase N+1 还没写）→ 困惑 + 浪费。

**正确做法**：把连续几个 Phase 当成一个**可测的里程碑**打包做完，中间**不中断** Human，只在打包结束时一次性交付完整的 user flow 让 Human 实测。

**如何判断 "可测的里程碑"**：一个 Phase 组合是"可测的"，当且仅当：
- 完成后，典型 happy-path 的第一个动作到最后一个动作**全部有实现**
- Human 沿路点击不会碰到 404 / "coming soon" 死端
- 如果某个 Phase 的 UI 产出一个按钮，那个按钮的目的地**已经建好**

**典型批量边界**（以 Vibe Reading 旧 v1 implementation-guide 的项目内 Phase 编号为例 —— 注意这些是项目自己的 Phase，不是 STANDARD §11 的 Phase）：
- 项目 Phase 5 + 6（Goal 输入 + 三色映射）= 第一个可测里程碑：上传 → 填 goal → 看 map
- 项目 Phase 7 + 8 + 9（Claim + Brief + Restate）= 第二个可测里程碑：登录 → 看 brief → 复述
- 项目 Phase 11 + 12（Library + Cron）= 收尾里程碑
- 项目 Phase 10（Read mode）= 独立一块（spec defer）

**例外**（必须中断 Human 的场景）：
- Phase 需要 Human 在 Dashboard 做配置（Supabase bucket、OAuth credentials、Vercel env）——这种 blocker 型 Human work 挡不过去，必须立刻中断
- 架构决策争议点（比如"这个 schema 设计对不对"）——宁愿早问也比埋头一路跑偏

**不批量的代价**（这是真实踩过的）：Vibe Reading 2026-04-23，我按 phase-by-phase 节奏让 user 每一个 phase 都去浏览器测，结果项目 Phase 5 → goal → /map 404；Phase 6 → map → 点 Brief → 404；Phase 7 推完说"现在登录就通了"——user 累了。正确的节奏本该是"项目 Phase 5+6+7+8+9 一起做完，一次性告诉 user：'现在可以从上传到复述全部跑一遍'"。

---

## 12. Post-MVP Operations

> §11 的 Phase 0–N 走完，MVP 已经在 `*.vercel.app` 上能用了。**接下来不是直接邀请陌生人，也不是急着接 Stripe**。按下面 4 个子节顺序走：先你自己 dogfood 验证产品方向（A），再换 custom domain 让 brand 定型（B），再加 rate limit / 监控等防御性 scale-up（C），最后才是开始收费（D）。
>
> 跳步代价：UAT 没通过就换 domain → brand 跟着错；scale-up 没做就邀请陌生人 → OpenAI 账单爆；Stripe 在 UAT 之前接 → 用户反馈被"价格"污染。

### 12.A UAT — Creator Dogfooding（你一个人测）

> **AI 做**：根据自测发现的 issue 写迭代代码、修 bug。
> **Human 做**：你自己用 MVP 真的做一次"它本来要解决的事"。不是"测一遍 happy path"——是真的当一次用户。
> **判断 gate**：如果**你自己**都觉得"还不如不用 / 不如别的工具" → 不要继续 §12.B 域名 / §12.C 硬化，回 §11 Phase 6-N 改业务。

#### 步骤

```
[Human] 用 MVP 完整跑一次你**最早写 spec 时设想的真实场景**
        - 例：vibe-reading 真用它读完 1 本你想读的书（不是测试书）
        - 例：launchradar 真用它找出 3 条今天能 reach 的 Reddit / HN 线索
        - 例：trend-monitor 真用它收一封 daily digest 邮件，看里面是不是真有用
[Human] 跑过程中**别做开发者视角**（"哦这个按钮放错了"），做用户视角
        ("我想知道 X，但产品好像不让我直接问")
[Human] 跑完写 3 行：
          - 这次有用吗（真解决了问题 / 没解决）
          - 比 ChatPDF / NotebookLM / 你之前用的工具，更好 or 更差
          - 卡住的地方在哪（不是 bug，是"产品方法论的薄弱点"）
[AI]    基于这 3 行写 issue list（必修 / 优化 / 拒绝）
[AI]    必修做完，再跑一遍 §12.A
```

#### 决策 gate

- **通过**（自己觉得"嗯，这个工具我会继续用"）→ 进 §12.B Custom Domain
- **不通过**（自己都不想用）→ 不一定回炉，但要冷静分析：是产品立场问题、还是关键体验缺失？参考各项目 spec 的 Success Criteria 决策

#### 何时跳过 §12.A

- 工具是给自己用的（不需要外部用户验，但你自己持续用着算 dogfood）
- 已经在生产 `*.vercel.app` 跑得很顺、给反馈的人也不少（UAT 实际上一直在跑）
- 是 dev tool，target 用户=你自己 / 你的圈子，自己在 §11 Phase 6-N 的过程中已经持续 dogfood

#### 何时这一步会扩大成"5-10 朋友试用"

§12.A 通过 + §12.B 域名定型 + §12.C 硬化全做完 → 才邀请朋友 / 公开。**不要**在 dogfooding 没通过就邀请别人 —— 你自己都没说服自己，别人没耐心给你反馈。

---

### 12.B Custom Domain（一次性 · UAT 通过后做）

> **AI 做**：grep 代码里的硬编码 URL（metadata、email 模板、第三方 config 文件）、改 README 里的 live URL、commit + push、`curl` 测 redirect。
> **Human 做**：所有 Dashboard / Registrar 的 GUI 操作（Vercel Domains、Namecheap DNS、Supabase Auth、Stripe Webhooks）—— AI 进不去；浏览器实测 OAuth 走通。
> **关键约束**：env vars 改完后 Vercel **不会自动 redeploy**，必须 Human 在 Dashboard 点 Redeploy（或 AI 推一个空 commit 作为绕过）。

**前置**：MVP 已上线（用 `*.vercel.app` 自动域名），§12.A UAT 通过、产品名 / brand 定型不会再改，已在 Namecheap 等 registrar 买好域名。

#### 第一步：Vercel 加 domain

```
[Human] Vercel Dashboard → 项目 → Settings → Domains → Add
[Human] 输入 example.com（不带 https://）→ Vercel 提示 DNS 配置方案
```

DNS 两种方案：
- **方案 A**：把整个域名 nameserver 改成 Vercel 的 —— 简单，但失去 Namecheap 上的邮箱 / 子域名灵活性
- **方案 B（推荐）**：保留 Namecheap 管，只加 A + CNAME 记录指向 Vercel

#### 第二步：Namecheap 加 DNS 记录

```
[Human] Namecheap → Domain List → 找到 example.com → Manage → Advanced DNS
[Human] Add Record: Type=A      Host=@    Value=<Vercel 给的 IP，一般 76.76.21.21>
[Human] Add Record: Type=CNAME  Host=www  Value=cname.vercel-dns.com
[Human] TTL 默认 (Automatic)
```

DNS propagation 一般 5–30 min。期间 Vercel Dashboard → Domains 状态条会从 ❌ Invalid 变 ✅ Valid。DNS 生效后 Vercel 自动申请 Let's Encrypt 证书，HTTPS 5–10 分钟内可用。

#### 第三步：选 www / apex 主域

```
[Human] Vercel Dashboard → Domains → 把 example.com 或 www.example.com
        其中之一标记为 Primary（另一个会自动 307 redirect 到 Primary）
```

约定：**apex 当主，www 子域 307 到主**（`www.example.com → example.com`）。也可反过来，但要全项目一致。Vercel 自动设 redirect，不用手写。

#### 第四步：改所有引用旧 URL 的地方

```
[Human] Vercel Dashboard → Settings → Environment Variables
        NEXT_PUBLIC_APP_URL = https://example.com   ← 替换 *.vercel.app
[Human] Vercel → Deployments → 最新 → ⋯ → Redeploy
        （env 不会自动触发重部；或 [AI] 推空 commit 触发自动 redeploy）
[Human] Supabase Dashboard → Auth → URL Configuration:
        - Site URL  =  https://example.com
        - Redirect URLs  → 加 https://example.com/auth/callback
          （如保留 www 入口，再加 https://www.example.com/auth/callback）
[Human] (仅 Day 1 就接 Stripe 的项目) Stripe Dashboard → Webhooks → 删旧 endpoint
        → 用新域名建新的 → 复制新的 STRIPE_WEBHOOK_SECRET → Vercel env 更新 → Redeploy
[AI]    grep 代码里硬编码的 *.vercel.app（理想情况应该全用 NEXT_PUBLIC_APP_URL，
        实际项目难免漏：metadata.openGraph.url / 邮件模板 / og-image 路径 /
        README live URL / 第三方 config 文件如 shopify.app.<name>.toml 等）
[AI]    git push → Vercel 自动 redeploy
```

#### 不用动的

```
[Human] Google OAuth Cloud Console — redirect URI 永远是
        https://<supabase-ref>.supabase.co/auth/v1/callback，跟 app 域名无关
[Human] CRON_SECRET / SUPABASE_SERVICE_ROLE_KEY / OPENAI_API_KEY — 跟域名无关
[AI]    本地 .env.local — 仍指 localhost
```

#### 第五步：实测

```
[AI]    curl -I https://www.example.com  → 期望 307 redirect 到 https://example.com
[AI]    curl -I https://example.com       → 期望 200
[Human] 浏览器测全套 user flow（bare 域 + www 子域**各走一遍**）：
        - landing 渲染
        - Google 登录走通（OAuth callback 不报 "redirect URI mismatch"）
        - Email 登录走通
        - middleware 保护路径（如 /library）能正确重定向到 /auth/login
        - 受保护路径登录后能访问
```

#### 已踩过的坑（projects 历史归档）

- **`www.<domain>` 子域 OAuth 转圈** — Supabase Site URL 设的是 bare 域，但用户从 www 子域进入，OAuth callback 回跳时 Supabase 用 Site URL 拼 redirect，跟实际域名不匹配 → 用户卡在 callback 页。修法：要么强制 www → bare redirect（首选），要么在 Supabase Redirect URLs 里把 www 版本也加上。
- **HTTPS 一开始 404 / "Not secure"** — Vercel 自动申请 Let's Encrypt 证书需要 5–10 分钟，期间 https 路径会 503 / 404。耐心等。
- **改 env 没 redeploy** — 旧 `NEXT_PUBLIC_APP_URL` 还在生产 build 里，metadata / email / OAuth redirect 还指 `*.vercel.app`，登录立刻报 "redirect URI mismatch"。修法：**每次改 env 都要 manual redeploy**（或推空 commit 触发自动）。
- **第三方 config 文件漏改** — 比如 Shopify app 的 `shopify.app.<name>.toml` 把 webhook URL 和 callback URL 全写死。换域名时 grep 所有 `*.toml` / `*.config.*` / 邮件模板 / static HTML，找旧域名一并改。

---

### 12.C Scale-up / Hardening（开放给陌生人之前的安全网）

> **触发条件**：§12.A UAT 通过 + §12.B 域名定型 + 准备分享给陌生人 / 推文 / Product Hunt。
> 在那之前**不做**这些 —— 没用户的产品装监控 / rate limit 是浪费时间。

#### 5 件事，按 ROI 排（一次做一件，不是必须全做）

```
1. OpenAI / API 成本上限（最便宜，最先做）
   [Human] OpenAI Dashboard → Settings → Usage limits
           Hard limit $25/月 + Alert email at $10
   5 分钟。Rate limit 漏了或被滥刷，账单不会爆。

2. Rate limit AI 端点
   [Human] 注册 Upstash → 建 Redis → 复制 REST URL + token
   [Human] Vercel env 加 UPSTASH_REDIS_REST_URL + UPSTASH_REDIS_REST_TOKEN
   [AI]    npm install @upstash/ratelimit @upstash/redis
   [AI]    写 lib/ratelimit.ts（每用户每天 50 次问答 / 200 次 brief 等）
   [AI]    在每个 AI 端点 auth check 之后插入 ratelimit check
   [AI]    git push
   [Human] 浏览器实测：连续 51 次请求 → 第 51 次应该 429

3. Error tracking (Sentry)
   [Human] Sentry → New Project → 选 Next.js
   [AI]    npm install @sentry/nextjs && npx @sentry/wizard@latest -i nextjs
   [AI]    校 sentry.{client,server,edge}.config.ts；tracesSampleRate=0.1
   [AI]    在每个 /api/* 的 catch 里加 Sentry.captureException
   [Human] Sentry → Alert rules → "5 errors / hour 发邮件"

4. Usage analytics (Posthog)
   [Human] Posthog → New Project → 选 Web → 复制 API key
   [Human] Vercel env 加 NEXT_PUBLIC_POSTHOG_KEY + NEXT_PUBLIC_POSTHOG_HOST
   [AI]    npm install posthog-js
   [AI]    写 lib/posthog.ts + app/providers.tsx 包 PostHogProvider
   [AI]    关键 conversion 点埋事件
   [Human] Posthog Dashboard → 建 funnel 看 drop-off

5. Storage lifecycle audit
   [Human] Supabase Dashboard → Storage → 看 bucket 用量
   [AI]    跑 SQL 查 orphan blobs（owner_id IS NULL & 老于 24h）；应该 0
   [AI]    Vercel Dashboard → Cron Jobs → 看最近 7 天 cron 执行历史
   [Human] 如果 cron 失败，看 Vercel logs 找原因
```

#### 何时跳过

- 内部工具 → 跳过 1-5 全部
- 自用 → 全跳过
- 你已经从 Day 1 接 §11 Phase 5 Stripe 的项目 → 1 + 5 必做，2/3/4 看用量决定

---

### 12.D Stripe / Monetization（开始收费）

> **触发条件**：§12.A UAT 通过 + §12.B 域名定型 + §12.C 硬化都做完 + 你确定要收费了。
> Day 1 就接 Stripe 的项目走的是 §11 Phase 5（rare），其它项目都在这里。

#### 步骤

```
[Human] 决定 grandfather 策略 —— 已经免费用着的用户怎么处理？
        - 选项 A：永久免费（"founding members"）—— vibe-reading 路线
        - 选项 B：宽限期（"6 个月内继续免费，之后 50% off"）
        - 选项 C：切断 + 提供 export（不推荐，伤口碑）
        提前决定。事后切非常被动。
[Human] 走 §6 Stripe 模块（模式 A credits 一次性 / 模式 B subscription 月付）
        实操步骤跟 Day 1 接 Stripe 完全一样：
        - Stripe Dashboard 建 Product → 复制 Price ID + Secret Key
        - 加到 Vercel env vars
[AI]    照 §6 写 /api/stripe/{checkout,webhook} + 前端付费按钮
[Human] Stripe test mode 付款实测（test card 4242 4242 4242 4242）
[Human] Stripe Dashboard → Webhooks → 用生产 URL 创建 endpoint
        → 复制 STRIPE_WEBHOOK_SECRET → Vercel env → Redeploy
[Human] 切到 Stripe live mode + 真实付一次（你自己用真卡 / 朋友试一次）
[AI]    写一封"开始收费"通知邮件给现有 free 用户（讲清 grandfather 政策）
[Human] 发邮件、更新 landing 加价格区
```

#### 已踩过的坑

- **没做 grandfather 决定就上线付费墙** —— 老用户登录看到突然要钱，差评率激增。修法：上线前明确通知 + 给 grandfather。
- **Stripe Webhook 漏配 / Secret 错** —— 付款成功但本地没收到 webhook → 数据库 credits 不增加 → 用户付了钱看不到。修法：test mode 付款 + 看 Webhook event log 必须看到 `checkout.session.completed` 事件才算 OK。
- **Live mode 第一笔忘了切** —— 测试用 test card，正式用真卡。Stripe Dashboard 右上角有个 "Test mode / Live mode" toggle，部署时确认是 Live。

#### 何时跳过 §12.D

- 永远开源免费（vibe-reading 短期就是）
- 已经在 §11 Phase 5 接过 Stripe（Day 1 付费项目）
- 项目 sunset，不接新用户
