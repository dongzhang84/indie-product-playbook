# Indie Product Development Playbook

> 一人公司的产品开发完整指南
>
> 从0到1，快速验证，以量取胜

## 📁 项目结构

```
├── playbook/           # 产品开发方法论
│   ├── 01-find-demand.md
│   ├── 02-reverse-engineer.md
│   ├── 03-development.md
│   ├── 04-launch.md
│   ├── 05-marketing.md
│   ├── 06-metrics.md
│   ├── 07-success.md
│   ├── 08-failure.md
│   ├── 09-indie-resources.md
│   ├── 10-ai-workflow-plan.md  # AI多项目管理系统规划
│   └── indie-roadmap-2026.md   # 2026年独立开发路线图
├── ideas/              # 产品想法库
│   ├── README.md
│   └── *-proposal.md
├── product-evaluation.md
├── weekly-review.md
└── README.md
```

## 📋 Playbook 目录

1. [找需求](playbook/01-find-demand.md) - 如何发现值得做的产品
2. [逆向工程](playbook/02-reverse-engineer.md) - 如何拆解竞品
3. [开发](playbook/03-development.md) - 如何快速开发MVP
4. [上线](playbook/04-launch.md) - 如何部署和发布
5. [推广](playbook/05-marketing.md) - 如何获取第一批用户
6. [数据分析](playbook/06-metrics.md) - 如何追踪关键指标
7. [成功后](playbook/07-success.md) - 产品有起色后怎么办
8. [失败后](playbook/08-failure.md) - 如何快速复盘和继续
9. [参考资料](playbook/09-indie-resources.md) - 参考工具和资源
10. [AI多项目工作流](playbook/10-ai-workflow-plan.md) - OpenClaw + Mac Mini 自动化调度系统

## 🚀 当前状态（2026-03-23）

### 活跃项目

| 项目 | 状态 | 下一步 |
|------|------|--------|
| **Socrates Finds You** | 🟢 每日使用中 | 持续打磨 |
| **AceRocket** | 🔨 开发中 | 推进功能 |
| **SAT/AP** | 🔨 开发中 | 推进功能 |
| **ProfitPilot** | 🔨 开发中 | 推进功能 |
| **Shopify AI Analyst** | 📋 排队中 | 待启动 |
| **Vibe Coding Orchestrator** | 📋 排队中 | 待启动 |
| **LaunchRadar** | ❄️ 冷藏 | 无成功竞品，方向验证失败 |

### 下一步优先级

**阶段一：立刻（免费，今天就能做）**
- [ ] 把所有项目推到 GitHub private repo
- [ ] 每个项目根目录创建 `CLAUDE.md`（参考 [模板](playbook/10-ai-workflow-plan.md#六claude-md-模板)）
- [ ] 发 GitHub repo 链接给 Claude，开始第一次调度

**阶段二：购买 Mac Mini**
- [ ] 购买 Mac Mini M4 16GB — Best Buy open-box $580.99 或 apple.com $599
- [ ] 安装 OpenClaw，配置 WhatsApp 晨报

**阶段三：自动化（Mac Mini 到货后）**
- [ ] 写 Perception Script（读 git log + 报错日志）
- [ ] 配置 Morning Brief + Evening Retrospective
- [ ] 测试完整闭环

> 详细规划见 [AI多项目工作流](playbook/10-ai-workflow-plan.md)

---

## 🎯 核心理念

**不是做100个产品碰运气，而是快速试错、快速学习、持续迭代。**

### 关键原则

- **速度 > 完美**：1周出MVP，不要花3个月打磨
- **数据 > 直觉**：7天看数据决定继续还是放弃
- **免费为主**：早期不花大钱做marketing
- **以量取胜**：但每3个产品要停下来复盘
- **保持理性**：不要对单个产品过度投入感情

### 典型周期

```
Week 1: 找需求 → 选1个山寨
Week 2: 逆向工程 → Claude Code开发
Week 3: 上线 → 免费渠道推广
Week 4: 看数据 → 决定继续/放弃
```

## 🛠 技术栈

**统一技术栈，不要每个产品换一套：**

- **开发工具**: Claude Code
- **框架**: Next.js + TypeScript + React
- **样式**: Tailwind CSS
- **数据库**: Supabase
- **支付**: Stripe
- **部署**: Vercel
- **分析**: Google Analytics 4

## 📊 成功标准

### Level 1: 有信号（Week 1-4）

- ✅ 100+ visits/week
- ✅ 20+ active users
- ✅ 5+ return next day
- ✅ MRR: $0-200

### Level 2: 初步验证（Month 2-3）

- ✅ 500+ visits/week
- ✅ 50+ active users
- ✅ 有人问"能付费吗"
- ✅ MRR: $500-1000

### Level 3: 真正成功（Month 3-6）

- ✅ 2000+ visits/week
- ✅ 200+ active users
- ✅ MRR: $3000-5000
- ✅ 持续增长（+20%/month）

### Level 4: 爆了（Month 6+）

- ✅ MRR: $10k+
- ✅ 有机传播
- ✅ 考虑All In

## 🚫 常见错误

1. ❌ 过度打磨第一个产品
2. ❌ 做太复杂的功能
3. ❌ 花大钱做marketing
4. ❌ 不看数据，凭感觉
5. ❌ 对失败的产品不放手
6. ❌ 盲目做100个产品不复盘

## 📈 时间规划

### Month 1-2: 做3个产品
- Week 1-2: Product A
- Week 3-4: Product B
- Week 5-6: Product C
- Week 7-8: 复盘

### Month 3-4: 做3个产品（应用教训）
- 重复上述流程
- 调整策略

### Month 5-6: 评估
- 如果有1个>$500/月 → 专注优化
- 如果全失败 → 深度复盘，可能pivot

## 🔗 模板

- [产品评估模板](product-evaluation.md)
- [周复盘模板](weekly-review.md)
- [产品想法库](ideas/README.md)
- [2026年独立开发路线图](playbook/indie-roadmap-2026.md)（含 Build in Public / X.com 策略）

## 📝 使用方法

1. **按顺序阅读** playbook/ 目录下的01-08章节
2. **执行时参考** 具体章节的checklist
3. **定期更新** 根据实际经验修改playbook
4. **复盘时使用** templates记录learnings
5. **记录想法** 在 ideas/ 目录下创建proposal

## ⚠️ 重要提醒

这是**私人工作文档**，包含：
- 真实数据和收入
- 失败的详细原因
- 具体策略和trick
- 个人反思和情绪

不要公开分享。

---

Last Updated: 2026-03-23
Version: 1.4
