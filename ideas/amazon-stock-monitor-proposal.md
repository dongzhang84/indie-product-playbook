# Amazon Stock Monitor

## 项目概述
一个多股票实时监控系统，支持自定义价格阈值警报。Dashboard + 自动通知系统。

## 目标
- 练手项目：熟悉 Vercel + Next.js + Cron 完整流程
- 验证 "3天出MVP" 的方法论
- 建立可复用的产品架构模板

## 技术栈
- **前端**: Next.js 14 + TypeScript + React + Tailwind CSS + Recharts
- **后端**: Vercel Serverless Functions + Vercel Cron
- **数据存储**: Vercel KV (Redis)
- **通知**: GitHub Issues + (可选) Email
- **部署**: Vercel
- **股票API**: Alpha Vantage 或 Finnhub (免费tier)

## 核心功能
1. **实时Dashboard**
   - 显示多只股票当前价格
   - 价格走势图表（最近24小时）
   - 状态指示器（买入/持有/卖出区域）

2. **自动监控系统**
   - Vercel Cron 每5分钟检查价格
   - 触发阈值时自动创建 GitHub Issue
   - 支持多只股票同时监控

3. **可扩展配置**
   - 轻松添加新股票
   - 自定义每只股票的阈值
   - 启用/禁用特定股票监控

## 初始配置
- **AMZN**: 买入阈值 $230，卖出阈值 $240
- 未来可添加: AAPL, GOOGL, MSFT, TSLA 等

## 开发计划
- **第一步**: 项目初始化 (1-2小时)
- **第二步**: 核心功能开发 (3-4小时)
- **第三步**: 数据存储实现 (1小时)
- **第四步**: Vercel部署 (30分钟)
- **第五步**: 测试优化 (1小时)
- **总计**: 6-8小时完成MVP

## 成本
- 完全免费（Vercel Hobby plan + 免费股票API）

## 成功指标
- ✅ 3天内上线
- ✅ Dashboard正常显示实时价格
- ✅ Cron准时运行
- ✅ 触发阈值时成功通知

## 学习目标
- Vercel平台使用
- Next.js API Routes
- Serverless Cron Jobs
- 第三方API集成
- 实时数据展示
- 通知系统设计

## 扩展可能
- 添加更多通知渠道（Email, Telegram, Discord）
- 价格预测/趋势分析
- 用户认证和个人watchlist
- 移动端优化/PWA
- 集成券商API

## 项目状态
🟡 Planning - 2026年2月4日创建

## 相关文件
- GitHub Repo: (待创建)
- Vercel 部署: (待部署)
