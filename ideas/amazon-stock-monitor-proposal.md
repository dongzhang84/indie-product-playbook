# Amazon Stock Monitor

## 项目概述
多股票实时监控系统，支持自定义价格阈值警报。Dashboard + 自动通知。

## 目标
- 练手项目：熟悉 Vercel + Next.js + Cron 完整流程
- 验证 "3天出MVP" 方法论
- 建立可复用的产品架构模板

## 技术栈
- 前端: Next.js 14 + TypeScript + Tailwind CSS + Recharts
- 后端: Vercel Serverless Functions + Vercel Cron
- 数据: Vercel KV
- 通知: GitHub Issues
- API: Alpha Vantage 或 Finnhub

## 核心功能
1. 实时Dashboard - 多股票价格显示和图表
2. 自动监控 - Vercel Cron 每5分钟检查
3. 智能警报 - 触发阈值时 GitHub Issue 通知

## 初始配置
- AMZN: 买入 < $230, 卖出 > $240

## 开发计划
- 总时间: 6-8小时完成MVP
- 成本: $0 (Vercel免费tier)

## 学习目标
- Vercel平台使用
- Serverless Cron Jobs
- 第三方API集成
- 实时数据展示

## 项目状态
🟢 v1.0.0 Launched - 2026-02-06
