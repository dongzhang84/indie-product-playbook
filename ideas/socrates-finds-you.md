# Project Proposal: socrates-finds-you

## 一句话描述

一个自动化系统，持续监控多个平台上的公开讨论，识别出有真实需求的潜在客户，并将其与服务提供者的能力做精准匹配，最终输出一份每日可操作的线索清单。

---

## 背景与动机

### 问题

高价值服务（STEM tutoring、AI mentorship、PhD转行咨询）的提供者，面临一个核心困境：

- 平台型接单（Wyzant、Care.com）竞争激烈、压价严重、客群质量低
- 冷冲陌生人（cold outreach）成功率极低
- 人工在各平台东找西找，效率极差、难以持续

真实需求其实每天都在网上出现——有人在Reddit发帖说"读完PhD不知道怎么进工业界"，有人在Blind吐槽"学了半年ML还是找不到方向"，有人在Twitter感叹"孩子SAT数学怎么都提不上去"——但这些信号分散、杂乱、转瞬即逝。

### 解决方案

构建一个自动化pipeline，主动去这些平台抓取信号、过滤噪音、匹配需求，每天输出一份整理好的线索清单，让服务提供者只需要专注于判断和触达，而不是寻找。

---

## 目标用户

本项目的第一个使用者是 **Dong Zhang, Ph.D.**，一位提供以下服务的独立导师与顾问：

- SAT / AP / ACT Math Tutoring
- AI Project Mentorship（面向高中生）
- College-Level STEM Tutoring
- AI / ML Learning Path Coaching
- PhD to Industry Transition Coaching
- Applied AI Project Coaching for Career Switchers
- AI Upskilling for Professionals

未来可扩展为通用工具，适用于任何提供高价值个人服务的独立顾问、导师或教练。

---

## 系统架构

```
平台数据源
    ↓
Scraper层（Playwright / API / RSS）
    ↓
原始数据存储（JSON）
    ↓
Claude API语义匹配层
    ↓
线索评分 + 服务匹配
    ↓
每日输出报告（Markdown / CSV）
```

---

## 数据来源平台

按客群质量从高到低排序：

| 排名 | 平台 | 客群质量 | 典型需求 | 抓取方式 |
|------|------|----------|----------|----------|
| 1 | LinkedIn | 最高 | PhD转行、职场AI upskilling、高收入家长 | Playwright，半手动 |
| 2 | Blind | 最高 | 大厂职场人、高薪专业人士转型焦虑 | Playwright，有反爬 |
| 3 | Twitter/X | 高 | AcademicTwitter PhD转行、职场AI焦虑 | API，有成本 |
| 4 | Hacker News | 中高 | 技术型职场人、AI upskilling | 官方API，完全自动化 |
| 5 | Substack评论区 | 中高 | 职场转型、AI学习 | RSS自动化 |
| 6 | 小红书 | 中 | 海外华人PhD、留学生家长 | 半手动 |
| 7 | Reddit r/PhD, r/AskAcademia | 中 | PhD转行 | 官方API，完全自动化 |
| 8 | The Grad Cafe | 中 | PhD迷茫期、转型讨论 | Scraper，难度不高 |
| 9 | Reddit r/datascience, r/MachineLearning | 中 | 职场转AI | 官方API，完全自动化 |
| 10 | Reddit r/cscareerquestions | 中低 | 大学生、早期职场 | 官方API，完全自动化 |
| 11 | Quora | 中低 | 混合，质量参差 | 半自动化 |
| 12 | Medium评论区 | 中低 | AI学习者，付费意愿不稳定 | RSS自动化 |
| 13 | Reddit r/learnmachinelearning | 低中 | 大学生，入门学习者 | 官方API，完全自动化 |
| 14 | Discord | 低中 | 大学生，学习社群 | 半手动，违反ToS |
| 15 | Reddit r/SAT, r/ApplyingToCollege | 低 | 高中生本人，不是付费方 | 官方API，完全自动化 |
| 16 | Facebook Groups | 低中 | 家长群，质量不稳定 | 半手动，高风险 |
| 17 | Nextdoor | 低 | 本地家长 | 基本不可行 |
| 18 | Stack Overflow | 低 | 技术答疑为主，非付费需求 | 有API但信号少 |

---

## 执行分阶段计划

### Phase 1：Blind Scraper（第一个跑通）

**目标：** 抓取Blind上Career / AI / PhD相关版块的帖子

**步骤：**
1. 用Playwright模拟浏览器登录Blind
2. 导航到目标版块：Career, Job Search, AI/ML, PhD
3. 抓取帖子标题、正文摘要、发帖时间、链接
4. 存储为本地JSON文件
5. 加入基础关键词过滤（见下方关键词列表）

**目标版块关键词：**
- 转行类：career change, transition, leaving academia, PhD to industry, quit PhD
- 需求类：mentor, coach, guidance, lost, confused, don't know where to start
- AI学习类：learn ML, learn AI, machine learning roadmap, AI career
- 家长类：my kid, SAT, college application, STEM tutor

**输出：** `output/blind_raw_YYYY-MM-DD.json`

---

### Phase 2：Claude API 语义匹配层

**目标：** 对原始抓取数据做语义层面的过滤与匹配

**步骤：**
1. 读取原始JSON
2. 每条帖子送入Claude API，prompt如下：

```
你是一个需求匹配助手。以下是一条从社交平台抓取的帖子内容：

[帖子内容]

请判断：
1. 这条帖子是否包含真实的学习/转型/辅导需求？（是/否）
2. 如果是，匹配以下哪个服务类型？
   - SAT/AP/ACT Math Tutoring
   - AI Project Mentorship for High School Students
   - College STEM Tutoring
   - AI/ML Learning Path Coaching
   - PhD to Industry Transition Coaching
   - Applied AI Project Coaching for Career Switchers
   - AI Upskilling for Professionals
3. 匹配置信度（高/中/低）
4. 一句话说明匹配理由

只输出JSON格式，不要其他内容。
```

3. 保存匹配结果

**输出：** `output/matched_YYYY-MM-DD.json`

---

### Phase 3：LinkedIn Scraper

**目标：** 抓取LinkedIn上的public post

**注意事项：**
- LinkedIn有较强反爬机制，需要限速
- 只抓public post，不登录抓取私人内容
- 建议每次运行间隔随机化，模拟人工行为

**步骤：**
1. 用Playwright搜索目标关键词
2. 抓取post内容、作者信息、链接
3. 同样经过Claude API语义过滤

**目标搜索关键词：**
- "PhD career transition"
- "leaving academia"
- "learn machine learning"
- "AI mentor"
- "career change AI"

**输出：** `output/linkedin_raw_YYYY-MM-DD.json`

---

### Phase 4：Reddit Scraper

**目标：** 覆盖中等客群，补充线索量

**优势：** Reddit有官方API，完全合规，最稳定

**目标Subreddit：**
- r/PhD
- r/AskAcademia
- r/datascience
- r/MachineLearning
- r/learnmachinelearning
- r/cscareerquestions
- r/SAT
- r/ApplyingToCollege

**步骤：**
1. 用PRAW（Reddit官方Python库）抓取新帖和热帖
2. 关键词过滤
3. Claude API语义匹配

**输出：** `output/reddit_raw_YYYY-MM-DD.json`

---

### Phase 5：每日汇总报告

**目标：** 把所有平台的匹配结果合并，生成一份可操作的每日报告

**报告格式：**

```markdown
# 每日线索报告 YYYY-MM-DD

## 高优先级（置信度：高）

### 1. [帖子标题]
- 来源：Blind
- 匹配服务：PhD to Industry Transition Coaching
- 匹配理由：发帖者明确表示从物理PhD转行，寻求方向建议
- 链接：[URL]

---

## 中优先级（置信度：中）
...

## 低优先级（置信度：低）
...
```

**输出：** `output/daily_report_YYYY-MM-DD.md`

---

## 文件结构

```
socrates-finds-you/
├── docs/
│   ├── 01-services.md          # 服务清单
│   └── 02-platforms.md         # 平台优先级表
├── scrapers/
│   ├── blind.py                # Blind scraper
│   ├── linkedin.py             # LinkedIn scraper
│   ├── reddit.py               # Reddit scraper
│   └── utils.py                # 公共工具函数
├── matcher/
│   └── claude_match.py         # Claude API语义匹配
├── reporter/
│   └── daily_report.py         # 每日报告生成
├── output/                     # 每日输出（gitignore）
├── ideas/                      # 项目构思文档
├── README.md
├── requirements.txt
└── .env.example                # API key模板
```

---

## 技术栈

| 组件 | 技术 |
|------|------|
| 浏览器自动化 | Playwright (Python) |
| Reddit抓取 | PRAW |
| 语义匹配 | Claude API (claude-sonnet) |
| 数据存储 | 本地JSON / CSV |
| 报告输出 | Markdown |
| 运行方式 | 本地手动运行，后期可接cron job |

---

## 核心设计原则

1. **人机分工清晰：** 自动化负责找信号、过滤、匹配；人负责判断和触达
2. **不做自动化冷冲：** 冷冲成功率极低，这部分保留人工判断
3. **先跑通再优化：** Phase 1先本地跑通，不追求完美
4. **合规优先：** 优先使用官方API；对于无API的平台，控制频率，不做激进抓取

---

## 成功标准

- Phase 1完成：每天能稳定从Blind抓到20+条相关帖子
- Phase 2完成：Claude匹配准确率达到70%以上（人工抽查）
- Phase 5完成：每天早上能看到一份整理好的线索报告
- 实际转化：每周至少1-2条线索值得人工触达

---

## 后续可扩展方向

- 加入更多平台（小红书、The Grad Cafe、Twitter/X）
- 加入线索追踪（哪些触达了、结果如何）
- 扩展为通用工具，支持其他独立顾问使用
- 加入简单的web界面，替代markdown报告

## Sprint Summary

_Last updated: 2026-03-09_

Week 2 _(current)_ · 2026-03-09 to 2026-03-15
Status: ❌ Stalled
Active days: 0 / 7
Total commits: 0

Week 1 · 2026-03-02 to 2026-03-08
Status: ❌ Stalled
Active days: 1 / 7
Total commits: 4
