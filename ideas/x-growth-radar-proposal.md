# x-growth-radar — Implementation Guide

**Status**: 📋 Proposal  
**Repo**: TBD  
**Last Updated**: March 2026

> 分析 X 英语区爆款规律，给用户提供数据驱动的发帖策略。
> 数据来源：trends24.in（热搜话题）+ X embed 接口（帖子详情）。
> 核心价值：告诉用户**发什么、什么时间发、用什么格式**，而不是靠感觉猜。
> TL1.com 做中文区，我们做英语区，没有直接竞争对手。
> 所有标准模块参照 `indie-product-playbook/stack/STANDARD.md`。

---

## 1. Tech Stack

| Layer | Choice | Notes |
|-------|--------|-------|
| Framework | Next.js 14 (App Router) | 标准，不变 |
| Language | TypeScript | strict mode |
| Styling | Tailwind CSS + Shadcn/ui | 标准，不变 |
| Database | Supabase (PostgreSQL) | 通过 Prisma 访问 |
| ORM | Prisma v7 + @prisma/adapter-pg | 见 STANDARD.md Section 4 |
| Auth | Supabase Auth | Email + Google |
| Payments | Stripe Subscription | 月付模式，见 STANDARD.md Section 6B |
| 数据采集 | Python scraper（独立进程） | 每日 cron，结果写入同一 Supabase DB |
| AI 分析 | Claude API (claude-sonnet) | 爆款规律提取 + 发帖建议生成 |
| Deployment | Vercel（Next.js）+ Railway（Python scraper） | 分开部署 |

---

## 2. 产品定位

**目标用户**：想在 X 英语区涨粉的创作者、独立开发者、创业者、个人品牌

**市场空白**：TL1.com 做中文区已经做得很好，英语区没有类似产品。英语区是 X 最大的流量池，付费意愿也最高。

**核心功能**：

1. **今日热帖分析** — 每天抓取英语区热帖，提取共同特征（话题、格式、句式、时间）
2. **发帖建议** — 根据用户所在领域，推荐今天该发什么、怎么发
3. **草稿评分** — 用户输入草稿，AI 给出算法得分 + 具体改进建议
4. **竞品追踪** — 监控用户指定的对标账号，分析其爆款规律

**不做的事**：
- 不预测精确曝光数字（数据不够支撑，会不准）
- 不帮用户自动发帖（违反 X ToS）
- 暂不做多语言（先把英语区做深，验证后再扩展）

---

## 3. 数据来源

### 主要来源一：trends24.in（免费，稳定）

trends24.in 实时追踪全球各国 X 热搜话题，按小时更新，按国家分类，完全免费，无需登录。

```
GET https://trends24.in/united-states/
→ 拿到当前美国 Top 20 热搜话题
→ 用话题关键词去搜索对应热帖
```

### 主要来源二：X embed 接口（免费，匿名开放）

```
GET https://publish.twitter.com/oembed?url={tweet_url}
→ 拿到帖子详情（内容、作者、互动数）
→ 无需 API Key，匿名访问
```

**完整数据流**：
```
trends24.in → 热搜话题列表
    ↓
twscrape 按话题搜索 → 热帖 URL 列表
    ↓
embed 接口 → 帖子详情（内容 + 互动数）
    ↓
特征提取（语言、格式、时间、话题类型）
    ↓
Claude 分析爆款规律 → 写入 Supabase
    ↓
Web Dashboard 展示给用户
```

### 为什么不用官方 API

官方 API Basic $100/月，Pro $5,000/月。embed 接口免费且从未被关闭，是 TL1.com 作者验证过的方案。

---

## 4. 项目目录结构

```
x-growth-radar/
├── app/                                  ← Next.js Web 端
│   ├── api/
│   │   ├── stripe/
│   │   │   ├── checkout/route.ts
│   │   │   └── webhook/route.ts
│   │   ├── dashboard/
│   │   │   ├── hot-posts/route.ts        ← 今日热帖分析
│   │   │   ├── suggestions/route.ts      ← 发帖建议
│   │   │   └── score/route.ts            ← 草稿评分（调 Claude API）
│   │   └── cron/
│   │       └── analyze/route.ts          ← Vercel cron 触发每日分析
│   ├── auth/
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── callback/route.ts
│   ├── dashboard/
│   │   ├── page.tsx                      ← 主界面：今日建议
│   │   ├── hot-posts/page.tsx            ← 热帖榜
│   │   ├── score/page.tsx                ← 草稿评分
│   │   └── competitors/page.tsx          ← 竞品追踪（Pro only）
│   ├── page.tsx                          ← Landing page
│   └── layout.tsx
├── components/
│   ├── Header.tsx
│   ├── PostCard.tsx                      ← 热帖展示卡片
│   ├── ScoreWidget.tsx                   ← 草稿评分组件
│   └── SuggestionCard.tsx                ← 发帖建议卡片
├── lib/
│   ├── supabase/
│   │   ├── client.ts
│   │   ├── server.ts
│   │   └── admin.ts
│   └── db/
│       └── client.ts
├── prisma/
│   └── schema.prisma
├── scraper/                              ← Python 独立进程（部署到 Railway）
│   ├── trends_scraper.py                 ← 抓 trends24.in 热搜话题
│   ├── tweet_scraper.py                  ← twscrape 按话题搜热帖
│   ├── embed_fetcher.py                  ← embed 接口拿帖子详情
│   ├── feature_extractor.py             ← 提取帖子特征
│   ├── analyzer.py                       ← Claude API 分析爆款规律
│   ├── db.py                             ← 写入 Supabase
│   ├── main.py                           ← 入口，每日 cron 触发
│   └── requirements.txt
├── middleware.ts
├── vercel.json                           ← Vercel cron 配置
└── .env.local
```

---

## 5. 数据库 Schema（Prisma）

```prisma
model Profile {
  id                 String       @id           // = Supabase auth.users.id
  email              String       @unique
  niche              String?                    // 用户领域（tech / startup / finance / creator...）
  xUsername          String?                    // 用户自己的 X 账号
  subscriptionStatus String       @default("free")
  createdAt          DateTime     @default(now())
  updatedAt          DateTime     @updatedAt
  competitors        Competitor[]
}

// 每日抓取的英语区热帖
model HotPost {
  id             String   @id                  // tweet_id
  url            String
  authorId       String
  authorName     String
  authorFollowers Int
  content        String
  viewCount      Int
  likeCount      Int
  replyCount     Int
  retweetCount   Int
  bookmarkCount  Int
  hasMedia       Boolean
  hasLink        Boolean
  hasQuestion    Boolean
  wordCount      Int
  topic          String?                       // 关联的热搜话题
  niche          String?                       // AI 分类的领域标签
  postedAt       DateTime
  scrapedAt      DateTime @default(now())
}

// AI 每日分析结果（按领域分开存）
model DailyAnalysis {
  id          String   @id @default(cuid())
  date        DateTime
  niche       String                           // "tech" | "startup" | "finance" | "general" ...
  insights    Json                             // 今日爆款规律
  suggestions Json                             // 发帖建议列表（3条）
  topPosts    Json                             // Top 5 热帖摘要
  createdAt   DateTime @default(now())

  @@unique([date, niche])
}

// 用户追踪的竞品账号（Pro only，最多5个）
model Competitor {
  id        String   @id @default(cuid())
  profileId String
  profile   Profile  @relation(fields: [profileId], references: [id])
  xUsername String
  createdAt DateTime @default(now())

  @@unique([profileId, xUsername])
}
```

---

## 6. 定价方案

| 方案 | 价格 | 功能 |
|------|------|------|
| Free | $0 | 每天看 Top 5 热帖，看今日 1 条发帖建议 |
| Pro | $9/月 | 全部热帖 + 3 条发帖建议 + 草稿评分无限次 + 竞品追踪（5个账号）|

盈亏平衡：**2 个 Pro 用户**（$9×2 = $18/月）即可覆盖服务器成本。

---

## 7. Build Phases

---

### Phase 1: 项目初始化 + 数据库

**Goal**: Next.js 跑起来，DB schema 建好，Auth 通，能登录。

按 STANDARD.md Section 11 Checklist 走。

**额外工作**（在标准流程之外）：
- schema.prisma 加入 `HotPost`、`DailyAnalysis`、`Competitor` 三张表
- Profile 加 `niche`、`xUsername`、`subscriptionStatus` 字段
- `npx prisma db push` 建表

**验收标准**：能用 Email 注册登录，能访问 `/dashboard`（空页面即可）。

---

### Phase 2: Python Scraper — 趋势抓取

**Goal**: 每天自动抓取英语区热帖，存入 Supabase。

**两步流程**：

第一步，`trends_scraper.py` 抓 trends24.in：
```python
# 目标 URL
GET https://trends24.in/united-states/

# 解析出当前 Top 20 热搜话题，例如：
# ["#AI", "OpenAI", "Elon Musk", "Bitcoin", ...]
```

第二步，`tweet_scraper.py` 按话题搜帖子：
```python
# 用 twscrape，每个话题搜 50 条
# 过滤条件：英文 + 24小时内 + 有互动数据
```

第三步，`embed_fetcher.py` 补充详情：
```python
GET https://publish.twitter.com/oembed?url={tweet_url}
# 多 IP 轮换防封（梯子多线路 或 rotating proxy）
```

第四步，`feature_extractor.py` 提取特征：
```python
features = {
    "has_question": "?" in content,
    "has_numbers": bool(re.search(r'\d+', content)),
    "has_link": "http" in content,
    "has_media": tweet.media is not None,
    "word_count": len(content.split()),
    "hour_posted": tweet.date.hour,
    "day_of_week": tweet.date.weekday(),
}
```

**预计产量**：每天 200-500 条有效英语热帖。

**部署**：Railway，每天 UTC 02:00 跑一次（美国用户睡觉时段，数据已沉淀）。

**验收标准**：`hot_posts` 表每天自动新增 200+ 条记录。

---

### Phase 3: Claude API 分析层

**Goal**: 每天对热帖跑 AI 分析，提取爆款规律，生成发帖建议。

**输入**：今日热帖列表（content + 互动数 + 特征）

**Claude prompt 核心逻辑**：

```
分析以下今日英语区 X 热帖，提取爆款规律，针对 {niche} 领域生成发帖建议。

分析维度：
- 什么话题类型互动率最高
- 什么句式/格式出现最频繁（问句/列表/故事/争议性观点）
- 什么时间段的帖子互动最好
- 有没有共同的开头模式

输出 JSON，格式如下：
{
  "insights": {
    "top_topics": [...],
    "best_format": "...",
    "best_time": "...",
    "key_pattern": "..."
  },
  "suggestions": [
    {
      "angle": "...",
      "template": "...",
      "reason": "...",
      "example": "..."
    }
  ]
}

只返回 JSON，不要其他文字。
```

**按领域分开跑**：general / tech / startup / finance / creator，每个 niche 一条 DailyAnalysis 记录。

**触发方式**：Vercel cron，每天 UTC 04:00 触发 `/api/cron/analyze`（scraper 跑完两小时后）。

**验收标准**：`daily_analyses` 表每天自动新增 5 条记录（5 个 niche），insights 格式正确。

---

### Phase 4: Web Dashboard — 核心页面

**Goal**: 用户登录后能看到今日建议、热帖榜、草稿评分。

**今日建议页**（主页，`/dashboard`）：
- 今日最应该发的 3 个方向（按用户选择的 niche）
- 每个方向附带模板 + 理由 + 例子
- 今日爆款规律摘要（最佳时间、最佳格式）
- Free 用户只看 1 条，Pro 看全部 3 条

**热帖榜**（`/dashboard/hot-posts`）：
- 今日 Top 20 英语区热帖
- 显示互动数、话题标签、发帖时间
- Free 用户只看 Top 5

**草稿评分**（`/dashboard/score`，Pro only）：
- 用户粘贴草稿
- 调 `/api/dashboard/score` → Claude API 实时评分
- 输出：0-10 分 + 各维度分析 + 具体改进建议
- 预计响应时间：3-5 秒

**Onboarding**（新用户注册后）：
- 选择自己的 niche（tech / startup / finance / creator / other）
- 填写自己的 X 用户名（可选）
- 写入 Profile.niche

**验收标准**：真实用户能完成注册 → onboarding → 看到今日建议的完整流程。

---

### Phase 5: Stripe 订阅

**Goal**: 免费用户受限，$9/月 解锁 Pro 功能。

按 STANDARD.md Section 6B Subscription 模式实现，无偏差。

**Free vs Pro 限制逻辑**：
```typescript
// 在每个 API route 里检查
const profile = await prisma.profile.findUnique({ where: { id: user.id } })
const isPro = profile?.subscriptionStatus === 'active'

if (!isPro && requestingProFeature) {
  return Response.json({ error: 'upgrade_required' }, { status: 403 })
}
```

**Stripe Dashboard 配置**：
- 创建产品 "x-growth-radar Pro"，月付 $9
- Webhook 监听 `checkout.session.completed` + `customer.subscription.deleted`
- 复制 Price ID + Webhook Secret → 填入 Vercel 环境变量

**验收标准**：能完成 $9/月 订阅流程，订阅后 `subscriptionStatus` 变为 `active`，Pro 功能解锁。

---

### Phase 6: 竞品追踪（Pro only）

**Goal**: 用户可以监控最多 5 个对标账号，分析其爆款规律。

**流程**：
- 用户在 `/dashboard/competitors` 填入对标账号的 X 用户名
- Python scraper 每天顺带抓这些账号的最新帖子
- Claude 分析该账号的发帖规律（什么内容表现好、什么时间发）
- Dashboard 展示：该账号本周爆款 + 规律总结

**验收标准**：添加竞品账号后，次日能看到该账号的分析报告。

---

## 8. 环境变量清单

在 STANDARD.md Section 5.1 基础上，额外需要：

```bash
# Claude API
ANTHROPIC_API_KEY=sk-ant-...

# Cron 安全验证
CRON_SECRET=   # openssl rand -base64 32

# Railway scraper 回写 Supabase 用（和 Web 端共享同一个 DB）
# 直接复用 NEXT_PUBLIC_SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY
```

---

## 9. 运行成本估算

| 组件 | 费用 |
|------|------|
| Claude API（每日分析 ~400 帖，5 个 niche）| ~$0.10–0.30/天 |
| Claude API（草稿评分，按用量）| ~$0.01/次 |
| Railway（Python scraper hosting）| ~$5/月 |
| Vercel Hobby | 免费 |
| Supabase Free tier | 免费（起步够用） |
| Rotating proxy（可选，防 IP 封锁）| ~$10/月 |
| **月度总成本** | **~$15–25/月** |

**盈亏平衡**：3 个 Pro 用户（$9×3 = $27/月）覆盖成本。

---

## 10. 关键风险

| 风险 | 概率 | 应对 |
|------|------|------|
| trends24.in 改版导致爬虫失效 | 中 | 加 `--debug` 模式保存 HTML，快速重新分析 DOM |
| X 封掉 embed 接口 | 低 | 切换到 Apify Twitter Scraper，成本约 $20/月 |
| twscrape 账号被封 | 中 | 备 3-5 个小号轮换，或切换到 Apify |
| Claude 分析结果质量不稳 | 低 | 人工审核初期输出，迭代 prompt，加输出格式校验 |
| 英语区用户找不到产品（冷启动）| 高 | 产品本身就是 X 增长工具，用产品自己在 X 上做 build in public 推广 |

---

## 11. 冷启动策略

产品本身的目标用户就在 X 上，所以推广方式很自然：

- 用产品自己分析出来的建议，在 X 上发 build in public 帖子
- 每天发一条"今日英语区爆款规律"，附带产品链接
- 找 indie hacker 社区（HN、Reddit r/indiehackers）发帖

本质上：**用产品来推广产品，自我验证。**

---

## 12. 新项目 Checklist

```
□ npx create-next-app@latest x-growth-radar --typescript --tailwind --app
□ 按 STANDARD.md Section 11 完成标准初始化
□ schema.prisma 加入 HotPost / DailyAnalysis / Competitor 表
□ Profile 加 niche / xUsername / subscriptionStatus 字段
□ npx prisma db push
□ Python scraper 环境：venv + requirements.txt + .env
□ trends_scraper.py → 验证能抓到 trends24.in 热搜话题
□ tweet_scraper.py → 验证 twscrape 能按话题搜到帖子
□ embed_fetcher.py → 验证能拿到帖子互动数据
□ analyzer.py → 验证 Claude 输出格式正确
□ db.py → 验证数据写入 Supabase hot_posts 表
□ main.py 全流程 → python main.py 跑通，hot_posts + daily_analyses 都有数据
□ Railway 部署 scraper + 设置每日 cron UTC 02:00
□ /dashboard 主页展示今日建议（从 DailyAnalysis 读）
□ /dashboard/hot-posts 热帖榜
□ /dashboard/score 草稿评分（Pro only）
□ Onboarding 流程（选 niche）
□ Stripe 订阅接入（按 STANDARD.md 6B）
□ Free vs Pro 权限控制
□ Vercel cron 配置（UTC 04:00 触发分析）
□ Vercel 部署 → 验证生产环境正常
□ 第一个真实用户测试
□ 在 X 上发第一条 build in public 帖子
```

---

## Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-03 | 1.0 | 初版（中文区方向）|
| 2026-03 | 2.0 | 改为英语区方向，数据源换为 trends24.in，定价加入 Free tier |
