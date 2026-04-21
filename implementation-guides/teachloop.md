# AceRocket B2B — Implementation Guide
## AI-Powered Teaching Loop for SAT Math & AP Calculus Tutoring Centers

> Single source of truth for development. Follow phases in order. No skipping steps.
> Business logic customization is in each Phase's dedicated sections.

**Last Updated**: March 2026
**Stack**: Next.js 14 + TypeScript + Firebase + Tailwind + Shadcn/ui

---

## Tech Stack

| Layer | Choice | Notes |
|-------|--------|-------|
| Framework | Next.js 14 (App Router) | No Pages Router |
| Language | TypeScript | strict mode |
| Styling | Tailwind CSS + Shadcn/ui | |
| Auth | Firebase Auth | Email + Google |
| Database | Firebase Firestore | Structured data: questions, students, sessions |
| Realtime | Firebase Realtime Database | Live session performance tracking |
| AI | OpenAI GPT-4o-mini | Topic tagging |
| File Storage | Firebase Storage | PDF / image uploads |
| PDF Parsing | pdf-parse + Vision API | Extract question text |
| Payments | Stripe (Subscription) | Monthly billing |
| Deployment | Vercel | Hobby plan to start |

---

## Project Structure

```
teachloop/
├── app/
│   ├── api/
│   │   ├── stripe/
│   │   │   ├── checkout/route.ts
│   │   │   └── webhook/route.ts
│   │   ├── questions/
│   │   │   ├── upload/route.ts        ← PDF upload + AI tagging
│   │   │   └── tag/route.ts           ← Manual tag override
│   │   ├── sessions/
│   │   │   ├── create/route.ts        ← Create session record
│   │   │   └── performance/route.ts   ← Log student performance
│   │   ├── students/
│   │   │   └── analysis/route.ts      ← Update mastery profile
│   │   └── homework/
│   │       └── recommend/route.ts     ← Recommend homework questions
│   ├── auth/
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   ├── dashboard/
│   │   ├── page.tsx                   ← Org overview
│   │   ├── questions/page.tsx         ← Question bank
│   │   ├── students/page.tsx          ← Student list
│   │   ├── sessions/
│   │   │   ├── page.tsx               ← Session history
│   │   │   └── [id]/page.tsx          ← Session detail
│   │   └── homework/page.tsx          ← Homework assignments
│   ├── page.tsx                       ← Landing page (build first)
│   └── layout.tsx
├── components/
│   ├── landing/
│   │   ├── Hero.tsx
│   │   ├── Problem.tsx
│   │   ├── Solution.tsx
│   │   ├── HowItWorks.tsx
│   │   ├── Pricing.tsx
│   │   └── CTA.tsx
│   ├── dashboard/
│   │   ├── QuestionUploader.tsx
│   │   ├── QuestionTable.tsx
│   │   ├── StudentProfile.tsx
│   │   ├── SessionLogger.tsx
│   │   └── HomeworkPanel.tsx
│   └── shared/
│       ├── Header.tsx
│       └── Sidebar.tsx
├── lib/
│   ├── firebase/
│   │   ├── client.ts                  ← Browser-side Firebase
│   │   ├── admin.ts                   ← Server-side Firebase Admin
│   │   └── auth.ts                    ← Auth helpers
│   ├── ai/
│   │   ├── tagger.ts                  ← GPT-4o-mini topic tagging
│   │   └── recommender.ts             ← Pure algorithm homework recommendation
│   └── pdf/
│       └── parser.ts                  ← PDF parsing logic
├── types/
│   └── index.ts                       ← All TypeScript type definitions
├── middleware.ts                       ← Route protection
└── .env.local
```

---

## Phase 0: Project Initialization

```bash
npx create-next-app@latest teachloop --typescript --tailwind --app
cd teachloop
npx shadcn@latest init

# Firebase
npm install firebase firebase-admin

# AI + PDF
npm install openai pdf-parse
npm install -D @types/pdf-parse

# Stripe
npm install stripe

# Utilities
npm install lucide-react clsx
```

**.env.local**
```bash
# Firebase Client
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
NEXT_PUBLIC_FIREBASE_DATABASE_URL=

# Firebase Admin (server-side only)
FIREBASE_ADMIN_PROJECT_ID=
FIREBASE_ADMIN_CLIENT_EMAIL=
FIREBASE_ADMIN_PRIVATE_KEY=             ← See Phase 2 for newline handling

# OpenAI
OPENAI_API_KEY=

# Stripe
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PRICE_STARTER=
STRIPE_PRICE_GROWTH=
STRIPE_PRICE_PRO=

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

---

## Phase 1: Landing Page (Build First — Highest Priority)

> Build the landing page before any dashboard work.
> It can be shown to owners immediately for feedback, before a single line of backend code is written.

### 1.1 Page Structure

`app/page.tsx` renders these components in order:

```
Hero          ← One-line value proposition + CTA button
Problem       ← Three pain points
Solution      ← Four-step teaching loop diagram
HowItWorks    ← Feature breakdown
Pricing       ← Pricing table
CTA           ← Bottom call to action
```

### 1.2 Hero Component

```tsx
// components/landing/Hero.tsx
export function Hero() {
  return (
    <section>
      <h1>Homework assigned automatically — right after class ends.</h1>
      <p>
        AceRocket helps SAT Math and AP Calculus tutoring centers
        track each student's performance per session, analyze mastery
        by topic, and recommend the right homework from your own question bank.
      </p>
      <a href="/auth/register">Start Free 30-Day Trial</a>
      <a href="#how-it-works">See How It Works</a>
    </section>
  )
}
```

### 1.3 Problem Component

```tsx
// components/landing/Problem.tsx
const problems = [
  {
    title: "Homework is guesswork",
    desc: "After every session, tutors manually hunt through PDFs to find review questions. No system, no data — just experience."
  },
  {
    title: "No visibility into student gaps",
    desc: "Without per-topic tracking, tutors can't know exactly where each student is struggling until it's test day."
  },
  {
    title: "Owners can't see what's happening",
    desc: "Center owners have no real-time view of student progress. Everything depends on the tutor's verbal update."
  }
]
```

### 1.4 HowItWorks Component

```tsx
// components/landing/HowItWorks.tsx
const steps = [
  {
    step: "01",
    title: "Upload Your Questions",
    desc: "Upload PDF or image worksheets. AI automatically identifies each question, tags the topic and difficulty. You can edit any tag manually."
  },
  {
    step: "02",
    title: "Log the Session",
    desc: "After class, mark which questions were covered and which ones the student got wrong. Takes 30 seconds."
  },
  {
    step: "03",
    title: "Get Mastery Analysis",
    desc: "The system builds a per-topic mastery profile for each student based on every session, updated automatically after each class."
  },
  {
    step: "04",
    title: "Assign Targeted Homework",
    desc: "Based on the student's current level, the system recommends the most relevant questions from your own question bank. One click to assign."
  }
]
```

### 1.5 Pricing Component

```tsx
// components/landing/Pricing.tsx
const plans = [
  {
    name: "Starter",
    price: "$99",
    period: "/month",
    students: "Up to 15 students",
    features: [
      "Unlimited question uploads",
      "AI topic tagging",
      "Session logging",
      "Homework recommendations"
    ]
  },
  {
    name: "Growth",
    price: "$199",
    period: "/month",
    students: "Up to 50 students",
    features: [
      "Everything in Starter",
      "Per-topic mastery analytics dashboard",
      "Multiple tutor accounts"
    ],
    highlighted: true
  }
]
```

---

## Phase 2: Firebase Initialization

### 2.1 Firebase Client (Browser-side)

```typescript
// lib/firebase/client.ts
import { initializeApp, getApps } from 'firebase/app'
import { getAuth } from 'firebase/auth'
import { getFirestore } from 'firebase/firestore'
import { getDatabase } from 'firebase/database'
import { getStorage } from 'firebase/storage'

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
  databaseURL: process.env.NEXT_PUBLIC_FIREBASE_DATABASE_URL,
}

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0]

export const auth = getAuth(app)
export const db = getFirestore(app)       // Firestore
export const rtdb = getDatabase(app)      // Realtime Database
export const storage = getStorage(app)
```

### 2.2 Firebase Admin (Server-side)

```typescript
// lib/firebase/admin.ts
import { initializeApp, getApps, cert } from 'firebase-admin/app'
import { getFirestore } from 'firebase-admin/firestore'
import { getDatabase } from 'firebase-admin/database'
import { getAuth } from 'firebase-admin/auth'

// ⚠️ Private key newlines are stripped in Vercel env vars
// In Vercel dashboard: paste the raw key with actual newlines
const privateKey = process.env.FIREBASE_ADMIN_PRIVATE_KEY?.replace(/\\n/g, '\n')

if (!getApps().length) {
  initializeApp({
    credential: cert({
      projectId: process.env.FIREBASE_ADMIN_PROJECT_ID,
      clientEmail: process.env.FIREBASE_ADMIN_CLIENT_EMAIL,
      privateKey,
    }),
    databaseURL: process.env.NEXT_PUBLIC_FIREBASE_DATABASE_URL,
  })
}

export const adminDb = getFirestore()
export const adminRtdb = getDatabase()
export const adminAuth = getAuth()
```

### 2.3 Auth Helper (Server-side Session Verification)

```typescript
// lib/firebase/auth.ts
import { adminAuth } from './admin'
import { cookies } from 'next/headers'

// Call this as the first line of every API route
export async function verifySession(): Promise<string | null> {
  const cookieStore = await cookies()
  const token = cookieStore.get('firebase-token')?.value
  if (!token) return null

  try {
    const decoded = await adminAuth.verifyIdToken(token)
    return decoded.uid
  } catch {
    return null
  }
}
```

> **Standard API Route pattern — no exceptions:**
> ```typescript
> const uid = await verifySession()
> if (!uid) return new Response('Unauthorized', { status: 401 })
> ```

---

## Phase 3: Auth Module

### 3.1 Firebase Console Setup

- Authentication → Sign-in method → Enable **Email/Password**
- Authentication → Sign-in method → Enable **Google**
- Authentication → Settings → Authorized domains → Add `your-project.vercel.app`

### 3.2 Login Page

```typescript
// app/auth/login/page.tsx
'use client'
import { signInWithEmailAndPassword, signInWithPopup, GoogleAuthProvider } from 'firebase/auth'
import { auth } from '@/lib/firebase/client'

// Email login
const userCredential = await signInWithEmailAndPassword(auth, email, password)
const token = await userCredential.user.getIdToken()
document.cookie = `firebase-token=${token}; path=/; max-age=3600`
router.push('/dashboard')

// Google login
const provider = new GoogleAuthProvider()
const result = await signInWithPopup(auth, provider)
const token = await result.user.getIdToken()
document.cookie = `firebase-token=${token}; path=/; max-age=3600`
router.push('/dashboard')
```

UI strings:
```tsx
<h1>Sign in to AceRocket</h1>
<label>Email address</label>
<label>Password</label>
<button>Sign In</button>
<button>Continue with Google</button>
<p>Don't have an account? <a href="/auth/register">Sign up free</a></p>
```

### 3.3 Register Page

```typescript
// app/auth/register/page.tsx
import { createUserWithEmailAndPassword } from 'firebase/auth'
import { doc, setDoc } from 'firebase/firestore'
import { auth, db } from '@/lib/firebase/client'

const userCredential = await createUserWithEmailAndPassword(auth, email, password)
const user = userCredential.user

// Create organization profile in Firestore
await setDoc(doc(db, 'organizations', user.uid), {
  email: user.email,
  name: orgName,
  plan: 'trial',
  trialEndsAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
  createdAt: new Date(),
})

const token = await user.getIdToken()
document.cookie = `firebase-token=${token}; path=/; max-age=3600`
router.push('/dashboard')
```

UI strings:
```tsx
<h1>Create your AceRocket account</h1>
<label>Organization name</label>
<label>Email address</label>
<label>Password</label>
<button>Start Free Trial</button>
<p>Already have an account? <a href="/auth/login">Sign in</a></p>
<p>Free for 30 days. No credit card required.</p>
```

### 3.4 Middleware — Route Protection

```typescript
// middleware.ts
import { NextResponse, type NextRequest } from 'next/server'

const PROTECTED = ['/dashboard']
const AUTH_PAGES = ['/auth/login', '/auth/register']

export function middleware(request: NextRequest) {
  const token = request.cookies.get('firebase-token')?.value
  const path = request.nextUrl.pathname

  if (!token && PROTECTED.some(r => path.startsWith(r))) {
    return NextResponse.redirect(new URL('/auth/login', request.url))
  }

  if (token && AUTH_PAGES.includes(path)) {
    return NextResponse.redirect(new URL('/dashboard', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|api).*)'],
}
```

---

## Phase 4: Firestore Data Structure

> **Rule**: Firestore stores structured data. Realtime Database stores live session performance.

### 4.1 Firestore Collections

```
organizations/{orgId}
  - email: string
  - name: string
  - plan: 'trial' | 'starter' | 'growth' | 'pro'
  - trialEndsAt: timestamp
  - createdAt: timestamp

organizations/{orgId}/questions/{questionId}
  - content: string
  - imageUrl: string
  - subject: 'SAT_MATH' | 'AP_CALC'
  - topic: string
      SAT_MATH: 'Linear Equations' | 'Systems of Equations' | 'Quadratics' |
                'Functions' | 'Geometry' | 'Trigonometry' | 'Statistics' |
                'Probability' | 'Word Problems'
      AP_CALC:  'Limits' | 'Derivatives' | 'Applications of Derivatives' |
                'Integrals' | 'Applications of Integrals' | 'FRQ'
  - difficulty: 'Easy' | 'Medium' | 'Hard'
  - aiTagged: boolean
  - createdAt: timestamp

organizations/{orgId}/students/{studentId}
  - name: string
  - createdAt: timestamp
  - topicMastery: { [topic: string]: number }   ← 0–100 per topic
  - lastUpdated: timestamp

organizations/{orgId}/sessions/{sessionId}
  - date: timestamp
  - studentId: string
  - teacherNote: string
  - createdAt: timestamp
  - homeworkQuestionIds: string[]

organizations/{orgId}/sessions/{sessionId}/performance/{questionId}
  - correct: boolean
  - topic: string
  - difficulty: string
```

### 4.2 Realtime Database Structure

```
sessions/
  {sessionId}/
    status: 'active' | 'completed'
    studentId: string
    orgId: string
    questions/
      {questionId}/
        correct: boolean | null
        answeredAt: timestamp
```

### 4.3 TypeScript Types

```typescript
// types/index.ts

export type Subject = 'SAT_MATH' | 'AP_CALC'

export type SATTopic =
  | 'Linear Equations'
  | 'Systems of Equations'
  | 'Quadratics'
  | 'Functions'
  | 'Geometry'
  | 'Trigonometry'
  | 'Statistics'
  | 'Probability'
  | 'Word Problems'

export type APCalcTopic =
  | 'Limits'
  | 'Derivatives'
  | 'Applications of Derivatives'
  | 'Integrals'
  | 'Applications of Integrals'
  | 'FRQ'

export type Topic = SATTopic | APCalcTopic
export type Difficulty = 'Easy' | 'Medium' | 'Hard'
export type Plan = 'trial' | 'starter' | 'growth' | 'pro'

export interface Question {
  id: string
  content: string
  imageUrl?: string
  subject: Subject
  topic: Topic
  difficulty: Difficulty
  aiTagged: boolean
  createdAt: Date
}

export interface Student {
  id: string
  name: string
  topicMastery: Partial<Record<Topic, number>>
  lastUpdated: Date
}

export interface Session {
  id: string
  date: Date
  studentId: string
  teacherNote?: string
  homeworkQuestionIds: string[]
  performance: Record<string, { correct: boolean; topic: Topic; difficulty: Difficulty }>
}

export interface Organization {
  id: string
  email: string
  name: string
  plan: Plan
  trialEndsAt: Date
}
```

---

## Phase 5: Core AI Features

### 5.1 PDF Upload + AI Topic Tagging API

```typescript
// app/api/questions/upload/route.ts
import { verifySession } from '@/lib/firebase/auth'
import { adminDb } from '@/lib/firebase/admin'
import { tagQuestions } from '@/lib/ai/tagger'
import { parseQuestionsFromPDF } from '@/lib/pdf/parser'

export async function POST(request: Request) {
  const uid = await verifySession()
  if (!uid) return new Response('Unauthorized', { status: 401 })

  const formData = await request.formData()
  const file = formData.get('file') as File
  const subject = formData.get('subject') as 'SAT_MATH' | 'AP_CALC'

  const buffer = Buffer.from(await file.arrayBuffer())
  const questions = await parseQuestionsFromPDF(buffer)
  const taggedQuestions = await tagQuestions(questions, subject)

  const batch = adminDb.batch()
  taggedQuestions.forEach(q => {
    const ref = adminDb
      .collection('organizations').doc(uid)
      .collection('questions').doc()
    batch.set(ref, { ...q, aiTagged: true, createdAt: new Date() })
  })
  await batch.commit()

  return Response.json({ success: true, count: taggedQuestions.length })
}
```

### 5.2 AI Topic Tagging Logic

```typescript
// lib/ai/tagger.ts
import OpenAI from 'openai'

const client = new OpenAI()

const SAT_TOPICS = [
  'Linear Equations', 'Systems of Equations', 'Quadratics',
  'Functions', 'Geometry', 'Trigonometry', 'Statistics',
  'Probability', 'Word Problems'
]

const AP_CALC_TOPICS = [
  'Limits', 'Derivatives', 'Applications of Derivatives',
  'Integrals', 'Applications of Integrals', 'FRQ'
]

export async function tagQuestions(
  questions: string[],
  subject: 'SAT_MATH' | 'AP_CALC'
) {
  const topics = subject === 'SAT_MATH' ? SAT_TOPICS : AP_CALC_TOPICS
  const subjectLabel = subject === 'SAT_MATH' ? 'SAT Math' : 'AP Calculus'

  const prompt = `
You are an expert ${subjectLabel} question analyst.

For each question below, determine:
1. topic: choose the single best match from: ${topics.join(', ')}
2. difficulty: Easy, Medium, or Hard

Questions:
${questions.map((q, i) => `Question ${i + 1}: ${q}`).join('\n\n')}

Return ONLY a JSON array in this exact format, no other text:
[
  { "index": 0, "topic": "topic name", "difficulty": "Easy|Medium|Hard" },
  ...
]
`

  const response = await client.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 1024,
    temperature: 0,
  })

  const content = response.choices[0]?.message?.content ?? ''
  const match = content.match(/\[[\s\S]*\]/)
  const tagged = JSON.parse(match ? match[0] : '[]')

  return questions.map((content, i) => ({
    content,
    topic: tagged[i]?.topic ?? topics[0],
    difficulty: tagged[i]?.difficulty ?? 'Medium',
    subject,
  }))
}
```

### 5.3 Homework Recommendation Logic (Pure Algorithm — No AI)

```typescript
// lib/ai/recommender.ts
import { Question, Student, Topic, Difficulty } from '@/types'

const DIFFICULTY_ORDER: Difficulty[] = ['Easy', 'Medium', 'Hard']

// Target difficulty based on mastery level
function targetDifficulty(mastery: number): Difficulty {
  if (mastery < 40) return 'Easy'
  if (mastery < 70) return 'Medium'
  return 'Hard'
}

export function recommendHomework(
  student: Student,
  availableQuestions: Question[],
  count: number = 5
): string[] {

  // Sort topics by mastery ascending (weakest first)
  const topicsByWeakness = Object.entries(student.topicMastery)
    .sort(([_, a], [__, b]) => a - b)
    .map(([topic, mastery]) => ({ topic: topic as Topic, mastery }))

  const scored = availableQuestions.map(q => {
    const topicEntry = topicsByWeakness.find(t => t.topic === q.topic)
    const mastery = topicEntry?.mastery ?? 50
    const weaknessRank = topicsByWeakness.findIndex(t => t.topic === q.topic)

    // Score: lower mastery = higher priority
    // Difficulty match bonus: matching target difficulty gets +10
    const difficultyMatch = q.difficulty === targetDifficulty(mastery) ? 10 : 0
    const score = (100 - mastery) + difficultyMatch - weaknessRank

    return { id: q.id, score }
  })

  return scored
    .sort((a, b) => b.score - a.score)
    .slice(0, count)
    .map(q => q.id)
}
```

### 5.4 Student Mastery Update

```typescript
// Exponential moving average: newMastery = old * 0.7 + newScore * 0.3
// newScore: correct = 100, incorrect = 0

export function updateMastery(
  current: number | undefined,
  correct: boolean
): number {
  const old = current ?? 50
  const newScore = correct ? 100 : 0
  return Math.round(old * 0.7 + newScore * 0.3)
}
```

---

## Phase 6: Dashboard Pages

### 6.1 Dashboard Home (/dashboard)

```tsx
<h1>Dashboard</h1>
<p>Active Students This Week</p>
<p>Sessions This Week</p>
<p>Questions in Bank</p>
<h2>Recent Sessions</h2>
<a href="/dashboard/sessions/new">Log a Session</a>
```

### 6.2 Question Bank (/dashboard/questions)

Features: upload button, question list with topic/difficulty/tag-source badges, inline dropdowns to edit topic or difficulty.

```tsx
<h1>Question Bank</h1>
<button>Upload Questions</button>
<p>Subject</p>
<p>Topic</p>
<p>Difficulty</p>
<p>Tagged by</p>
<span>AI Tagged</span>
<span>Manually Edited</span>
<p>No questions yet. Upload a PDF to get started.</p>
```

### 6.3 Session Logger (/dashboard/sessions/[id])

Features: select student, select questions covered, mark correct/incorrect per question, submit to trigger analysis + homework recommendation.

```tsx
<h1>Log Session</h1>
<label>Student</label>
<label>Date</label>
<label>Questions Covered</label>
<label>Teacher Notes (optional)</label>
<h2>Mark Performance</h2>
<button>Correct</button>
<button>Incorrect</button>
<button>Complete Session</button>
<p>Session saved. Homework recommendations are ready.</p>
```

### 6.4 Students (/dashboard/students)

Features: student list, click to view per-topic mastery profile (bar chart).

```tsx
<h1>Students</h1>
<button>Add Student</button>
<h2>Mastery Profile</h2>
<p>Last updated</p>
<p>No sessions logged yet for this student.</p>
```

---

## Phase 7: Stripe Subscription

### 7.1 Checkout API

```typescript
// app/api/stripe/checkout/route.ts
import Stripe from 'stripe'
import { verifySession } from '@/lib/firebase/auth'
import { adminDb } from '@/lib/firebase/admin'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(request: Request) {
  const uid = await verifySession()
  if (!uid) return new Response('Unauthorized', { status: 401 })

  const { plan } = await request.json()

  const priceIds: Record<string, string> = {
    starter: process.env.STRIPE_PRICE_STARTER!,
    growth:  process.env.STRIPE_PRICE_GROWTH!,
    pro:     process.env.STRIPE_PRICE_PRO!,
  }

  const orgDoc = await adminDb.collection('organizations').doc(uid).get()
  const org = orgDoc.data()

  const session = await stripe.checkout.sessions.create({
    mode: 'subscription',
    line_items: [{ price: priceIds[plan], quantity: 1 }],
    customer_email: org?.email,
    success_url: `${process.env.NEXT_PUBLIC_APP_URL}/dashboard?upgraded=true`,
    cancel_url:  `${process.env.NEXT_PUBLIC_APP_URL}/dashboard`,
    metadata: { orgId: uid, plan },
  })

  return Response.json({ url: session.url })
}
```

### 7.2 Webhook

```typescript
// app/api/stripe/webhook/route.ts
export async function POST(request: Request) {
  const body = await request.text()      // ← Must use text(), not json()
  const sig = request.headers.get('stripe-signature')!
  const event = stripe.webhooks.constructEvent(body, sig, process.env.STRIPE_WEBHOOK_SECRET!)

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object as Stripe.Checkout.Session
    const { orgId, plan } = session.metadata!
    await adminDb.collection('organizations').doc(orgId).update({
      plan,
      subscriptionStatus: 'active',
      stripeCustomerId: session.customer,
    })
  }

  if (event.type === 'customer.subscription.deleted') {
    // Look up org by stripeCustomerId, downgrade plan to 'trial'
  }

  return new Response('ok')
}
```

---

## Phase 8: Vercel Deployment

### 8.1 Environment Variables

Add all `.env.local` variables in Vercel Dashboard → Settings → Environment Variables.

⚠️ **FIREBASE_ADMIN_PRIVATE_KEY**: Paste the raw private key with actual newlines in the Vercel input field.

### 8.2 Build Command

```
next build
```

### 8.3 Firebase Security Rules

Firestore — all access through Admin SDK only:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Realtime Database:
```json
{
  "rules": {
    ".read": false,
    ".write": false
  }
}
```

### 8.4 Stripe Webhook Setup

Stripe Dashboard → Developers → Webhooks → Add endpoint:
- URL: `https://your-project.vercel.app/api/stripe/webhook`
- Events: `checkout.session.completed`, `customer.subscription.deleted`
- Copy Signing Secret → `STRIPE_WEBHOOK_SECRET`

---

## Common Pitfalls

| Pitfall | Cause | Fix |
|---------|-------|-----|
| Firebase Admin private key error | Newlines stripped in Vercel | Paste raw key with real newlines in Vercel dashboard |
| Firebase token verification fails | Cookie expired or missing | Re-call `getIdToken()` on login |
| Firestore permission denied | Used client SDK directly | All writes go through API route + Admin SDK |
| PDF parses as garbage | Scanned image PDF | Use Vision API OCR before parsing |
| AI tagging returns malformed JSON | Claude adds surrounding text | Extract with `/\[[\s\S]*\]/` before JSON.parse |
| Stripe webhook signature fails | Used `request.json()` | Must use `request.text()` |

---

## Phase Summary

```
Phase 0: Project init + dependency install
Phase 1: Landing page — show to owners immediately ★★★
Phase 2: Firebase initialization
Phase 3: Auth (register / login)
Phase 4: Firestore data structure
Phase 5: Core AI features (upload, tag, recommend) ★★★
Phase 6: Dashboard pages
Phase 7: Stripe subscription
Phase 8: Vercel deployment
```

**Out of scope for MVP:**
- ❌ Student-facing portal
- ❌ Parent reports
- ❌ Mobile app
- ❌ Multi-tutor accounts
- ❌ White-label branding
