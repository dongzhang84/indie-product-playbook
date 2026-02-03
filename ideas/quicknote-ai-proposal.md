# QuickNote AI - Product Proposal

## One-liner
"Dump your thoughts, find them instantly with AI"

## Problem
- 笔记app太复杂（Notion需要整理结构）
- 搜索只能找关键词，找不到相似内容
- "我记得写过，但找不到了"

## Solution
最简单的笔记 + 最强大的AI搜索
- 打开就写，不需要分类/标签/文件夹
- AI理解你写的内容
- 用自然语言搜索，立即找到

## Target Users
- Indie makers（想法很多）
- 知识工作者（会议记录、阅读笔记）
- 学生（课程笔记、论文想法）

## Core Features (MVP - Week 1)
1. **Quick Capture** - 打开就能写，自动保存
2. **AI Search** - 语义搜索，理解意思而非关键词
3. **Timeline** - 按时间浏览所有笔记

## Tech Stack
- Next.js + TypeScript + Tailwind
- Supabase (PostgreSQL + pgvector)
- OpenAI API (embeddings)
- Stripe (payment)
- Vercel (deploy)

## Pricing
- **Free**: 100 notes
- **Pro**: $3/month - unlimited

## Differentiation
| Feature | QuickNote AI | Notion | Evernote | Apple Notes |
|---------|--------------|--------|----------|-------------|
| 简单度 | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| AI搜索 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐ |
| 价格 | $3/月 | $10/月 | $10/月 | 免费 |
| 跨平台 | Web | Web | All | Apple only |

## Why This Works
✅ 真实痛点（每个人都找不到笔记）
✅ 极致简单（零学习成本）
✅ AI真正有用（解决搜索问题）
✅ 定价合理（$3容易接受）
✅ Solo friendly（1周MVP）

## Success Metrics
**Week 1:**
- 100+ visits
- 20+ signups
- 5+ active users
- 1-2 paid users

**Week 4:**
- 500+ visits
- 50+ signups
- 10+ active users
- 5+ paid ($15 MRR)

## Competition
- Remem AI: $20/月太贵，iOS only
- Notion: 功能强但太复杂
- Evernote: 老旧，搜索弱
- Apple Notes: 免费但搜索只能关键词

## Phase 2 (如果成功)
- Browser extension
- Mobile app
- Voice input
- Smart auto-tags
- Export (Markdown/PDF)

## Risk
⚠️ "Nice to have" vs "Must have"
⚠️ 需要养成习惯（不是instant value）
⚠️ AI成本（每个note生成embedding）

## Timeline
- Week 1: MVP开发
- Week 2: Product Hunt launch
- Week 3-4: 观察数据，决定继续/放弃

---

**Status**: Proposal
**Created**: 2026-02-02
**Decision**: TBD
