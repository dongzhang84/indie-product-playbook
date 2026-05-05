# AIfy — Implementation Guide

**Product**: AIfy — Personal Workflow AI-ification Diagnostic
**Stack**: Next.js 14 App Router + TypeScript + Tailwind + Shadcn/ui + Supabase (Auth + Postgres, Supabase-only) + React Flow + OpenAI gpt-4o-mini + Vercel
**Repo**: `github.com/dongzhang84/AIfy` (to be created, public, MIT)
**Last Updated**: 2026-05-05

> 业务逻辑和方法论在 [`ideas/AIfy.md`](../ideas/AIfy.md)。本文件只讲**怎么建**。
> Bootstrap 走 `bash stack/new-project.sh AIfy "AIfy"`，然后按 Phase 0 加 Next.js + Supabase 栈。
> 标准模块严格按 [`stack/STANDARD.md`](../stack/STANDARD.md)，**已偏离的地方**：用 Supabase-only 替代 Prisma（§4.6）；不做 Stripe（开源免费）；砍 GitHub OAuth（只 Email + Google）。

---

## ⚠️ Golden Rules

四条产品哲学的代码层 enforcement。开发过程不能妥协，PR review 拒绝任何违反。

**Rule 1 — 三档措辞固定，UI 字面量受锁定。**
🟢 "AI 替你做"、🟡 "AI 帮你做"、⚪ "你必须自己做" 是 user-facing 措辞。**不允许**改成 "可以 AI 化 / 人机协作 / 保留人工" 等工程内部表述。这些字符串集中在 `lib/copy/tiers.ts`，不允许散落到组件里。

**Rule 2 — Edit 限额（最多 2 次）在 API 层强制。**
不是 UI hint。`/api/reports/[id]/edit` 第一行检查 `edit_count >= 2 → 403`。即使前端 bug 让按钮一直可点，后端也拒绝。这条规则的产品意图是"主动帮用户摆脱完美主义陷阱"——必须可信。

**Rule 3 — 公开报告页（`/r/[slug]`）SSR、无 auth 要求。**
任何人有链接就能看，server-side 渲染（SEO + Twitter card）。这是产品唯一的增长机制，绝不能让登录墙挡在分享链接前面。

**Rule 4 — 诊断必须给所有节点打颜色。**
没有 "I don't know" 档。如果模型对某节点犹豫，prompt 要求它**必选**最接近的一档 + 在 reason 里说"边界情况"。产品的核心价值是**做出区分**——不区分的报告等于没用。

---

## Phase 0 — 项目初始化

### 0.1 Scaffold（走 new-project.sh + 加 Next.js 栈）

```bash
# 在 indie-product-playbook 根目录
bash stack/new-project.sh AIfy "AIfy"
cd ../AIfy

# Next.js + 依赖
npx create-next-app@latest . --typescript --tailwind --app --no-src-dir
npx shadcn@latest init

npm install \
  @supabase/supabase-js @supabase/ssr \
  @xyflow/react \
  openai \
  nanoid

npm install -D @types/node
```

> `new-project.sh` 已经把 docs/ 和 .github/workflows/ 配好了。Next.js 在已有目录中初始化时会问几个 prompt，全选默认即可。

### 0.2 目录结构

```
AIfy/
├── app/
│   ├── api/
│   │   ├── reports/
│   │   │   ├── route.ts                    ← POST 创建新报告
│   │   │   └── [id]/
│   │   │       ├── workflow/route.ts        ← AI 调用 1：生成 workflow
│   │   │       ├── edit/route.ts            ← 拖动 / 加减节点（max 2）
│   │   │       ├── diagnose/route.ts        ← AI 调用 2：3 档诊断
│   │   │       └── claim/route.ts           ← session → user 迁移
│   ├── auth/
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── callback/route.ts
│   ├── r/
│   │   └── [slug]/
│   │       ├── page.tsx                     ← 公开分享页（SSR）
│   │       └── opengraph-image.tsx          ← 动态 OG 图
│   ├── reports/
│   │   ├── new/page.tsx                     ← Step 1：textarea 输入
│   │   └── [id]/
│   │       ├── workflow/page.tsx            ← Step 2：React Flow 编辑
│   │       └── diagnose/page.tsx            ← Step 3：诊断报告
│   ├── library/page.tsx                     ← 用户报告历史（受保护）
│   ├── page.tsx                             ← Landing
│   └── layout.tsx
├── components/
│   ├── WorkflowEditor.tsx                   ← React Flow 包装
│   ├── DiagnosisCard.tsx                    ← 节点详情侧栏
│   ├── ShareButton.tsx
│   ├── LoginModal.tsx
│   └── ui/...
├── lib/
│   ├── supabase/{client,server,admin}.ts
│   ├── ai/
│   │   ├── workflow.ts                      ← AI 调用 1
│   │   ├── diagnose.ts                      ← AI 调用 2
│   │   └── prompts/
│   │       ├── workflow.md
│   │       └── diagnose.md
│   ├── copy/tiers.ts                        ← Rule 1 锁定字符串
│   ├── slug.ts
│   └── session.ts                           ← 匿名 session cookie
├── types/
│   ├── index.ts
│   └── db.ts                                ← supabase gen types 输出
├── middleware.ts
└── .env.local
```

### 0.3 环境变量

`.env.local`:

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# OpenAI
OPENAI_API_KEY=

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000

# 外部链接（无需集成）
NEXT_PUBLIC_CALENDLY_URL=https://cal.com/dongzhang/aify-30min
```

无 `DATABASE_URL`（Supabase-only）；无 Stripe；无 GitHub OAuth。

---

## Phase 1 — Landing + Step 1 输入页

### 1.1 Landing（`app/page.tsx`）

极简，单屏：

```tsx
export default function Landing() {
  return (
    <main className="mx-auto max-w-2xl px-6 py-24">
      <h1 className="text-4xl font-semibold">
        看清你的工作流，AI 帮你做哪些 / 你必须做哪些
      </h1>
      <p className="mt-4 text-lg text-slate-600">
        3-5 句话描述你平时怎么工作。我们画出流程图，告诉你哪些可以 AI 化、哪些必须自己做。
      </p>
      <Link href="/reports/new" className="mt-8 inline-block bg-black text-white px-6 py-3 rounded-lg">
        开始诊断
      </Link>
    </main>
  )
}
```

### 1.2 Step 1 输入页（`app/reports/new/page.tsx`）

```tsx
'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'

const PLACEHOLDERS = [
  "我是 indie dev，每天写代码、回邮件、刷 X、做 demo、写周报...",
  "我是产品经理，开会、写 PRD、看用户反馈、约访谈、跟工程师讨论...",
  "我是 freelance designer，找客户、做 brief、画 mock、来回改、出图...",
]

export default function NewReportPage() {
  const router = useRouter()
  const [text, setText] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const placeholder = PLACEHOLDERS[Math.floor(Math.random() * PLACEHOLDERS.length)]

  async function submit() {
    if (text.trim().length < 30) return
    setSubmitting(true)
    const res = await fetch('/api/reports', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ work_description: text.trim() }),
    })
    const { id } = await res.json()
    router.push(`/reports/${id}/workflow`)
  }

  return (
    <main className="mx-auto max-w-2xl px-6 py-16">
      <h2 className="text-2xl font-semibold">3-5 句话讲讲你平时怎么工作</h2>
      <p className="mt-2 text-sm text-slate-500">
        不分步、不追问、不强制结构化。写到流程级别，包含痛点。
      </p>
      <textarea
        rows={6}
        placeholder={placeholder}
        value={text}
        onChange={(e) => setText(e.target.value)}
        className="mt-6 w-full rounded-md border p-4 text-base"
      />
      <button
        disabled={submitting || text.trim().length < 30}
        onClick={submit}
        className="mt-4 bg-black text-white px-6 py-3 rounded-lg disabled:opacity-50"
      >
        {submitting ? '生成中…' : '画出我的流程图 →'}
      </button>
    </main>
  )
}
```

### 1.3 Tier copy 锁定（Rule 1）

`lib/copy/tiers.ts`：

```typescript
export const TIERS = {
  green: {
    label: 'AI 替你做',
    color: 'emerald',
    short: '你只需要 review 结果',
    emoji: '🟢',
  },
  yellow: {
    label: 'AI 帮你做',
    color: 'amber',
    short: '你定方向、AI 跑细节',
    emoji: '🟡',
  },
  gray: {
    label: '你必须自己做',
    color: 'zinc',
    short: '判断 / 关系 / 品味，不该外包',
    emoji: '⚪',
  },
} as const

export type Tier = keyof typeof TIERS
```

**所有 UI 文案从这里读。** 任何在组件里硬编码"可以 AI 化"等字样的 PR 一律拒绝。

---

## Phase 2 — Database Schema

Supabase Dashboard → SQL Editor 跑这段。所有表 RLS DISABLED（STANDARD §4.1，安全靠 API 层）。

```sql
create table reports (
  id uuid primary key default gen_random_uuid(),

  -- ownership
  owner_id uuid references auth.users(id) on delete cascade,
  session_id text,                                -- 登录前用 cookie 识别
  public_slug text unique not null
    default substring(md5(random()::text || clock_timestamp()::text) from 1 for 8),

  -- input
  work_description text not null check (char_length(work_description) >= 30),

  -- AI outputs (null until each stage completes)
  workflow_json jsonb,                            -- {nodes: [...], edges: [...]}
  diagnosis_json jsonb,                           -- {[node_id]: {tier, reason, tool, how}}

  -- edit tracking (Rule 2)
  edit_count int not null default 0
    check (edit_count >= 0 and edit_count <= 2),

  -- metadata
  created_at timestamptz default now(),
  finalized_at timestamptz                        -- when diagnosis_json was generated
);

create index on reports (owner_id);
create index on reports (session_id);
create index on reports (public_slug);
```

跑完：

```bash
npm run db:types
```

`package.json` 加：

```json
"scripts": {
  "db:types": "supabase gen types typescript --project-id <your-ref> > types/db.ts"
}
```

---

## Phase 3 — Auth (Email + Google, 闸门在 Step 3 → Step 4)

照 STANDARD §3 复制 `lib/supabase/{client,server,admin}.ts` + `app/auth/{login,register,callback}` + `middleware.ts`。**偏离**：

- 砍掉 GitHub OAuth（只保留 Email/Password + Google）
- 不创建 Profile 表（`auth.users` 直接用，AIfy 没有 user profile 数据）
- middleware 只保护 `/library`；`/`、`/reports/*`、`/r/*` 都不要求登录

### 3.1 Middleware

```typescript
// middleware.ts
const PROTECTED = ['/library']

export async function middleware(request: NextRequest) {
  const path = request.nextUrl.pathname
  if (!PROTECTED.some(p => path.startsWith(p))) return NextResponse.next()
  // ... 标准 STANDARD §3.5 auth 检查
}

export const config = {
  matcher: ['/library/:path*'],
}
```

### 3.2 Session cookie（登录前的匿名识别）

`lib/session.ts`：

```typescript
import { cookies } from 'next/headers'
import crypto from 'crypto'

const COOKIE = 'aify-session'

export async function getOrCreateSessionId(): Promise<string> {
  const jar = await cookies()
  const existing = jar.get(COOKIE)?.value
  if (existing) return existing
  const sid = crypto.randomUUID()
  jar.set(COOKIE, sid, {
    httpOnly: true, sameSite: 'lax',
    maxAge: 60 * 60 * 24 * 30,    // 30 天
    path: '/',
  })
  return sid
}
```

### 3.3 LoginModal（Step 3 → Step 4 闸门）

`components/LoginModal.tsx`：

```tsx
'use client'
import { createClient } from '@/lib/supabase/client'

export function LoginModal({ onSuccess, reportId }: Props) {
  const supabase = createClient()

  async function google() {
    await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback?next=/reports/${reportId}/diagnose?share=1`,
      }
    })
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center">
      <div className="bg-white rounded-lg p-8 max-w-md">
        <h2 className="text-xl font-semibold">最后一步：登录后才能分享</h2>
        <p className="mt-2 text-sm text-slate-600">
          你刚刚看到的诊断报告是匿名生成的。
          登录后，这份报告会归到你账户下，可以分享、可以稍后回来看。
          <br />
          <span className="text-xs text-slate-400">（这是我们唯一会要求你登录的时刻。）</span>
        </p>
        <button onClick={google} className="mt-6 w-full bg-black text-white py-2 rounded">
          用 Google 登录
        </button>
        {/* + Email/password 表单 */}
      </div>
    </div>
  )
}
```

### 3.4 Claim API（Session → User 迁移）

`app/api/reports/[id]/claim/route.ts`：

```typescript
export async function POST(request: Request, { params }: Props) {
  const supabase = await createServerSupabaseClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  const sessionId = await getSessionId()
  const { id } = await params

  const db = createAdminClient()
  await db.from('reports')
    .update({ owner_id: user.id, session_id: null })
    .eq('id', id)
    .eq('session_id', sessionId)
    .is('owner_id', null)

  return NextResponse.json({ ok: true })
}
```

### 3.5 Callback 支持 next 参数

`app/auth/callback/route.ts`：登录成功后回到 `next` 路径（默认 `/library`）。和 Vibe Reading 一致。

---

## Phase 4 — AI 调用 1：文本 → workflow JSON

### 4.1 Prompt（`lib/ai/prompts/workflow.md`）

```markdown
---
version: v1
purpose: extract a workflow graph from a free-form work description
---

The user describes how they work in plain language:

"{{work_description}}"

Extract their workflow as a directed graph of 5–10 work steps.

Rules:
- Each NODE is a single concrete activity using the user's own vocabulary (e.g. "写每周周报", "回邮件", "review PR", "和 designer 对 mock")
- Don't paraphrase abstractly ("planning phase" ❌; "和 PM 开 weekly" ✅)
- Don't invent steps the user didn't mention; stay close to their text
- EDGES connect sequential or causal steps (A leads to B)
- 5–10 nodes total; if the user described too many, pick the most representative ones

Return JSON only, matching the schema. No prose.
```

### 4.2 Generator（`lib/ai/workflow.ts`）

```typescript
import 'server-only'
import OpenAI from 'openai'

const SCHEMA = {
  type: 'object',
  required: ['nodes', 'edges'],
  additionalProperties: false,
  properties: {
    nodes: {
      type: 'array',
      minItems: 5,
      maxItems: 10,
      items: {
        type: 'object',
        required: ['id', 'label'],
        additionalProperties: false,
        properties: {
          id: { type: 'string' },
          label: { type: 'string', maxLength: 30 },
        }
      }
    },
    edges: {
      type: 'array',
      items: {
        type: 'object',
        required: ['from', 'to'],
        additionalProperties: false,
        properties: {
          from: { type: 'string' },
          to: { type: 'string' },
        }
      }
    }
  }
} as const

let cached: OpenAI | null = null
const openai = () => cached ?? (cached = new OpenAI())

export async function generateWorkflow(workDescription: string) {
  const promptTemplate = await loadPrompt('workflow.md')
  const prompt = promptTemplate.replace('{{work_description}}', workDescription)

  const res = await openai().chat.completions.create({
    model: 'gpt-4o-mini',
    response_format: {
      type: 'json_schema',
      json_schema: { name: 'workflow', strict: true, schema: SCHEMA },
    },
    temperature: 0.2,
    messages: [{ role: 'user', content: prompt }],
  })

  return JSON.parse(res.choices[0]?.message?.content ?? '{}')
}
```

### 4.3 API Route

`app/api/reports/[id]/workflow/route.ts`：

```typescript
export async function POST(request: Request, { params }: Props) {
  const { id } = await params
  const db = createAdminClient()

  const { data: report } = await db.from('reports').select('*').eq('id', id).single()
  if (!report) return NextResponse.json({ error: 'Not found' }, { status: 404 })

  // ownership check (session or user)
  const ok = await verifyOwnership(report)
  if (!ok) return NextResponse.json({ error: 'Forbidden' }, { status: 403 })

  // skip if already generated
  if (report.workflow_json) return NextResponse.json({ workflow: report.workflow_json })

  const workflow = await generateWorkflow(report.work_description)
  await db.from('reports').update({ workflow_json: workflow }).eq('id', id)

  return NextResponse.json({ workflow })
}
```

---

## Phase 5 — Step 2: React Flow Editor + 拖动编辑

### 5.1 WorkflowEditor 组件

`components/WorkflowEditor.tsx`：

```tsx
'use client'
import { ReactFlow, Background, Controls, useNodesState, useEdgesState } from '@xyflow/react'
import '@xyflow/react/dist/style.css'

export function WorkflowEditor({ workflow, editable, onSave, editsRemaining }: Props) {
  const [nodes, setNodes, onNodesChange] = useNodesState(layoutNodes(workflow.nodes))
  const [edges, setEdges, onEdgesChange] = useEdgesState(workflow.edges)
  const [pendingChanges, setPendingChanges] = useState(false)

  return (
    <div className="h-[600px] border rounded">
      <ReactFlow
        nodes={nodes} edges={edges}
        onNodesChange={(changes) => {
          if (!editable) return
          onNodesChange(changes)
          if (changes.some(c => c.type !== 'position')) setPendingChanges(true)
        }}
        onEdgesChange={editable ? onEdgesChange : undefined}
        nodesDraggable={editable}
      >
        <Background /> <Controls />
      </ReactFlow>

      {editable && (
        <div className="flex items-center gap-3 mt-3">
          <span className="text-sm text-slate-500">
            还能改 {editsRemaining} 次
          </span>
          <button
            disabled={!pendingChanges || editsRemaining === 0}
            onClick={() => onSave({ nodes, edges })}
          >
            保存修改
          </button>
        </div>
      )}
    </div>
  )
}

function layoutNodes(rawNodes: any[]) {
  // simple top-to-bottom layout; React Flow doesn't auto-layout
  return rawNodes.map((n, i) => ({
    id: n.id,
    data: { label: n.label },
    position: { x: 200, y: i * 100 },
  }))
}
```

### 5.2 Step 2 页面

`app/reports/[id]/workflow/page.tsx`：

```tsx
'use client'
export default function WorkflowPage({ params }: Props) {
  const { id } = use(params)
  const [workflow, setWorkflow] = useState(null)
  const [editsUsed, setEditsUsed] = useState(0)

  useEffect(() => {
    fetch(`/api/reports/${id}/workflow`, { method: 'POST' })
      .then(r => r.json())
      .then(d => setWorkflow(d.workflow))
  }, [id])

  async function handleSave(newWorkflow) {
    const res = await fetch(`/api/reports/${id}/edit`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ workflow: newWorkflow }),
    })
    if (res.status === 403) { alert('已用完 2 次修改'); return }
    setEditsUsed(prev => prev + 1)
    setWorkflow(newWorkflow)
  }

  if (!workflow) return <p>正在生成你的流程图…</p>

  return (
    <main className="mx-auto max-w-4xl px-6 py-8">
      <h2 className="text-2xl font-semibold">这是你的工作流</h2>
      <p className="text-slate-500 mt-2">
        看一眼对不对。可以调整最多 2 次（拖动 / 删除节点）。差不多就行——不需要 100% 准确。
      </p>

      <WorkflowEditor
        workflow={workflow}
        editable={true}
        editsRemaining={2 - editsUsed}
        onSave={handleSave}
      />

      <button onClick={() => router.push(`/reports/${id}/diagnose`)} className="mt-6 bg-black text-white px-6 py-3 rounded">
        就这样，继续分析 →
      </button>
    </main>
  )
}
```

### 5.3 Edit API (Rule 2 enforcement)

`app/api/reports/[id]/edit/route.ts`：

```typescript
export async function POST(request: Request, { params }: Props) {
  const { id } = await params
  const { workflow } = await request.json()
  const db = createAdminClient()

  const { data: report } = await db.from('reports').select('edit_count').eq('id', id).single()
  if (!report) return NextResponse.json({ error: 'Not found' }, { status: 404 })

  // Rule 2: hard limit
  if (report.edit_count >= 2) {
    return NextResponse.json({ error: 'Edit limit reached' }, { status: 403 })
  }

  await db.from('reports')
    .update({
      workflow_json: workflow,
      edit_count: report.edit_count + 1,
    })
    .eq('id', id)

  return NextResponse.json({ ok: true, edit_count: report.edit_count + 1 })
}
```

---

## Phase 6 — AI 调用 2: 诊断

### 6.1 Prompt（`lib/ai/prompts/diagnose.md`）

```markdown
---
version: v1
---

User's work description:
"{{work_description}}"

User's workflow (after their edits):
{{workflow_json}}

For EACH node in the workflow, classify it into ONE tier:

- "green" (AI 替你做): the AI can do this end-to-end with current tools (2026). User just reviews the output. Examples: 写代码骨架, 翻译文档, 总结会议录音, 改格式.

- "yellow" (AI 帮你做): human-in-the-loop. User sets the direction or makes the key call; AI handles drafting / details. Examples: 写产品需求文档（人定 what, AI 写 how）, 给客户写邮件（人定 tone, AI 出文字）.

- "gray" (你必须自己做): this depends on judgment, relationships, taste, or live presence. Outsourcing destroys the value. Examples: 跟团队建立信任, 决定是否炒员工, 在投资人面前 pitch, 品鉴 design 美感.

For each node, return:
- tier: "green" | "yellow" | "gray"
- reason: ONE sentence explaining the verdict (≤ 60 chars)
- tool: ONE specific tool to use (e.g. "Cursor", "Claude", "Notion AI"); use "—" for gray
- how: ONE sentence on how to use it / why it's human-only (≤ 80 chars)

Critical: EVERY node must get a tier. No "I don't know" — pick the closest match and note "boundary case" in reason if unclear.

Return JSON keyed by node id.
```

### 6.2 Generator + API

类似 Phase 4 结构。Schema 强制每个 node id 都有 `{tier, reason, tool, how}`。完成后 `update reports set diagnosis_json = $, finalized_at = now()`.

---

## Phase 7 — Step 3: 报告 UI

`app/reports/[id]/diagnose/page.tsx`:

```tsx
'use client'
export default function DiagnosePage({ params }: Props) {
  const { id } = use(params)
  const [report, setReport] = useState(null)
  const [showLogin, setShowLogin] = useState(false)

  useEffect(() => {
    fetch(`/api/reports/${id}/diagnose`, { method: 'POST' })
      .then(r => r.json())
      .then(setReport)
  }, [id])

  if (!report) return <p>诊断中…</p>

  // Color nodes by tier
  const coloredNodes = report.workflow.nodes.map(n => {
    const verdict = report.diagnosis[n.id]
    return {
      id: n.id,
      data: { label: n.label, ...verdict },
      style: { borderColor: TIERS[verdict.tier].color, borderWidth: 3 },
    }
  })

  return (
    <main className="mx-auto max-w-5xl px-6 py-8">
      <h2 className="text-2xl font-semibold">你的 AI 化诊断</h2>
      <TierLegend />
      <WorkflowEditor workflow={{ nodes: coloredNodes, edges: report.workflow.edges }} editable={false} />

      <NodeDetailsList diagnosis={report.diagnosis} workflow={report.workflow} />

      <div className="mt-8 flex gap-4">
        <button onClick={() => setShowLogin(true)} className="bg-black text-white px-6 py-3 rounded">
          📤 分享我的诊断
        </button>
        <a href={process.env.NEXT_PUBLIC_CALENDLY_URL} target="_blank" className="border px-6 py-3 rounded">
          🗣️ 和创始人聊聊
        </a>
      </div>

      {showLogin && (
        <LoginModal
          reportId={id}
          onSuccess={async () => {
            await fetch(`/api/reports/${id}/claim`, { method: 'POST' })
            const slug = await fetch(`/api/reports/${id}`).then(r => r.json()).then(d => d.public_slug)
            router.push(`/r/${slug}`)
          }}
        />
      )}
    </main>
  )
}

function TierLegend() {
  return (
    <div className="flex gap-6 my-6 text-sm">
      {Object.entries(TIERS).map(([key, t]) => (
        <div key={key} className="flex items-center gap-2">
          <span>{t.emoji}</span>
          <span className="font-medium">{t.label}</span>
          <span className="text-slate-500">— {t.short}</span>
        </div>
      ))}
    </div>
  )
}
```

`NodeDetailsList` 是一个可点开的列表，每个节点显示 reason + tool + how。

---

## Phase 8 — Step 4: 分享 + 公开页（Rule 3）

### 8.1 公开页（SSR，不要 auth）

`app/r/[slug]/page.tsx`:

```tsx
import { createAdminClient } from '@/lib/supabase/admin'

export default async function PublicReportPage({ params }: Props) {
  const { slug } = await params
  const db = createAdminClient()
  const { data: report } = await db.from('reports').select('*').eq('public_slug', slug).single()
  if (!report || !report.diagnosis_json) notFound()

  // 只读 React Flow + 节点详情
  return (
    <main className="mx-auto max-w-5xl px-6 py-12">
      <header>
        <h1 className="text-3xl font-semibold">"{firstSentence(report.work_description)}"</h1>
        <p className="text-slate-500">的 AI 化诊断</p>
      </header>

      <TierLegend />
      <ReadOnlyWorkflow workflow={report.workflow_json} diagnosis={report.diagnosis_json} />
      <NodeDetailsList diagnosis={report.diagnosis_json} workflow={report.workflow_json} />

      <section className="mt-12 border-t pt-8">
        <h3 className="text-xl">想给自己也来一份？</h3>
        <Link href="/" className="bg-black text-white px-6 py-3 rounded inline-block mt-4">
          AIfy 我的工作 →
        </Link>
      </section>
    </main>
  )
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params
  const db = createAdminClient()
  const { data: report } = await db.from('reports').select('work_description, diagnosis_json').eq('public_slug', slug).single()

  const tally = countTiers(report?.diagnosis_json)
  return {
    title: `AI 化诊断：${truncate(report?.work_description, 30)} | AIfy`,
    description: `🟢 ${tally.green} · 🟡 ${tally.yellow} · ⚪ ${tally.gray}`,
    openGraph: { /* ... */ },
    twitter: { card: 'summary_large_image' },
  }
}
```

### 8.2 OG 图（动态生成）

`app/r/[slug]/opengraph-image.tsx`：

```tsx
import { ImageResponse } from 'next/og'

export const runtime = 'edge'
export const size = { width: 1200, height: 630 }

export default async function og({ params }) {
  const { slug } = params
  const db = createAdminClient()
  const { data: report } = await db.from('reports').select('work_description, diagnosis_json').eq('public_slug', slug).single()

  const tally = countTiers(report.diagnosis_json)

  return new ImageResponse(
    <div style={{ /* big card with: */ }}>
      <h1>AIfy 诊断</h1>
      <p>"{truncate(report.work_description, 80)}"</p>
      <div style={{ display: 'flex', gap: 32, fontSize: 80 }}>
        <span>🟢 {tally.green}</span>
        <span>🟡 {tally.yellow}</span>
        <span>⚪ {tally.gray}</span>
      </div>
      <small>aify.app/r/{slug}</small>
    </div>,
    size,
  )
}
```

---

## Phase 9 — `/library` 用户报告历史

`app/library/page.tsx` (受 middleware 保护):

```tsx
export default async function LibraryPage() {
  const supabase = await createServerSupabaseClient()
  const { data: { user } } = await supabase.auth.getUser()

  const db = createAdminClient()
  const { data: reports } = await db.from('reports')
    .select('id, work_description, public_slug, diagnosis_json, created_at')
    .eq('owner_id', user!.id)
    .order('created_at', { ascending: false })

  return (
    <main className="mx-auto max-w-3xl px-6 py-12">
      <h1 className="text-2xl font-semibold">我的诊断历史</h1>
      <ul className="mt-6 space-y-3">
        {reports?.map(r => {
          const tally = countTiers(r.diagnosis_json)
          return (
            <li key={r.id} className="border rounded p-4 flex justify-between">
              <div>
                <p className="font-medium">{truncate(r.work_description, 60)}</p>
                <p className="text-sm text-slate-500 mt-1">
                  🟢 {tally.green} · 🟡 {tally.yellow} · ⚪ {tally.gray} ·
                  {timeAgo(r.created_at)}
                </p>
              </div>
              <Link href={`/r/${r.public_slug}`} className="text-blue-600">查看 →</Link>
            </li>
          )
        })}
      </ul>
    </main>
  )
}
```

刻意简洁——spec §4 强调"不为留存优化服务"。无搜索、无筛选、无统计图表。

---

## Phase 10 — Calendly + Vercel 部署

### 10.1 Calendly

`NEXT_PUBLIC_CALENDLY_URL` 环境变量直接外链，不嵌 widget（保持页面轻）。

### 10.2 Vercel

- Settings → Environment Variables 填入 Phase 0.3 列出的所有
- Build Command: 默认 `next build`（Supabase-only，**不要** `prisma generate`）
- Domain: 先用 `aify.vercel.app`；验证后再买 `aify.app` / `aify.dev`
- Supabase Dashboard → Auth → URL Configuration 加生产 callback URL
- Google Cloud Console → OAuth credentials Authorized redirect URIs 加 Supabase callback

### 10.3 OG 图测试

部署后用 https://www.opengraph.xyz/ 输入 `aify.app/r/<slug>` 看 Twitter / Facebook 卡片。

---

## 常见坑

| 坑 | 原因 | 解法 |
|----|------|------|
| React Flow 节点初始位置全堆一起 | 默认不带 layout | 用简单 top-to-bottom 算法 (`y = index * 100`)，或装 `dagre` 包做自动布局 |
| Edit count 被前端绕过 | 只在 UI 隐藏按钮 | Rule 2: API 层硬检查 `edit_count >= 2 → 403` |
| OG 图渲染 timeout | edge runtime 慢 | `runtime = 'edge'` + 提前查 DB；不要在 og 里跑额外 AI |
| Public slug 冲突 | 8 字符 md5 截取理论上有碰撞 | DB column `unique`; 失败时重试 |
| Login 后丢失报告上下文 | callback redirect 默认 `/library` | callback 用 `?next=/reports/[id]/diagnose?share=1` 参数 |
| Tier 字符串散在组件里 | 直接 hardcode 方便 | Rule 1: 全部 import from `lib/copy/tiers.ts`，PR review 检查 |
| Diagnosis 模型给"未知"档 | prompt 没强制三选一 | 加 schema enum `["green","yellow","gray"]` strict; prompt 明说不允许 "unknown" |
| Workflow 节点过多 / 过少 | 模型不稳定 | schema `minItems: 5, maxItems: 10`；超出 retry |

---

## 环境变量清单

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# OpenAI
OPENAI_API_KEY=

# App
NEXT_PUBLIC_APP_URL=

# Calendly
NEXT_PUBLIC_CALENDLY_URL=
```

无 `DATABASE_URL`（Supabase-only）；无 Stripe；无 Resend（v0.1 不发邮件）。

---

## 新项目 Checklist

```
□ bash stack/new-project.sh AIfy "AIfy"
□ cd ../AIfy && npx create-next-app . --typescript --tailwind --app
□ npx shadcn@latest init
□ npm i @supabase/supabase-js @supabase/ssr @xyflow/react openai nanoid
□ Supabase 项目创建 + 拷 keys
□ Supabase Dashboard 关闭 Email Confirmation
□ Supabase Dashboard 开启 Google OAuth
□ Phase 2 SQL 跑 reports 建表
□ npm run db:types 生成类型
□ Phase 1: Landing + Step 1 输入页 + tier copy lock
□ Phase 3: lib/supabase/* + middleware (只 protect /library)
□ Phase 3: LoginModal + claim API + session.ts
□ Phase 4: workflow prompt + generator + API
□ Phase 5: WorkflowEditor + Step 2 页面 + Rule 2 edit API
□ Phase 6: diagnose prompt + generator + API
□ Phase 7: Step 3 报告页 + TierLegend + NodeDetailsList
□ Phase 8: /r/[slug] 公开页 SSR + OG 图
□ Phase 9: /library 历史页
□ Phase 10: Vercel 配置 + 部署 + OG 卡片测试
□ 自测：从 / 到 /r/[slug] 走通完整流程，分享链接给朋友看
```

---

## 成功判定

参照 `ideas/AIfy.md §七`：

**v0.1（4 周内）**：
- 自己用 1 次跑通完整流程，把分享链接发到 X 看反应
- 5-10 个朋友试用，看完成率 + 分享率
- **重点看**：分享率（分享按钮点击 / 看到报告）。低于 10% → 报告内容不够分享，回去打磨；> 30% → 产品成立

不看 DAU / WAU / 留存。spec §七 明确放弃这些。

---

## Sprint Summary

_This section will be auto-updated by the sync-from-projects workflow once the repo is created._
