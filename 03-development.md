# 03 - 开发

> 用Claude Code，1周做出MVP。不要花3个月打磨。

## 🎯 目标

**Week 1结束时，产品能用，可以上线。**

### 不是什么

```
❌ 不是完美的产品
❌ 不是所有功能都有
❌ 不是production-ready的代码
❌ 不是考虑所有edge cases

Week 1的目标：能用，能演示，能获得反馈
```

## 🛠 标准技术栈

**不要每个产品换技术栈，用统一的：**

### 前端 + 后端
```
Next.js 14 + TypeScript + React
- 全栈框架
- API Routes做后端
- 不需要单独backend
```

### 样式
```
Tailwind CSS
- 快速
- 不用写CSS
- 响应式容易
```

### 数据库
```
Supabase
- PostgreSQL
- 自带Auth
- 免费tier够用
```

### 支付
```
Stripe
- 集成简单
- Stripe Checkout（最快）
```

### 部署
```
Vercel
- Next.js的公司做的
- 0配置部署
- 免费tier够用
```

### 分析
```
Google Analytics 4
- 免费
- 标准工具
```

**为什么统一技术栈？**
```
✅ 不用重新学
✅ 可以复用代码
✅ Claude Code更熟练
✅ 调试更快
```

## 📅 Week 1 开发计划

### Day 1-2: Setup + 数据库（Claude Code）

```
用Claude Code完成：

1. 初始化项目
   - Next.js + TypeScript
   - Tailwind配置
   - 基础文件结构

2. Supabase设置
   - 创建project
   - 设计database schema
   - 设置Row Level Security

3. 认证设置
   - Supabase Auth集成
   - 登录/注册页面
   - Protected routes

提示词模板：
"用Next.js 14 + TypeScript + Tailwind创建一个新项目。
集成Supabase，设置以下数据库表：
[列出你的表结构]
添加Supabase Auth，做登录和注册页面。"
```

### Day 3-4: 核心功能（Claude Code）

```
用Claude Code实现核心功能：

1. 主要页面
   - Landing page
   - Dashboard/主功能页面
   - 设置页面（简单）

2. 核心功能
   - 根据你的逆向工程文档
   - 只做Must Have的功能
   - UI够用就行，不追求完美

提示词模板：
"实现以下核心功能：
1. [功能1描述]
2. [功能2描述]
3. [功能3描述]

用户流程是：[描述用户如何使用]
UI保持简单，用Tailwind做基础样式。"
```

### Day 5: 支付集成（如果需要）

```
用Stripe Checkout（最快）：

不要手写支付逻辑
用Stripe的hosted checkout page

步骤：
1. 创建Stripe账号
2. 创建产品和价格
3. 集成Stripe Checkout
4. Webhook处理订阅状态

提示词给Claude Code：
"集成Stripe Checkout。
产品定价：$X/月
成功后redirect到dashboard
webhook更新用户的subscription状态到Supabase"

或者：
先不做支付，上线后观察，有人愿意付费再加
```

### Day 6: Polish + Bug修复

```
基础优化：

1. UI微调
   - 确保responsive
   - 基础的loading states
   - 基础的error handling

2. 功能测试
   - 自己走一遍完整流程
   - 修复明显的bug
   - 确保核心功能work

不要追求完美：
❌ 不用做fancy动画
❌ 不用测试所有edge cases
❌ 不用优化性能（够用就行）
```

### Day 7: Landing Page + Analytics

```
1. Landing Page
   - 一句话说明是什么
   - 核心价值3个bullet points
   - CTA button（Sign Up/Try It）
   - 简单的demo gif/video

2. 加入Analytics
   - Google Analytics 4
   - 基础的event tracking

提示词：
"创建一个landing page。
标题：[你的产品标题]
描述：[一句话说明]
核心价值：[3个点]
加入GA4 tracking。"
```

## 🤖 与Claude Code协作技巧

### 好的提示词

```
✅ 具体，有context
"创建一个时间追踪器。
用户可以开始/停止计时，选择活动类型，
查看今天总时间。用Next.js + Supabase。"

❌ 太模糊
"做一个时间管理app"
```

### 分步骤

```
✅ 一次一个功能
"先实现开始/停止计时功能"
然后
"现在加入活动类型选择"

❌ 一次要求太多
"做完所有功能"
```

### 给context

```
✅ 提供结构
"这是我的数据库schema：[schema]
现在实现XX功能"

❌ 没有context
"做个功能"
```

### 迭代

```
流程：
1. 让Claude Code做出来
2. 测试
3. 发现问题
4. 告诉Claude Code："修复XX问题"
5. 重复

不要期望一次完美
```

## ⚠️ 常见错误

### 错误1：追求完美

```
❌ "UI要和Figma一样精美"
❌ "代码要clean，要写tests"
❌ "要handle所有edge cases"

✅ Week 1目标：能用就行
```

### 错误2：功能蔓延

```
❌ "我再加一个功能..."
❌ "这个也挺有用的..."
❌ "这个应该不难..."

✅ 严格遵守MVP清单
   只做Must Have的功能
```

### 错误3：自己写代码

```
❌ "我改一下这里..."
❌ "这个我自己写更快..."

✅ 让Claude Code写，你负责指导
   除非是很简单的改动
```

### 错误4：卡住不继续

```
❌ "这个bug修不好，我要重写"
❌ "这个功能做不出来，放弃吧"

✅ 换个思路，或者先跳过
   Week 1不需要完美
```

### 错误5：过度优化

```
❌ "我要优化数据库查询"
❌ "我要做caching"
❌ "我要做load balancing"

✅ 这些都是以后的事
   Week 1不会有性能问题
```

## 📦 Week 1结束的checklist

### 功能

- [ ] 用户可以注册/登录
- [ ] 核心功能1能用
- [ ] 核心功能2能用
- [ ] 核心功能3能用
- [ ] Landing page完成
- [ ] 基础的responsive

### 技术

- [ ] 代码在GitHub
- [ ] 本地能运行
- [ ] 数据库配置好
- [ ] 环境变量设置好
- [ ] GA4集成完成

### 测试

- [ ] 自己走完一遍完整流程
- [ ] 注册 → 使用 → 看结果
- [ ] 在mobile上试一下
- [ ] 主要功能都work

### 准备上线

- [ ] 买好域名（可选）
- [ ] Vercel账号准备好
- [ ] Landing page文案写好
- [ ] 准备好demo screenshot/gif

## 🚀 如果进度落后怎么办

### 评估原因

```
原因1：功能太复杂
→ 砍功能，只做最核心的1-2个

原因2：技术问题卡住
→ 换个简单的实现方式
→ 或者先跳过，手动处理

原因3：完美主义
→ 提醒自己：Week 1只要能用
```

### 降级策略

```
如果Day 6了还没做完：

Priority 1（必须有）：
✅ 核心功能能用
✅ 简单的landing page

Priority 2（可以先不做）：
❌ 认证（可以先不需要登录）
❌ 数据库（可以先用localStorage）
❌ 精美UI

Priority 3（完全可以砍）：
❌ 支付
❌ 设置页面
❌ 额外功能

极简MVP：
一个页面，核心功能能用，能演示
这就够了
```

## 💡 加速技巧

### 复用代码

```
如果你做过类似产品：
✅ 复用登录页面
✅ 复用布局
✅ 复用常用组件

建立自己的starter template：
把常用的setup做成template
下次直接用
```

### 用现成的

```
不要重新造轮子：
✅ UI组件：shadcn/ui
✅ Icons：lucide-react
✅ 动画：Framer Motion（如果真的需要）
```

### 找参考

```
UI不知道怎么做：
✅ 看其他产品怎么做的
✅ 找个类似的照着做
✅ 不用原创，够用就行
```

## ✅ 下一步

Week 1完成后：

→ [04 - 上线](04-launch.md)

部署到Vercel，准备发布。

---

**Prev:** [02 - 逆向工程](02-reverse-engineer.md)  
**Next:** [04 - 上线](04-launch.md)
