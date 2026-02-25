# CLAUDE.md

> This file is read automatically by Claude Code.
> Part 1 is fixed — never change it across projects.
> Part 2 is project-specific — fill in the blanks when starting a new project.

---

## PART 1 — Standard Rules (Do Not Change)

### Tech Stack
- Framework: Next.js 14, App Router, TypeScript
- Styling: Tailwind CSS + Shadcn/ui
- Auth: Supabase Auth (Email + Google + GitHub)
- Database: Supabase PostgreSQL, accessed via Prisma v7 only
- ORM: Prisma v7 with @prisma/adapter-pg (never use Prisma without adapter)
- Payments: Stripe
- Email: Resend + React Email (if used)
- Deployment: Vercel

### Project Structure
Standard file locations — do not deviate:
- `lib/supabase/client.ts` — browser client
- `lib/supabase/server.ts` — server client
- `lib/supabase/admin.ts` — admin client (server only)
- `lib/db/client.ts` — Prisma singleton
- `app/auth/login/page.tsx`
- `app/auth/register/page.tsx`
- `app/auth/callback/route.ts` — OAuth callback, always required
- `app/api/stripe/checkout/route.ts`
- `app/api/stripe/webhook/route.ts`
- `middleware.ts` — route protection

### Database Rules
- All tables: RLS DISABLED. Security is enforced at the API layer.
- Always use Prisma for all DB operations. Never use Supabase client for DB queries.
- DATABASE_URL must use Supabase Transaction Pooler (port 6543), never Direct Connection (port 5432).
- Prisma must be initialized with @prisma/adapter-pg. Never use empty constructor.

### Auth Rules
- OAuth callback route (`app/auth/callback/route.ts`) must always exist.
- Profile row must be created via `prisma.profile.upsert` in BOTH register page AND callback route.
- Always use `upsert`, never `create`, when creating Profile rows.

### API Route Rules
- Every API route must verify session as the FIRST step, no exceptions:
```typescript
const supabase = await createServerSupabaseClient()
const { data: { user } } = await supabase.auth.getUser()
if (!user) return new Response('Unauthorized', { status: 401 })
```
- Stripe webhook route must use `request.text()` not `request.json()`.

### Build & Deployment Rules
- Build command must be: `npx prisma generate && next build`
- Set this in Vercel Dashboard → Settings → Build & Development Settings.

### Known Gotchas — Never Repeat These
- Prisma v7 requires adapter. Empty constructor throws error.
- Supabase Direct Connection (port 5432) times out on Vercel. Use port 6543.
- Stripe webhook signature fails if body is parsed with `request.json()`. Use `request.text()`.
- OAuth users won't have a Profile row unless callback route does upsert.
- Supabase enables email confirmation by default. Disable it for development.
- Missing `/api/stripe/webhook/route.ts` causes 404 silently. Always verify file path.

---

## PART 2 — This Project (Fill In)

### Project Info
- **Name**: ___
- **Description**: ___
- **Live URL**: ___

### Stripe Mode
- [ ] Credits (one-time purchase) — needs `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`
- [ ] Subscription (recurring) — needs `STRIPE_PRICE_ID`, no publishable key needed

### Optional Modules
- [ ] Email (Resend): yes / no
- [ ] Cron jobs: yes / no — if yes, schedule: ___
- [ ] OpenAI: yes / no — model: ___

### External APIs
_List any third-party APIs this project uses:_
- ___

### Database Models
_List the Prisma models beyond the standard Profile:_
- Profile (standard, extended with: ___)
- ___
- ___

### Business Logic Notes
_Anything Claude should know about how this product works:_
- ___

### Environment Variables (project-specific only)
_Standard vars are in STANDARD.md. List only the extra ones for this project:_
```bash
# Add project-specific env vars here
```
