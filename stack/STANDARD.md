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
- **Stripe 独立**：Phase 4，仅付费项目需要；MVP 可跳过
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

### Phase 3 — DB + Auth

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

### Phase 4 — Stripe（仅付费项目；MVP 无付费可跳过）

```
[Human]  Stripe Dashboard → 建 Product → 复制 Price ID + Secret Key → 加到 Vercel env vars
[AI]     写 /api/stripe/{checkout,webhook} + 前端付费按钮（照 §6 模式 A 或 B）
[Human]  Stripe test mode 付款实测（test card 4242 4242 4242 4242）
[Human]  Stripe Dashboard → Webhooks → 用生产 URL 创建 endpoint → 复制 STRIPE_WEBHOOK_SECRET
[Human]  加 STRIPE_WEBHOOK_SECRET 到 Vercel env → Redeploy
```

### Phase 5-N — 业务逻辑

按 `docs/implementation-guide.md` 的 Phase 顺序逐个做。每 Phase 完：

```
[AI]     git push
         (Vercel 自动 redeploy)
[Human]  线上 URL 实测本 Phase 新增功能（浏览器走一遍 user flow）
```
