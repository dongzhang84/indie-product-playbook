# Implementation Guides

单人 phase-by-phase 的 MVP 实施指南合集——每个文件是一个项目从 0 到 launch 的完整构建手册（技术栈、分阶段步骤、具体代码骨架、坑位提醒）。

**和 `ideas/` 的区别：** `ideas/` 是产品说明（要做什么、为什么做、给谁）；这里是工程实施（怎么做、按什么顺序做）。

## Index

| 项目 | 文件 | 技术栈 | 状态 |
|------|------|--------|------|
| Vibe Reading | [vibe-reading.md](./vibe-reading.md) | Next.js 14 + Supabase-only + OpenAI (no Stripe, open source) | Proposal → to build |
| TeachLoop (AceRocket B2B) | [teachloop.md](./teachloop.md) | Next.js 16 + Firebase + OpenAI + Stripe | Phase 6 完成 |
| GrowPilot | [growpilot.md](./growpilot.md) | Next.js 14 + Supabase + Prisma + Stripe | In Progress |
| LaunchRadar | [launchradar.md](./launchradar.md) | Next.js + Vercel | Phases 1–9 完成 (已 shelve) |
| Socrates Finds You | [socrates-finds-you.md](./socrates-finds-you.md) | 本地 Python 工具链 | 日常使用中 |
| Stock Monitor | [stock-monitor.md](./stock-monitor.md) | Next.js + Vercel | Launched |
| AI Video Assistant | [ai-video-assistant.md](./ai-video-assistant.md) | Next.js + Stripe | Abandoned |

## Sync Notes

这些文件是**从各自项目 `docs/implementation-guide.md` 复制过来的快照**——不是符号链接。原项目更新后这里不会自动同步。

如果项目里的 implementation guide 有大改，可以手动再 `cp` 一次覆盖。
