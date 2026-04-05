# 每日工作日志

> 格式：每天晚上记录当天做了什么，第二天早上的计划会基于这个生成。

---

## 2026-03-23（周日）

- 规划了是否要安装 OpenClaw（结论：先试用 Claude Cowork 再决定）
- SAT/AP 项目：实现了 PDF 导入 → 直接生成目标格式 HTML（另一台电脑完成）✅
- 运行了 Socrates Finds You 每日 run（第8天）

## 2026-03-24（周一）

- LaunchRadar v1.1 重启（21 commits）：简化 onboarding、移除 targetCustomer、新增即时扫描 + on-demand refresh、scanning banner、关掉 Stripe 改为个人工具模式，更新 README/CLAUDE.md/CHANGELOG
- Socrates Finds You 每日 run（第9天）
- indie-product-playbook：AI workflow plan 更新到 v2.0，加了 daily logs 结构
- 开始使用 Claude Cowork 替代 OpenClaw，搭建每日日志系统

## 2026-03-25（周二）

- ProfitPilot 从零启动（9 commits）：Next.js 14 初始化、Supabase 认证、Phase 2.1 Shopify OAuth 连接流程 + dashboard 占位
- LaunchRadar v1.2（5 commits）：抓取窗口扩展到 72h + 200条/subreddit，Clear History 按钮，404 静默跳过
- Socrates Finds You 每日 run（第10天）

## 2026-03-26（周四）

- ProfitPilot（7 commits）：Phase 2.1 Shopify OAuth flow（Dev Dashboard），Phase 2.2 Shopify 数据同步 API，Phase 2 bug fixes
- Socrates Finds You 每日 run（第11天）

## 2026-03-27（周五）

- ProfitPilot（17 commits）：完成今日 action-plan 全部4个 Phase
  - Phase 1 ✅ 7天免费试用（注册自动开启，第5天提醒邮件，到期强制付费）
  - Phase 2 ✅ Health Check 改成弹窗（每次进 Dashboard 自动弹出，可叉掉）
  - Phase 3 ✅ Health Check 数据可随时编辑（预填已有数据）
  - Phase 4 ✅ Dashboard 第一屏改成 AI 主动洞察（🔴警告/🟡注意/🟢机会）
  - 附加：sign out header，更新 README/CHANGELOG/CLAUDE.md
- LaunchRadar v1.3（16 commits）：标题直接变可点击链接、移除多余的 View Thread 按钮、帖子正文预览、Scan Now 时同步生成回复建议（修复之前只在 daily digest 生成的 bug）、OpenAI scoring 并行化提速、更新 CHANGELOG/CLAUDE.md/README
- AceRocket / AP_Calculus_Question_Bank（4 commits）：实现 2.2 批量 Firebase 写入 + 2.3 MathJax 懒加载，实现 3.1 测验结束后的题目复盘功能
- Socrates Finds You 每日 run（第12天）

**明天计划（2026-03-28）：**
- 深入研究 Shopify 店家真实痛点，验证 ProfitPilot 有没有抓住核心需求；用 LaunchRadar 找店主相关讨论
- 用虚拟账户跑完整测试流程（注册 → trial → dashboard → 洞察 → 问题 → 升级）
- ProfitPilot pricing 页面 UI 修改

## 2026-03-31（周二）

- ✅ Scott 邮件已于今早发送
- ProfitPilot（~25 commits）：
  - Dashboard 全面重设计：left-border insights、AI 洞察质量升级（更严格 prompt + WOW Moment 红色警告卡）、Questions 区改名为 Ask ProfitPilot + 5个快捷 pill 按钮、Sync Button 新增、profit overview heading 优化
  - 数据修复：rolling 30-day windows 替代 this month/last month、ad spend 计算修复、monthly profit server-side fetch、'warning' insight 红色样式修复
  - Landing page 大改：全新 copy（question-led hero + 真实用户引言 + 3步 how-it-works）、v1 template 设计、deep blue 主题、pricing cards 拓宽、字体修复
  - 功能新增：Google OAuth 注册、已登录用户自动跳转 dashboard
  - UI 细节：font loading 修复、各区块 header 尺寸统一
- AceRocket / AP_Calculus_Question_Bank（12 commits）：实现 30-question cap（expired-trial / 免费用户强制上限），PR #10、#11、#12 合并上线
- AceRocket / SAT_Math_Question_Bank：同步实现 30-question cap（https://github.com/dongzhang84/SAT_Math_Question_Bank）
- AceRocket / AP_Calculus_Question_Bank：修复做题记录无法存入 Realtime Database 的 bug
- AceRocket / SAT_Math_Question_Bank：修复 landing page "More Questions" 按钮失效的 bug
- 学习（Week 2 Day 1）✅ LangChain 入门完成：LCEL pipe syntax、ChatPromptTemplate、对话记忆（RunnableWithMessageHistory）、完整 RAG 系统（Load → Split → Embed → Retrieve → 带 source citation 输出），代码整理进 Study_Notes/LLM/LangChain.md 和 study_sandbox/week2_langchain_rag.py

## 2026-04-01（周三）

- ProfitPilot：制定 distribution 计划
- Socrates Finds You：复盘无法获客的原因，思考是否回归国内市场

