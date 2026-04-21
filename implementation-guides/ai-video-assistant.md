# AI Video Assistant - Implementation Guide (Updated)

**Status**: ✅ MVP Complete  
**Live URL**: https://www.aivideopick.com/  
**Last Updated**: March 3, 2026

---

## 📊 Project Status

### ✅ Completed (100%)

**Week 1: Core Recommendation Engine**
- ✅ GPT-4 powered model recommendation system
- ✅ Dynamic filtering based on budget/duration/content
- ✅ Cost optimization algorithm
- ✅ Model database with 4 providers

**Week 2: Backend Infrastructure**
- ✅ Supabase database setup (profiles, generations tables)
- ✅ Authentication system (email/password)
- ✅ Credits system with tracking
- ✅ Stripe integration (test mode)
- ✅ Minimax API integration
- ✅ Dashboard with video playback

**Week 3: Advanced Features**
- ✅ Kling 2.6 API integration via PiAPI (4 model variants)
- ✅ **Parallel preview** - Multi-model selection & comparison
- ✅ Multi-provider architecture
- ✅ Dynamic cost calculation

**Week 4: Production Deployment**
- ✅ Vercel deployment
- ✅ Environment variables configured
- ✅ Stripe webhook (production ready)
- ✅ Buy Credits UI with payment flow
- ✅ Mobile responsive design

---

## 🏗️ Architecture

### Tech Stack

**Frontend**:
- Next.js 14 (App Router)
- React 18
- TypeScript
- Tailwind CSS
- Radix UI (Dialog, etc.)

**Backend**:
- Next.js API Routes
- Supabase (PostgreSQL + Auth)
- Stripe (Payments)

**AI/Video APIs**:
- OpenAI GPT-4o (recommendations)
- Minimax Video-01 API (via PiAPI)
- Kling AI 2.6 API (Standard/Pro, via PiAPI)
- Luma Dream Machine API (Ray Flash 2)

**Deployment**:
- Vercel (hosting + auto-deploy)
- Supabase Cloud (database)

---

## 📁 Project Structure

```
ai-video-assistant/
├── app/
│   ├── api/
│   │   ├── generate/route.ts          # Video generation endpoint
│   │   ├── recommend/route.ts         # AI recommendations
│   │   ├── status/[id]/route.ts       # Check generation status
│   │   └── stripe/
│   │       ├── checkout/route.ts      # Create payment session
│   │       └── webhook/route.ts       # Handle payment webhooks
│   ├── auth/
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── callback/route.ts
│   ├── dashboard/page.tsx             # User's generations
│   ├── page.tsx                       # Homepage
│   └── layout.tsx
├── components/
│   ├── Header.tsx                     # Nav with credits & buy button
│   ├── RecommendationForm.tsx         # Main input form
│   ├── RecommendationTable.tsx        # Results display
│   ├── RecommendationCard.tsx         # Individual model card
│   ├── GenerateModal.tsx              # Multi-model selection modal
│   ├── BuyCreditsModal.tsx            # Credit packages
│   └── ...
├── lib/
│   ├── models.ts                      # Model definitions
│   ├── recommender.ts                 # AI recommendation logic
│   ├── video-apis/
│   │   ├── minimax.ts                 # Minimax client
│   │   ├── kling.ts                   # Kling client (via PiAPI)
│   │   └── luma.ts                    # Luma Dream Machine client
│   └── supabase/
│       ├── client.ts                  # Browser client
│       └── admin.ts                   # Server admin client
└── .env.local                         # Environment variables
```

---

## 🗄️ Database Schema

### `profiles` Table
```sql
id: uuid (primary key, references auth.users)
email: text
credits: numeric (default 10.00)
created_at: timestamp
updated_at: timestamp
```

### `generations` Table
```sql
id: uuid (primary key)
user_id: uuid (foreign key → profiles.id)
model_id: text
prompt: text
duration: integer
cost: numeric
status: text (pending/processing/completed/failed)
video_url: text (nullable)
provider: text (minimax/kling/luma)
provider_job_id: text
created_at: timestamp
updated_at: timestamp
```

**RLS Policies**:
- Users can SELECT/INSERT their own generations
- Server updates use supabaseAdmin (bypasses RLS)

---

## 🔑 Environment Variables

### Required Variables

```bash
# OpenAI
OPENAI_API_KEY=sk-proj-...

# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...

# Stripe (Test Mode)
STRIPE_SECRET_KEY=sk_test_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Video APIs
PIAPI_API_KEY=...          # Kling + Minimax via PiAPI
MINIMAX_API_KEY=...        # Minimax direct API
LUMA_API_KEY=...           # Luma Dream Machine API
```

**Note**: All variables configured in Vercel for production

---

## 🎯 Core Features

### 1. AI Recommendation Engine

**Flow**:
1. User inputs: description, budget, max duration
2. System filters models by: `maxDuration >= userDuration`
3. GPT-4 analyzes prompt and recommends top 3 models
4. Returns: model details + reasoning + cost estimate

**Key File**: `lib/recommender.ts`

**Models Available** (8 total):
- Minimax Video-01: 40cr/6s, 70cr/10s
- Kling 2.6 Standard: 25cr/5s, 50cr/10s
- Kling 2.6 Pro: 40cr/5s, 80cr/10s
- Luma Ray Flash 2 (720p): 30cr/5s, 55cr/9s

---

### 2. Parallel Preview (Core Differentiator)

**Feature**: Select multiple models → generate simultaneously → compare results

**Implementation**:
- `GenerateModal.tsx`: Checkbox UI for model selection
- Multi-model state management
- `Promise.all()` for parallel API calls
- Dashboard displays all generations

**User Value**: Test 2-3 models at once, pick best result

---

### 3. Video Generation

**Supported Providers**:

**Minimax**:
- Endpoint: `https://api.minimax.io/v1/video_generation`
- Auth: Bearer token
- Status check: Poll with task_id
- Video expiry: 9 hours

**Kling** (via PiAPI):
- Endpoint: `https://api.piapi.ai/api/v1/task`
- Auth: `x-api-key` header
- Status check: GET `/task/{task_id}`
- Duration: Only 5s or 10s (snapped in code)
- Models: 2.6 Standard, 2.6 Pro

**Luma**:
- Endpoint: `https://api.lumalabs.ai/dream-machine/v1/generations`
- Auth: Bearer token (`LUMA_API_KEY`)
- Status check: GET `/generations/{id}`
- States: `pending` → `dreaming` → `completed` / `failed`
- Duration: Only 5s or 9s (snapped in code)
- Models: Ray Flash 2 (720p)

**Generation Flow**:
1. User clicks Generate
2. API deducts credits from profile
3. Calls provider API → receives job_id
4. Saves to database (status: pending)
5. Client polls `/api/status/[id]` every 3s
6. When complete: updates status + video_url

---

### 4. Credits & Payments

**Credit Packages** (via BuyCreditsModal):
- $10 = 10 credits
- $25 = 25 credits  
- $50 = 50 credits

**Stripe Flow**:
1. User clicks package
2. Frontend calls `/api/stripe/checkout`
3. Creates Stripe Checkout Session
4. Redirects to Stripe payment page
5. After payment: Stripe webhook → `/api/stripe/webhook`
6. Webhook adds credits to user's profile

**Webhook Security**: Verifies signature with `STRIPE_WEBHOOK_SECRET`

---

## 🚀 Deployment

### Current Setup

**Hosting**: Vercel
- Auto-deploy on git push
- Environment variables configured
- Custom domain ready (optional)

**Database**: Supabase Cloud
- PostgreSQL hosted
- Automatic backups
- RLS enabled

**CDN/Assets**: Vercel Edge Network

---

## 🐛 Known Issues & Solutions

### Issue 1: Minimax Status Mapping
**Problem**: API returns lowercase "completed"  
**Solution**: Use `.toLowerCase()` comparison in status check

### Issue 2: Kling Duration Validation
**Problem**: Kling only accepts 5 or 10 seconds  
**Solution**: Round duration in `kling.ts`: `duration <= 5 ? 5 : 10`

### Issue 3: Auth Bug (Resolved)
**Problem**: Used wrong Supabase client  
**Solution**: Changed to `createBrowserClient` from `@supabase/ssr`

### Issue 4: Webhook 405 Error (Resolved)
**Problem**: Route path mismatch  
**Solution**: Moved file to `app/api/stripe/webhook/route.ts`

---

## 📱 Mobile Responsiveness

**Implemented**:
- ✅ Responsive form inputs
- ✅ Card-based layout for recommendations table on mobile
- ✅ Touch-friendly buttons and modals
- ✅ Readable text sizes

**Tested On**:
- iPhone (Safari)
- Android (Chrome)
- Desktop (Chrome, Safari, Firefox)

---

## 🧪 Testing Checklist

### Functionality Tests

**Authentication**:
- [ ] Register new user
- [ ] Login existing user
- [ ] Logout
- [ ] Password reset (email flow)

**Recommendations**:
- [ ] Get recommendations with various inputs
- [ ] Verify cost calculations
- [ ] Check duration filtering (e.g., 10s excludes Minimax)

**Video Generation**:
- [ ] Generate with Minimax
- [ ] Generate with Kling models
- [ ] Generate with Luma models
- [ ] Multi-model parallel generation
- [ ] Check credits deduction

**Dashboard**:
- [ ] View completed videos
- [ ] Video playback
- [ ] Download videos
- [ ] Status updates (polling)

**Payments**:
- [ ] Buy Credits modal displays packages
- [ ] Stripe checkout works (test card: 4242 4242 4242 4242)
- [ ] Webhook adds credits after payment
- [ ] Credits display updates

---

## 🔐 Security Considerations

**Implemented**:
- ✅ RLS policies on database
- ✅ Server-side credit checks before generation
- ✅ Stripe webhook signature verification
- ✅ Environment variables not exposed to client
- ✅ HTTPS only (Vercel enforces)

**Auth**:
- Supabase handles password hashing
- JWT tokens for sessions
- Email verification (optional, currently disabled)

---

## 💰 Pricing & Economics

### Current Costs

**Per Video** (API cost):
- Minimax 6s: $0.28 | 10s: $0.56
- Kling 2.6 Standard 5s: $0.20 | 10s: $0.40
- Kling 2.6 Pro 5s: $0.33 | 10s: $0.66
- Luma Ray Flash 2 5s: $0.24 | 9s: $0.44

**Infrastructure**:
- Vercel: Free tier (hobby plan)
- Supabase: Free tier (500MB database)
- Stripe: 2.9% + $0.30 per transaction

**Target Margins**: 
- Sell credits at 1:1 ($10 = 10 credits)
- Break even on video generation
- Profit on higher credit packages (future: volume discounts)

---

## 📈 Metrics to Track

**Key Metrics** (not yet implemented):
- [ ] User signups
- [ ] Credit purchase conversion rate
- [ ] Average credits spent per user
- [ ] Most popular models
- [ ] Generation success rate
- [ ] Churn rate

**Tools to Add**:
- [ ] Plausible/PostHog analytics
- [ ] Stripe revenue tracking
- [ ] Supabase query analytics

---

## 🚀 Next Steps (Post-MVP)

### Phase 1: Beta Testing (Week 1-2)
- [ ] Recruit 5-10 beta users
- [ ] Collect feedback on UX
- [ ] Identify and fix critical bugs
- [ ] Validate pricing

### Phase 2: Pre-Launch Polish (Week 2-3)
- [ ] Stripe: Switch to Live mode
- [ ] Optional: Buy custom domain
- [ ] Create demo video (Loom, 90s)
- [ ] Take screenshots for Product Hunt
- [ ] Write launch copy

### Phase 3: Soft Launch (Week 3)
- [ ] Post on Reddit (r/SideProject)
- [ ] Share on Twitter
- [ ] Indie Hackers listing

### Phase 4: Product Hunt Launch (Week 4)
- [ ] Submit to Product Hunt
- [ ] Monitor and respond to comments
- [ ] Drive traffic to site

### Phase 5: Feature Roadmap (Post-Launch)
**Potential additions** (prioritize based on user feedback):
- ✅ Luma Ray Flash 2 integration (completed March 2026)
- [ ] More AI video providers (Runway, Veo 2)
- [ ] Video editing features
- [ ] Team/workspace support
- [ ] API for developers
- [ ] Webhooks for generation completion
- [ ] Advanced comparison UI (side-by-side player)
- [ ] Export to social media formats
- [ ] Prompt templates library

---

## 🛠️ Development Workflow

### Local Development
```bash
# Install dependencies
npm install

# Run dev server
npm run dev

# Build for production
npm run build

# Type check
npx tsc --noEmit
```

### Deployment
```bash
# Commit changes
git add .
git commit -m "Description"
git push

# Vercel auto-deploys on push to main
```

### Environment Setup
1. Copy `.env.local.example` to `.env.local`
2. Fill in API keys
3. Restart dev server after changes

---

## 📚 Key Learnings

### What Worked Well
1. **Next.js App Router**: Clean API routes, easy deployment
2. **Supabase**: Fast setup, good free tier, RLS is powerful
3. **Stripe**: Straightforward integration, webhook is reliable
4. **Radix UI**: Accessible components out of the box
5. **Parallel Preview**: Core differentiator, users love it

### What Was Challenging
1. **Kling API**: Poor documentation, required trial/error
2. **Browser Caching**: Next.js client component chunks cached aggressively
3. **Minimax Status Codes**: Inconsistent API response formats
4. **Mobile UX**: Tables don't work well on small screens

### What Would Be Done Differently
1. Start with one provider, add second after validation
2. Add analytics from day 1
3. Implement error logging (Sentry) earlier
4. Create demo video before building features

---

## 🤝 Contributing

This is a solo project, but if you'd like to contribute:
1. Fork the repo
2. Create a feature branch
3. Submit a PR with clear description

---

## 📞 Support

**Issues**: GitHub Issues  
**Email**: [your email]  
**Twitter**: [your handle]

---

## 📄 License

[Choose: MIT, Apache 2.0, or Proprietary]

---

**Built by**: [Your Name]  
**Built with**: Next.js, Supabase, Stripe, GPT-4o, Minimax, Kling AI, Luma Dream Machine  
**Build Time**: ~4 weeks (Feb 2026)
