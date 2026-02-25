# STANDARD.md — Indie Project Standard Stack

> 这份文档是每个新项目的**唯一参照**。
> Claude 写 proposal 和实现计划时，标准模块部分严格按照此文档，不自由发挥。
> 只有业务逻辑部分（数据 schema、AI 功能、第三方 API）才做定制。

**Last Updated**: February 2026  
**Based on**: AI Video Assistant + LaunchRadar (两个已验证的项目)

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

- Authentication → Providers → **Email**: 关闭 "Confirm email"（开发阶段）
- Authentication → Providers → **Google**: 填入 Client ID + Secret（从 Google Cloud Console 获取）
- Authentication → Providers → **GitHub**: 填入 Client ID + Secret（从 GitHub OAuth Apps 获取）
- Redirect URL 填：`https://your-project.vercel.app/auth/callback`

---

## 4. Database 模块（Prisma）

### 4.1 安全模型

**所有表 RLS DISABLED。安全靠 API 层保证。**

规则：每个 API route 第一行必须验证 session：
```typescript
const supabase = await createServerSupabaseClient()
const { data: { user } } = await supabase.auth.getUser()
if (!user) return new Response('Unauthorized', { status: 401 })
```
> 这条规则没有例外。忘记写 = 安全漏洞。

### 4.2 Prisma 初始化（Prisma v7 必须用 adapter）

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

**必须用 Supabase Transaction Pooler URL（port 6543）**，不用 Direct Connection（port 5432）。
Direct connection 在 serverless 环境会超时。

获取路径：Supabase Dashboard → Connect → Transaction pooler tab

```
DATABASE_URL=postgresql://postgres.[ref]:[PASSWORD]@aws-0-[region].pooler.supabase.com:6543/postgres
```

### 4.5 Build Command

```bash
npx prisma generate && next build
```

> Vercel Build Settings 里要改这个，否则 Prisma client 不会生成。

---

## 5. Vercel 部署

### 5.1 环境变量清单

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

```bash
git add .
git commit -m "description"
git push   # Vercel 自动 deploy main 分支
```

---

## 6. Stripe 模块

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

## 10. 新项目 Checklist

每次开新项目，按顺序操作：

```
□ npx create-next-app@latest my-project --typescript --tailwind --app
□ npx shadcn@latest init
□ npm install prisma @prisma/client @prisma/adapter-pg pg @types/pg @supabase/supabase-js @supabase/ssr stripe
□ 创建 Supabase 项目 → 复制 URL / anon key / service role key
□ 复制 Transaction Pooler URL → DATABASE_URL
□ 创建 lib/supabase/client.ts + server.ts + admin.ts（照 Section 3.1 原样复制）
□ 创建 lib/db/client.ts（照 Section 4.2 原样复制）
□ 创建 prisma/schema.prisma（照 Section 4.3，加上业务 model）
□ npx prisma db push
□ 创建 middleware.ts（照 Section 3.5）
□ 创建 app/auth/login + register + callback（照 Section 3.2-3.4）
□ Supabase Dashboard → 关闭 Email Confirmation
□ Supabase Dashboard → 开启 Google + GitHub OAuth（如需要）
□ 创建 Stripe 产品 → 复制 Price ID / Secret Key
□ 创建 app/api/stripe/checkout + webhook（选模式 A 或 B，照 Section 6）
□ 配置 Vercel → 填入所有环境变量（见 Section 5.1）
□ 修改 Build Command → npx prisma generate && next build
□ git push → 验证 Vercel 部署成功
□ 配置 Stripe Webhook（生产 URL）→ 更新 STRIPE_WEBHOOK_SECRET
```
