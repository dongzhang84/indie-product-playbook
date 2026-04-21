# socrates-finds-you — Implementation Guide

**Status**: 🔧 In Progress  
**Repo**: https://github.com/dongzhang84/socrates-finds-you  
**Last Updated**: March 2026

> 这是一个纯本地运行的个人工具，无需 Auth、无需 Stripe、无需部署。
> Phase 顺序严格按照 `docs/02-platforms.md` 的客群价值排序，从高净值到低付费意愿。
> 所有标准模块参照 `indie-product-playbook/stack/STANDARD.md`。

---

## 1. Tech Stack

| Layer | Choice | Notes |
|-------|--------|-------|
| Language | Python 3.11+ | venv 隔离 |
| Browser Automation | Playwright (sync) | LinkedIn, Blind, 小红书 |
| Reddit API | PRAW | 官方 API，稳定 |
| HN API | Firebase REST API | 公开，无需 auth |
| Twitter/X API | tweepy | 需要 API key，有成本 |
| RSS | feedparser | Substack / Medium |
| AI Matching | Claude API (claude-sonnet) | 语义匹配服务需求 |
| Storage | SQLite (local) | 无需服务器，轻量 |
| Output | Markdown report | 每日生成到 output/ |
| Runtime | 本地手动或 cron | 不部署，不上云 |

---

## 2. 项目目录结构

```
socrates-finds-you/
├── .github/
│   └── workflows/
│       ├── sprint-report.yml       ← 标准配置，从 playbook 复制
│       └── notify-playbook.yml     ← 推送 sprint summary 到 playbook
├── docs/
│   ├── 01-services.md              ← Dong Zhang 服务清单
│   └── 02-platforms.md             ← 平台优先级表（Phase 顺序依据）
├── ideas/
│   └── proposal.md                 ← 项目 proposal
├── scrapers/
│   ├── linkedin.py                 ← Phase 2: LinkedIn (Playwright)
│   ├── blind.py                    ← Phase 3: Blind (Playwright)
│   ├── twitter.py                  ← Phase 4: Twitter/X (tweepy)
│   ├── hackernews.py               ← Phase 5: HN (Firebase API)
│   ├── rss.py                      ← Phase 6: Substack / Medium (RSS)
│   ├── xiaohongshu.py              ← Phase 7: 小红书 (Playwright)
│   ├── reddit.py                   ← Phase 8: Reddit (PRAW)
│   ├── gradcafe.py                 ← Phase 9: The Grad Cafe (scraper)
│   └── utils.py                    ← 共用工具函数
├── matcher/
│   └── claude_match.py             ← Claude API 语义匹配
├── storage/
│   └── db.py                       ← SQLite 读写层
├── reporter/
│   └── daily_report.py             ← Markdown 报告生成
├── scripts/
│   └── extract-sprint-summary.py   ← GitHub Actions 用
├── output/                         ← 每日报告（gitignored）
├── data/
│   └── signals.db                  ← SQLite 数据库（gitignored）
├── main.py                         ← 唯一入口
├── requirements.txt
├── .env
├── .env.example
├── .gitignore
├── SPRINT.md
└── README.md
```

---

## 3. 环境变量

```bash
# .env（从 .env.example 复制，填入真实值，永远不提交到 repo）

# Claude API
ANTHROPIC_API_KEY=sk-ant-...

# LinkedIn — 个人账号
LINKEDIN_EMAIL=...
LINKEDIN_PASSWORD=...

# Blind — 个人账号
BLIND_EMAIL=...
BLIND_PASSWORD=...

# Twitter/X API — 从 developer.twitter.com 申请
TWITTER_BEARER_TOKEN=...

# Reddit（PRAW）— 从 reddit.com/prefs/apps 申请
REDDIT_CLIENT_ID=...
REDDIT_CLIENT_SECRET=...
REDDIT_USER_AGENT=socrates-finds-you/1.0

# 小红书 — 个人账号（Playwright 登录用）
XIAOHONGSHU_PHONE=...
XIAOHONGSHU_PASSWORD=...
```

> ⚠️ `.env` 永远不进 repo。所有凭证只在本地机器上。

**.gitignore 必须包含**：
```
.env
data/
output/
__pycache__/
*.pyc
.venv/
```

---

## 4. 数据库 Schema（SQLite）

```sql
CREATE TABLE IF NOT EXISTS signals (
    id              TEXT PRIMARY KEY,       -- "{platform}:{external_id}"
    platform        TEXT NOT NULL,          -- "linkedin"|"blind"|"twitter"|"hn"|"rss"|"xiaohongshu"|"reddit"|"gradcafe"
    external_id     TEXT NOT NULL,
    url             TEXT NOT NULL,
    title           TEXT NOT NULL,
    body            TEXT,
    author          TEXT,
    subreddit       TEXT,                   -- reddit only
    posted_at       DATETIME,
    scraped_at      DATETIME DEFAULT CURRENT_TIMESTAMP,

    -- 匹配结果
    matched         BOOLEAN DEFAULT FALSE,
    service_match   TEXT,
    client_tier     TEXT,                   -- "high" | "medium" | "low"
    confidence      TEXT,                   -- "high" | "medium" | "low"
    reasoning       TEXT,

    -- 追踪
    included_in_report  BOOLEAN DEFAULT FALSE,
    actioned            BOOLEAN DEFAULT FALSE,

    UNIQUE(platform, external_id)
);
```

---

## 5. 平台优先级（Phase 顺序依据）

**Phase 顺序严格按此表，从高净值到低付费意愿。**

| 排名 | 平台 | 客群质量 | 典型需求 | 自动化可行性 |
|------|------|----------|----------|-------------|
| 1 | LinkedIn | 最高 | PhD转行、职场AI upskilling、高收入家长 | 半手动，有风险 |
| 2 | Blind | 最高 | 大厂职场人、高薪专业人士转型焦虑 | 半手动，有反爬 |
| 3 | Twitter/X | 高 | AcademicTwitter PhD转行、职场AI焦虑 | 自动化，有成本 |
| 4 | Hacker News | 中高 | 技术型职场人、AI upskilling | 完全自动化 |
| 5 | Substack / Medium | 中高 | 职场转型、AI学习 | RSS自动化 |
| 6 | 小红书 | 中 | 海外华人PhD、留学生家长 | 半手动 |
| 7 | Reddit r/PhD, r/AskAcademia | 中 | PhD转行 | 完全自动化 |
| 8 | The Grad Cafe | 中 | PhD迷茫期、转型讨论 | 可scrape |
| 9 | Reddit r/datascience, r/ML | 中 | 职场转AI | 完全自动化 |
| 10 | Reddit r/cscareerquestions | 中低 | 大学生、早期职场 | 完全自动化 |
| 11 | Quora | 中低 | 混合，质量参差 | 半自动化 |
| 12 | Medium评论区 | 中低 | AI学习者 | RSS自动化 |
| 13 | Reddit r/learnmachinelearning | 低中 | 大学生，入门 | 完全自动化 |
| 14 | Discord | 低中 | 大学生，学习社群 | 违反ToS，跳过 |
| 15 | Reddit r/SAT, r/ApplyingToCollege | 低 | 高中生，不是付费方 | 完全自动化 |
| 16 | Facebook Groups | 低中 | 家长群，质量不稳定 | 高风险，暂跳过 |
| 17 | Nextdoor | 低 | 本地家长 | 不可行，跳过 |
| 18 | Stack Overflow | 低 | 技术答疑，非付费需求 | 信号少，跳过 |

---

## 6. Claude API 匹配层 — 服务菜单

**HIGH VALUE** — PhD / 职场专业人士（最高付费意愿）
- PhD to Industry Transition Coaching
- AI Career Path Planning
- Applied AI Project Coaching for Career Switchers
- AI Upskilling for Professionals

**MEDIUM VALUE** — 大学生 / 早期职场
- AI / ML Learning Path Coaching
- College-Level STEM Tutoring
- Research / Independent Project Coaching

**LOWER VALUE** — 高中生 / 家长
- AI Project Mentorship for High School Students
- AP / SAT / ACT Math Tutoring
- AI Literacy for Students

---

## 📋 Build Phases

---

### Phase 1: Project Setup + SQLite Storage

**Goal**: 项目结构、依赖、数据库初始化完毕。

**Setup**:
```bash
git clone https://github.com/dongzhang84/socrates-finds-you
cd socrates-finds-you
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
playwright install chromium
cp .env.example .env
# 填入 .env
python storage/db.py   # 初始化数据库
```

**requirements.txt**:
```
anthropic
playwright
praw
tweepy
feedparser
requests
python-dotenv
```

---

**CC Prompt 1 — SQLite 存储层:**

```
Create storage/db.py for socrates-finds-you.

Local SQLite database. Database path: data/signals.db
Create the data/ directory if it doesn't exist.

Export these functions:

init_db()
  Creates signals table if not exists. Schema:
    id TEXT PRIMARY KEY ("{platform}:{external_id}")
    platform TEXT NOT NULL
    external_id TEXT NOT NULL
    url TEXT NOT NULL
    title TEXT NOT NULL
    body TEXT
    author TEXT
    subreddit TEXT
    posted_at DATETIME
    scraped_at DATETIME DEFAULT CURRENT_TIMESTAMP
    matched BOOLEAN DEFAULT FALSE
    service_match TEXT
    client_tier TEXT
    confidence TEXT
    reasoning TEXT
    included_in_report BOOLEAN DEFAULT FALSE
    actioned BOOLEAN DEFAULT FALSE
    UNIQUE(platform, external_id)

save_signals(signals: list[dict]) → int
  INSERT OR IGNORE. Returns count of newly inserted rows.
  Log: [db] Saved {N} new signals (skipped {M} duplicates)

get_unmatched(limit: int = 200) → list[dict]
  WHERE matched=FALSE ORDER BY scraped_at DESC LIMIT limit

update_match_result(id, matched, service_match, client_tier, confidence, reasoning)
  UPDATE signals SET matched=?, service_match=?, ... WHERE id=?

get_report_candidates() → list[dict]
  WHERE matched=TRUE AND included_in_report=FALSE
  Sort in Python after fetch: high → medium → low

mark_included_in_report(ids: list[str])
  UPDATE signals SET included_in_report=TRUE WHERE id IN (...)

Use sqlite3 stdlib only. Call init_db() under if __name__ == '__main__'.
```

**Test**: `python storage/db.py` → creates `data/signals.db` with no errors.

---

### Phase 2: LinkedIn Scraper (Playwright) ⭐ 最高价值

**Goal**: 抓取 LinkedIn 公开帖子。客群质量最高。

> ⚠️ LinkedIn 反爬最强。必须 headless=False。每次最多 20 条。每天最多一次。

---

**实际实现说明（与原始 prompt 有出入，已在调试中修正）**

`scrapers/linkedin.py` 实现过程中遇到三个实际问题，逐一修复：

**问题 1：登录流程 — 已登录 / Google SSO 重定向**

LinkedIn 主页有时直接跳转到 `/feed`（Google SSO 保持登录）。原始实现无条件填表会 timeout。

修复：
```python
page.goto("https://www.linkedin.com")
if "/feed" not in page.url:
    # 如果没有 email 输入框，先点 "Sign in with email"
    email_input = page.query_selector('input[name="session_key"]')
    if not email_input:
        try:
            page.click('a[data-tracking-control-name="guest_homepage-basic_sign-in-btn"]', timeout=5000)
        except Exception:
            page.click('text=Sign in with email', timeout=5000)
        page.wait_for_selector('input[name="session_key"]', timeout=10000)
    page.fill('input[name="session_key"]', email, timeout=10000)
    page.fill('input[name="session_password"]', password, timeout=10000)
    page.click('button[type="submit"]')
    page.wait_for_url(lambda url: "feed" in url, timeout=20000)
# else: 已在 feed，跳过登录
```

**问题 2：搜索页 DOM — `.search-results-container` 已不存在**

LinkedIn 已迁移到 SDUI 组件系统，旧 class 名（`.search-results-container`、`.feed-shared-update-v2` 等）全部失效。

等待策略改为：
```python
# 优先尝试 SDUI 容器
page.wait_for_selector('div[data-sdui-screen*="SearchResultsContent"]', timeout=10000)
# 失败则 fallback 到 domcontentloaded + sleep(3)
# ⚠️ 不用 networkidle — LinkedIn 有持续 XHR，networkidle 永远不会触发
```

**问题 3：CSS class 名全部混淆 — 改用 JS DOM traversal**

LinkedIn 当前 DOM 使用混淆 class（如 `_27d29e99`、`a47a5b30`），随时可能变更。
改为在 `page.evaluate()` 里用稳定的 href 属性做 DOM traversal：

```javascript
// 找所有帖子链接
const postLinks = document.querySelectorAll('a[href*="/feed/update/"]');
for (const link of postLinks) {
    // 向上找 card root（同时含 /in/ 和 /feed/update/ 链接的祖先）
    let card = link;
    for (let i = 0; i < 20; i++) {
        card = card.parentElement;
        if (card.hasAttribute('data-sdui-screen')) break;
        if (card.querySelector('a[href*="/in/"]') && card.querySelector('a[href*="/feed/update/"]')) break;
    }
    // 作者：card 内第一个 /in/ 链接
    const author = card.querySelector('a[href*="/in/"]')?.innerText.trim() ?? '';
    // 正文：card 内最长的 <p> 文本
    let snippet = '';
    for (const p of card.querySelectorAll('p')) {
        if (p.innerText.trim().length > snippet.length) snippet = p.innerText.trim();
    }
}
```

**稳定 selector 汇总（2026-03 验证）**：

| 元素 | Selector |
|------|----------|
| 页面加载等待 | `div[data-sdui-screen*="SearchResultsContent"]` |
| 帖子永久链接 | `a[href*="/feed/update/"]` |
| Card 根节点 | 从帖子链接向上遍历，找同时含 `/in/` 和 `/feed/update/` 的祖先 |
| 作者 | Card 内第一个 `a[href*="/in/"]`（`innerText` 或 `aria-label`） |
| 正文 | Card 内所有 `<p>` 中 `innerText` 最长的 |

**Debug 模式**：

`scrape_linkedin()` 支持 `debug=True` 参数，或命令行 `--debug` flag：
```bash
python scrapers/linkedin.py --debug
# 登录后导航到第一个关键词页面，保存 debug_linkedin.html，立即返回
```
用于在 LinkedIn 改版后重新分析 DOM 结构。

**Test**:
```bash
python -c "from scrapers.linkedin import scrape_linkedin; posts = scrape_linkedin(['PhD career transition'], 5); print(len(posts), 'posts')"
# 或直接运行（全量）
python scrapers/linkedin.py
# debug 模式（只捕获 DOM）
python scrapers/linkedin.py --debug
```

---

### Phase 3: Blind Scraper (Playwright) ⭐ 最高价值

**Goal**: 抓取 Blind Career / Job Search 版块。大厂职场人聚集地。

> ⚠️ 每天最多运行一次。加随机延迟。首次登录可能有 CAPTCHA，手动解一次后可复用 session。

---

**实际实现说明（与原始 spec 有出入，调试后修正）**

**问题 1：`page.goto()` 超时**

与 LinkedIn 相同根因：Blind 有持续后台 XHR，默认 `load` 事件永远不触发。

修复：所有 `page.goto()` 调用加 `wait_until="domcontentloaded"`，同时加 `--start-maximized` 和 `no_viewport=True`。

**问题 2：48h 年龄过滤把所有 post 都过滤掉**

Blind 的 topic 页面显示的是 popular posts，不是实时 feed——实测 timestamp 都是 5-7 天前。`CUTOFF_HOURS=48` 导致 0 结果。

修复：`CUTOFF_HOURS = 168`（7 天）。

**问题 3：DOM selector 全部失效**

原始 spec 依赖 `[data-testid='feed']` 等假设选择器。实际调试（`--debug` 捕获 DOM）发现真实结构：

| 元素 | 实际 Selector（2026-03 验证） |
|------|------|
| 登录检测 | `input[type="email"]` 是否存在 |
| Post card（完整 wrapper） | `a[href*="/post/"]` — anchor 本身就是 card |
| 标题 | `[data-testid="popular-article-preview-title"]` |
| 时间戳 | `p.text-gray-600`，值为 `"6d"`、`"Mar 7"` 等 |
| 正文（post 页内） | `article`、`[role="main"]`、`main` 取最长文本 |
| 作者 | Blind 匿名，author 字段返回空字符串 |

**时间戳解析**：两种格式都需处理——
- 相对：`"5d"`, `"2h"`, `"1w"` → timedelta 计算
- 绝对：`"Mar 7"` → strptime，年份用当前年，若未来则减一年

**两阶段抓取**：先批量收集 stub（url+title+timestamp），过滤后再逐个 fetch 正文，避免对过期 post 发请求。

**Debug 模式**：`scrape_blind(debug=True)` 或 `python scrapers/blind.py --debug` → 保存 `debug_blind.html`，立即退出。

**稳定 selector 汇总（2026-03 验证）**：

| 元素 | Selector |
|------|----------|
| 页面加载等待 | `wait_until="domcontentloaded"` + `time.sleep(2)` |
| Topic URL 重定向 | `/topics/Career` → `/channels/Career`（自动跟随） |
| Post card | `a[href*="/post/"]` |
| 标题 | `[data-testid="popular-article-preview-title"]` |
| 时间戳 | `p.text-gray-600` |
| 正文（post 页） | `article` / `[role="main"]` / `main` 取最长 innerText |

**Test**:
```bash
python -c "from scrapers.blind import scrape_blind; posts = scrape_blind(3); print(len(posts), 'posts')"
# debug 模式
python scrapers/blind.py --debug
```

---

### Phase 4: Twitter/X Scraper (tweepy) ⭐ 高价值 — ⛔ 已禁用

**Goal**: 抓取 AcademicTwitter 圈子里的转行、AI 学习讨论。

> ⛔ **已禁用**：Twitter API credits 费用过高，暂停使用。`scrapers/twitter.py` 已写好但在 `main.py` 中注释掉。重新启用时取消 `main.py` 中的两处注释（`TWITTER_QUERIES` 常量 + scraper 调用块）。

`scrapers/twitter.py` 实现要点：
- `tweepy.Client(bearer_token=..., wait_on_rate_limit=True)` — 自动处理 429
- 用 `response.includes["users"]` dict 做 author_id → username 映射
- 每个 query 之间 `time.sleep(2)` 礼貌延迟
- 按 tweet id 去重，按 `created_at` 过滤 48h 内

**若需重新启用**：
```python
# main.py 中取消注释：
TWITTER_QUERIES = ["PhD leaving academia", ...]
# 以及 run_scraping() 中的 Twitter 调用块
```

---

### Phase 5: Hacker News Scraper (Firebase API) ⭐ 中高价值

**Goal**: HN 技术圈，完全免费，无需 auth。

**实现与 spec 完全一致，无偏差。** 实际运行 ~2s 取回 40-50 条符合条件的 stories（100 条 ID 并发 fetch，过滤后约 40-50%）。

关键实现细节：
- `ThreadPoolExecutor(max_workers=10)` 并发 fetch，不保证顺序（`as_completed`）
- 过滤链：deleted/dead → type != story → no title → score < 2 → older than 48h
- `body` 来自 item 的 `text` 字段（Ask HN 类型有，普通链接没有）

**Test**:
```bash
python -c "from scrapers.hackernews import scrape_hn; posts = scrape_hn(20); print(len(posts), 'stories')"
```

---

### Phase 6: RSS Scraper (Substack / Medium) ⭐ 中高价值

**Goal**: 订阅职场转型、AI 学习类 newsletter 的评论和文章。

**实际实现说明**

**问题：`feedparser.parse(url)` SSL 证书验证失败（macOS）**

macOS 系统 Python 的 SSL 证书链不完整，`feedparser` 用 urllib 直接 fetch URL 会报 `CERTIFICATE_VERIFY_FAILED`。

修复：先用 `requests.get()` fetch 内容，再传 bytes 给 `feedparser.parse(resp.content)`：
```python
resp = requests.get(feed_url, timeout=15, headers={"User-Agent": "Mozilla/5.0"})
parsed = feedparser.parse(resp.content)  # 传 bytes，不传 URL
```

**已知 feed 状态（2026-03 验证）**：

| Feed | 状态 |
|------|------|
| `every.to/feed` | ❌ 404，URL 已失效 |
| `lennysnewsletter.com/feed` | ✅ 正常，返回 3 条/48h |
| `oneusefulthing.org/feed` | ✅ 正常（发布频率低，48h 内常为 0） |

`external_id` 处理：entry id 若超过 64 字符（常见于 Substack URL 格式），hash 为 12 位 MD5。

**Test**:
```bash
python -c "from scrapers.rss import scrape_rss; posts = scrape_rss(); print(len(posts), 'entries')"
```

---

### Phase 7: 小红书 Scraper (Playwright) ⭐ 中价值

**Goal**: 海外华人 PhD、留学生家长圈子。

> ⚠️ 小红书反爬中等。需要手机号登录。建议 headless=False。

---

**CC Prompt 7 — 小红书 scraper:**

```
Create scrapers/xiaohongshu.py for socrates-finds-you.

Use Playwright sync API.

Export: scrape_xiaohongshu(keywords: list[str], max_posts: int = 20) → list[dict]

Logic:
1. Load XIAOHONGSHU_PHONE and XIAOHONGSHU_PASSWORD from .env
2. Launch Chromium headless=False
3. Navigate to https://www.xiaohongshu.com
4. Handle login flow (phone + password or QR code)
5. For each keyword:
   - Use search: https://www.xiaohongshu.com/search_result?keyword={urllib.parse.quote(keyword)}
   - Collect post cards: title + URL
   - time.sleep(random.uniform(2.0, 4.0))
6. Click into each post to get body text, limit to max_posts total
7. Return list of dicts:
  {
    "platform": "xiaohongshu",
    "external_id": slug from URL,
    "url": full post URL,
    "title": title[:120],
    "body": body[:2000],
    "author": author name,
    "subreddit": None,
    "posted_at": timestamp if available else None
  }

Default keywords (from main.py):
  ["PhD转行", "留学生找工作", "AI学习", "数学辅导", "SAT备考", "美国读博"]

Wrap all in try/except. Log: [xiaohongshu] {N} posts scraped
```

> ⚠️ **小红书 scraper 尚未实现**（`scrapers/xiaohongshu.py` 不存在）。`main.py` 中调用被 try/except 包裹，失败时 log warning 继续。

---

### Phase 8: Reddit Scraper (公开 JSON API)

**Goal**: 覆盖 PhD 转行、职场 AI、高中生等多个 subreddit。

**实际实现说明**

原始 spec 使用 PRAW，但 Reddit 不再允许新应用注册。改用公开 JSON API，**无需任何认证**：

```
GET https://www.reddit.com/r/{subreddit}/new.json?limit=50
Headers: {"User-Agent": "socrates-finds-you/1.0"}
```

额外过滤（spec 未提）：作者为 `[deleted]` 或 `AutoModerator` 的 post 跳过。

实测产量：10 个 subreddit，每次约 380 条 posts（48h 内），是最高产量的 scraper。

**Test**:
```bash
python -c "from scrapers.reddit import scrape_reddit; posts = scrape_reddit(['PhD'], 10); print(len(posts), 'posts')"
```

---

### Phase 9: The Grad Cafe Scraper

**Goal**: PhD 群体转型讨论密集，和 Reddit r/PhD 并列。

**实际实现说明**

**问题：Forum 18 不再是 Career Advice**

`/forum/18-career-advice/` 重定向到 `/forum/18-city-guide/`（City Guide 板块）。

实际使用的论坛：
- **Forum 72** (`/forum/72-jobs/`) — Jobs
- **Forum 21** (`/forum/21-officially-grads/`) — Officially Grads

**DOM 结构（2026-03 验证）**：

| 元素 | Selector / 属性 |
|------|------|
| Thread link | `a[href*="/topic/"]` inside `h4.ipsDataItem_title` |
| 时间戳 | `<time datetime="2024-06-04T16:24:46Z">` — ISO in `datetime` attribute |
| 作者 | `<a href="/profile/...">` in `div.ipsDataItem_meta`（实测常为空，whitespace 问题）|
| 正文 | 第一个 `<div data-role="commentContent">` |

两个 stdlib `html.parser` 状态机：`_ThreadListParser`（列表页）和 `_PostBodyParser`（帖子页）。

> ⚠️ **Author 字段实测为空**：GradCafe 的 HTML 在 author anchor 内有多层 whitespace text node，解析器捕获不到。`author` 字段返回 `""`，不影响功能。

**Test**:
```bash
python -c "from scrapers.gradcafe import scrape_gradcafe; posts = scrape_gradcafe(5); print(len(posts), 'threads')"
```

---

### Phase 10: Claude API Matching Layer

**Goal**: 语义匹配，判断每条信号对应哪个服务、客群价值高低。

---

**CC Prompt 10 — Claude matcher:**

```
Create matcher/claude_match.py for socrates-finds-you.

Use Anthropic Python SDK. Load ANTHROPIC_API_KEY from .env.

Export: match_signals(signals: list[dict]) → list[dict]
  Input: list of signal dicts (id, title, body, platform, subreddit)
  Output: same list + matched, service_match, client_tier, confidence, reasoning

Process in batches of 10. Model: claude-sonnet-4-5

System prompt:
"You are a matching assistant for Dong Zhang, Ph.D. — a STEM and AI mentor.

He offers these services:

HIGH VALUE (PhD students, professionals):
- PhD to Industry Transition Coaching
- AI Career Path Planning
- Applied AI Project Coaching for Career Switchers
- AI Upskilling for Professionals

MEDIUM VALUE (college students, early-career):
- AI / ML Learning Path Coaching
- College-Level STEM Tutoring
- Research / Independent Project Coaching

LOWER VALUE (high school students, parents):
- AI Project Mentorship for High School Students
- AP / SAT / ACT Math Tutoring
- AI Literacy for Students"

User prompt per batch:
"Evaluate these posts. For each return:
- matched: true if there is a real learning/coaching/transition need
- service_match: specific service name from the list (or null)
- client_tier: 'high', 'medium', or 'low'
- confidence: 'high', 'medium', or 'low'
- reasoning: one sentence max

Posts:
{json.dumps([{"id": s["id"], "title": s["title"], "body": (s.get("body") or "")[:600], "platform": s["platform"], "subreddit": s.get("subreddit")} for s in batch])}

Return a JSON array only. No other text."

Strip ```json fences before json.loads().
Handle parse errors: log and skip batch.
Log: [matcher] Batch {N}: {M}/{K} matched
Log: [matcher] Total: {matched}/{total} matched
```

**2026-03-20 Prompt Rewrite — Conversion Likelihood Scoring**

The matching prompt was rewritten to score leads by **conversion likelihood** rather than service category match. Key change: Claude now decides `matched=false` for pure venting, complaints, or unrelated posts — not just "no relevant service."

New scoring tiers:
- **HIGH** (`matched=true`, `client_tier="high"`) — explicit ask with clear action intent: "how do I transition from PhD to industry", "I want to learn AI/ML, where do I start", parent looking for tutor
- **MEDIUM** (`matched=true`, `client_tier="medium"`) — interested but hesitant or direction unclear
- **NO** (`matched=false`) — venting ("PhD is so hard"), complaint with no ask, unrelated, sharing news

The system prompt ends with: *"Be strict: when in doubt, set matched=false. A false negative is better than a false positive that wastes outreach effort."*

**实际实现说明**

**问题 1：Claude 可能重排返回数组**

如果按数组索引位置合并结果，一旦 Claude 返回顺序与输入不同就会错位。

修复：按 `id` 字段合并，把结果建成 `{id: result}` dict，再遍历原始 signals 做 patch：
```python
result_map = {r["id"]: r for r in parsed_results if "id" in r}
for s in batch:
    if s["id"] in result_map:
        s.update(result_map[s["id"]])
```

**问题 2：Claude 返回带 ` ```json ``` ` 围栏**

尽管 prompt 明确要求 "Return a JSON array only. No other text."，Claude 有时仍加围栏。

修复：`_strip_fences()` 用正则在 `json.loads()` 前清洗：
```python
def _strip_fences(text: str) -> str:
    return re.sub(r"^```(?:json)?\s*|\s*```$", "", text.strip(), flags=re.MULTILINE)
```

**问题 3：单批解析失败不应中止整个 run**

per-batch try/except 同时捕获 `json.JSONDecodeError` 和通用 `Exception`，均 `continue` 跳到下一批，确保部分失败不影响其他批次。

**Test**:
```bash
python -c "
from matcher.claude_match import match_signals
test = [{'id': 'test:1', 'title': 'Just finished Physics PhD, completely lost on how to break into ML', 'body': 'Been in academia 6 years, no idea how to position myself for industry roles', 'platform': 'reddit', 'subreddit': 'PhD'}]
print(match_signals(test))
"
```

---

### Phase 11: Daily Report Generator

**Goal**: 生成可操作的每日 Markdown 报告，按客群价值排序。

---

**CC Prompt 11 — Report generator:**

```
Create reporter/daily_report.py for socrates-finds-you.

Export: generate_report() → str
  Saves to output/report_YYYY-MM-DD.md (create output/ if not exists)

Logic:
1. storage.db.get_report_candidates()
2. Split by client_tier, sort: high → medium → low (in Python, not SQL)
3. Generate markdown:

# socrates-finds-you — Daily Report {YYYY-MM-DD}

**{total} leads matched** — {H} high / {M} medium / {L} low value

---

## 🔴 High Value (PhD / Professionals)

### 1. {title}
- **Platform**: {platform}{" · r/" + subreddit if subreddit else ""}
- **Service**: {service_match}
- **Confidence**: {confidence}
- **Why**: {reasoning}
- **Link**: {url}
- **Posted**: {posted_at or "unknown"}

---

## 🟡 Medium Value (College / Early Career)
[same format]

---

## 🟢 Lower Value (High School / Students)
[same format]

---
*Generated {UTC timestamp}. Mark leads as actioned in signals.db after review.*

4. Save to output/report_{date}.md
5. mark_included_in_report(all included ids)
6. If zero signals: generate "no leads today" report, still save
Log: [reporter] Saved: output/report_{date}.md ({N} leads)
```

**实际实现说明**

**行为与 spec 基本一致，以下几点值得注意：**

- **零信号情况**：`get_report_candidates()` 返回空列表时仍正常生成报告，内容为 `*No leads today. Run again tomorrow.*`，文件依然写入 `output/report_YYYY-MM-DD.md`。
- **排序**：`TIER_ORDER = {"high": 0, "medium": 1, "low": 2}` 在 Python 层 sort，不依赖 SQL ORDER BY（SQL 按字母排会导致 high/low/medium 错序）。
- **`generate_report()` 返回值**：返回 `str`（路径），`main.py` 用于最终日志打印。

**2026-03-20 Extensions:**

- `generate_report()` now writes **both** `output/report_YYYY-MM-DD.md` and `output/report_YYYY-MM-DD.html`.
- All timestamps use **Seattle time** (`ZoneInfo("America/Los_Angeles")`), not UTC. Variable renamed `now_utc` → `now`.
- `_group_by_tier(signals)` applies `SERVICE_PRIORITY` sort within each tier (same priority map as `app.py`): AI Career Path Planning (0) → AI Upskilling (1) → Applied AI Project (2) → PhD Transition (3) → AI/ML Learning (4) → AP/SAT (5) → STEM Tutoring (6) → everything else (99).
- HTML report is fully standalone — no Flask, no external CSS. Inline `<style>`, pure JS Copy button (`navigator.clipboard.writeText`), pure JS Mark as Replied toggle (visual only, resets on refresh). Each reply div gets a unique `id="reply-{tier}-{idx}"` for the clipboard JS to target.
- **Regenerating a past date's HTML**: `get_report_candidates()` only returns signals with `included_in_report=FALSE`, so re-running the reporter won't pick up past dates. Query the DB directly by date and call `_build_html()`:
  ```python
  rows = conn.execute("SELECT * FROM signals WHERE matched=TRUE AND DATE(scraped_at)=?", ("2026-03-19",)).fetchall()
  html = _build_html([dict(r) for r in rows], "2026-03-19", datetime.now(ZoneInfo("America/Los_Angeles")))
  Path("output/report_2026-03-19.html").write_text(html)
  ```

---

### Phase 13: GitHub Pages Publishing (`push_report.sh`)

**Goal**: One-command publish of the daily HTML report to a public GitHub Pages URL.

**Script behavior**:
1. Determines date: optional `$1` arg, or `TZ="America/Los_Angeles" date +%Y-%m-%d`
2. If `output/report_${TODAY}.html` exists → skip generation
3. Else → `python3 reporter/daily_report.py`
4. `git checkout -b gh-pages 2>/dev/null || git checkout gh-pages`
5. `cp output/report_${TODAY}.html index.html`
6. `git add index.html && git commit -m "report: ${TODAY}"`
7. `git push origin gh-pages`
8. `git checkout main`

**Usage**:
```bash
./push_report.sh                    # today
./push_report.sh 2026-03-19        # specific date
```

Live URL: https://dongzhang84.github.io/socrates-finds-you

**Note**: `gh-pages` branch only needs `index.html` at the root. GitHub Pages serves it automatically once the branch exists and Pages is enabled in repo Settings.

---

### Phase 12: Main Entry Point

**Goal**: 单一命令跑完全流程，scrapers 按平台价值顺序执行。

---

**CC Prompt 12 — main.py:**

```
Create main.py for socrates-finds-you.

`python main.py` runs everything end-to-end.

Scraper execution order follows platform priority (high value first):
1. storage.db.init_db()
2. Scrapers (in this order):
   a. linkedin.scrape_linkedin(keywords=[...])    — 最高价值
   b. blind.scrape_blind(30)                      — 最高价值
   c. twitter.scrape_twitter(queries=[...])        — 高价值
   d. hackernews.scrape_hn(100)                   — 中高价值
   e. rss.scrape_rss(feeds=[...])                 — 中高价值
   f. xiaohongshu.scrape_xiaohongshu(keywords=[...]) — 中价值
   g. reddit.scrape_reddit(subreddits=[...])       — 中价值
   h. gradcafe.scrape_gradcafe(30)                — 中价值

   Wrap b, c, f in try/except — these are most likely to fail.
   Wrap a in try/except with clear message if LinkedIn blocks.

3. storage.db.save_signals(all_signals)
4. unmatched = storage.db.get_unmatched(limit=150)
5. If unmatched: run match_signals(), update_match_result() for each
6. generate_report()
7. Print total runtime

argparse flags:
  --high-value-only   Run LinkedIn + Blind + Twitter only (skip lower-tier scrapers)
  --no-browser        Skip all Playwright scrapers (LinkedIn, Blind, 小红书)
  --reddit-only       Run Reddit + HN + RSS + Grad Cafe only (no Playwright, no Twitter API)
  --no-scrape         Skip scraping, re-run matching + report on existing data
  --report-only       Skip scraping and matching, just regenerate report

Log: [main] Done in {elapsed:.1f}s — {N} new signals, {M} matched, report saved
```

**实际实现说明**

**偏差 1：Twitter 已禁用**

`TWITTER_QUERIES` 常量和 scraper 调用均已注释掉，注释内容为 `# Twitter disabled — API credits too expensive, re-enable when needed.`。`--high-value-only` 实际只跑 LinkedIn + Blind（不含 Twitter）。

**偏差 2：`id` 字段在 main.py 中拼接，scraper 不负责**

各 scraper 只返回 `platform` 和 `external_id`，不设置 `id`。`main.py` 在 `save_signals()` 前统一拼接：
```python
for s in all_signals:
    if "id" not in s:
        s["id"] = f"{s['platform']}:{s['external_id']}"
```

**偏差 3：增加详细进度日志**

原始 spec 只要求最终 summary log。实际实现在每个 scraper 开始前和结束后都有 `logger.info()`，Claude matching 开始前也有日志，避免运行时"无声静止"（matching 阶段约需 2 分钟无输出）。

**`--reddit-only` 实际行为**：跑 HN + RSS + Reddit + GradCafe（所有无浏览器 API scrapers）。Twitter 禁用后，此 flag 是最稳定、无成本的测试方式。

**Run options**:
```bash
python main.py                    # 全量，所有平台（Twitter 已禁用）
python main.py --high-value-only  # 只跑 LinkedIn + Blind（Twitter 已禁用）
python main.py --no-browser       # 跳过 Playwright，适合 cron / 无 GUI 环境
python main.py --reddit-only      # 只跑免费无风险的平台，适合测试
python main.py --no-scrape        # 重新匹配已抓取的数据
python main.py --report-only      # 只重新生成报告
```

---

## 7. Sprint Tracking

**已完成配置（socrates-finds-you）**：
- `.github/workflows/sprint-report.yml` ✅
- `.github/workflows/notify-playbook.yml` ✅
- `SPRINT.md` ✅
- `scripts/extract-sprint-summary.py` ✅
- `PLAYBOOK_TOKEN` secret 已设置 ✅

每次 push 到 main → 自动更新 `indie-product-playbook` 的 sprint 记录。

---

## 8. 运行成本估算

| 组件 | 费用 |
|------|------|
| Claude API (~150 signals × ~500 tokens/run) | ~$0.05–0.20/run |
| Twitter API v2 (免费 tier 500k reads/月) | 免费（量少时） |
| Reddit API (PRAW) | 免费 |
| HN Firebase API | 免费 |
| RSS | 免费 |
| LinkedIn / Blind / 小红书（个人账号） | 免费 |
| SQLite 本地存储 | 免费 |
| **月度估算（每天运行）** | **~$1–6/月** |

---

## 9. 常见坑

| 坑 | 原因 | 解法 |
|----|------|------|
| LinkedIn 检测 headless | 自动化检测 | headless=False + `--disable-blink-features=AutomationControlled` |
| LinkedIn 已登录但仍尝试填表 | Google SSO 保持登录，跳转直接到 /feed | `goto` 后先检查 `/feed` in `page.url`，已登录则跳过表单 |
| LinkedIn 主页无 email 输入框 | 新版主页默认显示 Google SSO 按钮 | 先点 "Sign in with email" 按钮再填表；用 `data-tracking-control-name` 或 `text=` 定位 |
| LinkedIn 搜索页等待 networkidle 超时 | LinkedIn 有持续后台 XHR，networkidle 永远不触发 | 改用 `domcontentloaded` + `time.sleep(3)` |
| LinkedIn selector 全部失效 | LinkedIn 迁移到 SDUI，class 名全部混淆（如 `_27d29e99`） | 用 `page.evaluate()` JS traversal，依赖 `href` 属性而非 class 名；等待用 `data-sdui-screen*="SearchResultsContent"` |
| LinkedIn DOM 再次改版 | LinkedIn 经常更新 | 运行 `python scrapers/linkedin.py --debug` 保存 `debug_linkedin.html`，重新分析结构 |
| Blind 首次登录 CAPTCHA | 新 browser profile | headless=False 手动解一次，之后保存 browser state |
| Twitter API 429 | 超过 rate limit | 每个 query 之间 time.sleep(2)，减少 max_per_query |
| Claude 返回带 ```json 的响应 | Claude 有时加围栏 | strip 后再 json.loads() |
| SQLite 排序错乱 | SQL 按字母排 high/low/medium | fetch 后在 Python sort |
| LinkedIn posted_at 为 None | 搜索结果不暴露时间戳 | 用 scraped_at 替代排序 |
| 小红书需要手机验证码 | 新设备登录 | 第一次手动登录后保存 browser state |
| Playwright 在 cron 无 GUI | headless=False 在无 display 环境报错 | cron 里用 --no-browser flag |
| 信号量太多导致 Claude 超时 | 一次送太多 | limit=150，batch size=10 |
| Grad Cafe 结构变化 | HTML 结构随时可能改 | 用 try/except，定期检查 scraper 是否还能跑 |
| Blind `page.goto()` 超时 | 与 LinkedIn 相同：Blind 有持续后台 XHR，默认 `load` 事件永远不触发 | 所有 `page.goto()` 加 `wait_until="domcontentloaded"` + `time.sleep(2)` |
| Blind 0 条结果 | Blind 显示的是 popular posts（5-7 天前），48h 截止过滤全部清空 | 改为 `CUTOFF_HOURS = 168`（7 天）|
| Blind selector 失效 | 原始 spec 使用假设 selector，实际 DOM 不同 | 用 `--debug` 捕获真实 DOM，实测 selector：card=`a[href*="/post/"]`，标题=`[data-testid="popular-article-preview-title"]` |
| RSS SSL 证书失败（macOS） | macOS Python SSL 链不完整，`feedparser.parse(url)` 用 urllib 会报 `CERTIFICATE_VERIFY_FAILED` | 先用 `requests.get()` fetch，再 `feedparser.parse(resp.content)` 传 bytes 而非 URL |
| Reddit PRAW 无法注册新应用 | Reddit 不再允许新 app 注册 | 改用公开 `.json` API：`reddit.com/r/{sub}/new.json`，无需任何认证 |
| Grad Cafe Forum 18 不是 Career Advice | Forum 18 已变更为 City Guide | 改用 Forum 72 (Jobs) + Forum 21 (Officially Grads) |
| main.py 运行时无任何输出 | matching 阶段 Claude API 调用约 2 分钟，缺少进度日志 | 在每个 scraper 开始/结束、matching 开始前加 `logger.info()`，明确可见每步进度 |
| Claude 按数组位置合并结果出错 | Claude 偶尔调整返回数组顺序 | 改为按 `id` 字段建 dict 合并，而非依赖数组索引位置 |

---

## 10. 新项目 Checklist

```
□ git clone + cd socrates-finds-you
□ python -m venv .venv && source .venv/bin/activate
□ pip install -r requirements.txt
□ playwright install chromium
□ cp .env.example .env → 填入所有凭证
□ python storage/db.py → 确认 data/signals.db 创建成功
□ python main.py --reddit-only → 先跑最稳定的平台验证全流程
□ 检查 output/ 有报告生成，格式正确
□ python main.py --high-value-only → 验证 LinkedIn + Blind + Twitter
□ python main.py → 全量跑一次
□ 确认 .gitignore 包含 .env / data/ / output/
□ SPRINT.md 存在，GitHub Actions 已配置
□ indie-product-playbook/ideas/README.md 表格里有 socrates-finds-you 行 ✅
□ PLAYBOOK_TOKEN secret 已配置 ✅
```

---

## 🔄 Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-03 | 1.0 | 初版 |
| 2026-03 | 2.0 | 按 STANDARD.md 重构，统一格式 |
| 2026-03 | 3.0 | Phase 顺序改为按客群价值排序（对照 02-platforms.md）；新增 Twitter/X、小红书、The Grad Cafe scraper；main.py 新增 --high-value-only 和 --no-browser flag |
| 2026-03 | 3.1 | Phase 2 实装修正：(1) 登录流程适配 Google SSO 保持登录场景；(2) 新增 "Sign in with email" 按钮点击（LinkedIn 主页改版）；(3) 搜索页等待从 networkidle 改为 domcontentloaded；(4) 所有 selector 改为 JS DOM traversal（LinkedIn 迁移 SDUI，class 名全混淆）；(5) 新增 debug=True / --debug 模式 |
| 2026-03 | 3.2 | 全部模块实装修正：Phase 3 (Blind) domcontentloaded + CUTOFF_HOURS=168 + 实测 selector；Phase 4 (Twitter) 标记为已禁用；Phase 5 (HN) 确认与 spec 一致；Phase 6 (RSS) macOS SSL 修复（requests+bytes）；Phase 7 (小红书) 标记为未实现；Phase 8 (Reddit) 从 PRAW 改为公开 JSON API；Phase 9 (Grad Cafe) Forum 18 失效改用 72+21，实测 DOM selector；Phase 10 (matcher) 按 id 合并结果 + fence stripping；Phase 11 (reporter) 零信号情况处理；Phase 12 (main.py) Twitter 禁用 + id 拼接位置 + 全程进度日志；常见坑表新增 9 条实测 bug |
| 2026-03-20 | 4.0 | Phase 10 matcher prompt rewritten for conversion likelihood scoring (HIGH/MEDIUM/NO). Phase 11 reporter now generates HTML + Markdown, Seattle timezone, Copy + Mark as Replied buttons in HTML. Phase 13 added: push_report.sh → GitHub Pages. Lead sort order within tiers by service priority added to both app.py and reporter. |
