# 04 - 上线

> 部署到Vercel，买域名，准备发布。

## 🎯 目标

**产品能公开访问，有自己的域名（可选），准备推广。**

## 🚀 部署到Vercel

### Step 1: 准备代码

```bash
# 确保代码在GitHub
git add .
git commit -m "Ready for launch"
git push origin main

# 确保有.env.example
# 列出需要的环境变量
```

### Step 2: Vercel部署

```
1. 访问 vercel.com
2. 用GitHub登录
3. Import你的repo
4. 配置环境变量：
   - NEXT_PUBLIC_SUPABASE_URL
   - NEXT_PUBLIC_SUPABASE_ANON_KEY
   - SUPABASE_SERVICE_ROLE_KEY
   - STRIPE_SECRET_KEY（如果有）
   - STRIPE_WEBHOOK_SECRET（如果有）
   - GA_MEASUREMENT_ID

5. Deploy

等待2-3分钟，完成！
```

### Step 3: 测试

```
- [ ] 访问 your-app.vercel.app
- [ ] 测试注册/登录
- [ ] 测试核心功能
- [ ] 在mobile测试
- [ ] 检查是否有console errors
```

## 🌐 域名（可选但推荐）

### 要不要买域名？

```
Week 1可以先不买：
✅ 用 your-app.vercel.app 先上线
✅ 看反应，再决定买不买

如果要买：
推荐注册商：
- Namecheap（便宜）
- Cloudflare（$8-12/年）

价格：$8-15/年

好的域名：
✅ 短
✅ 好记
✅ 能说明是什么
✅ .com/.app/.io都可以
```

### 绑定域名到Vercel

> 详细的购买、DNS配置、验证全流程见：[12 - 域名设置](12-domain-setup.md)

简要步骤：
```
1. Namecheap 购买域名（开启 Domain Privacy）
2. Vercel → Settings → Domains → Add 域名 → 拿到 DNS 记录
3. Namecheap → Advanced DNS → 添加 A Record + CNAME Record
4. 等待 DNS 生效（通常几分钟）→ Vercel 自动配置 HTTPS
5. 更新代码和第三方服务中的旧 URL
```

## 📊 Analytics设置

### Google Analytics 4

```
如果还没加：

1. 创建GA4账号
2. 获得Measurement ID
3. 加到Next.js：
   - 用next/script
   - 或用react-ga4包

基础tracking够了：
- Pageviews
- Events（signup, use_feature）

不要：
❌ 过度tracking
❌ 复杂的funnel
❌ Week 1不需要
```

## 🎨 Landing Page最后检查

### Checklist

- [ ] 标题清楚（5秒内知道是什么）
- [ ] 副标题说明核心价值
- [ ] CTA button明显（"Try It Free"/"Get Started"）
- [ ] 有demo（screenshot/gif/video）
- [ ] Mobile响应式
- [ ] Loading速度快（<3秒）

### 文案模板

```
标题：[动词] + [结果]
例子：
- "Track Time Like Money"
- "Generate AI Images in Seconds"
- "Automate Your Reports"

副标题：[谁] + [痛点] + [解决方案]
例子：
- "For freelancers who lose track of billable hours"
- "Stop wasting time on repetitive tasks"

CTA：
- "Try It Free" 比 "Sign Up" 好
- "Get Started" 比 "Learn More" 好
```

## 🔐 最后的安全检查

### 基础安全

- [ ] 所有API keys在环境变量
- [ ] Supabase Row Level Security启用
- [ ] 没有hard-coded secrets
- [ ] HTTPS自动redirect（Vercel默认）

### 不需要（可以以后再做）：

```
❌ 复杂的安全审计
❌ Penetration testing
❌ 高级的rate limiting
```

### ⚠️ 重要提醒

```
基础安全必须做，不能跳过：
✅ API keys必须在环境变量
✅ RLS必须启用
✅ 用户输入必须验证

安全漏洞从Day 1就可能被利用
不要因为"产品小"就忽略安全
```

## 📝 Launch Checklist

### 技术

- [ ] 部署成功（Vercel）
- [ ] 域名绑定（如果有）
- [ ] HTTPS工作
- [ ] 环境变量配置正确
- [ ] Database连接正常
- [ ] 没有console errors
- [ ] Mobile测试通过

### 内容

- [ ] Landing page完成
- [ ] About/FAQ页面（可选）
- [ ] Privacy Policy（简单的，可以用generator）
- [ ] Terms of Service（简单的）

### Analytics

- [ ] GA4配置完成
- [ ] 基础events tracking
- [ ] 能看到real-time数据

### 准备推广

- [ ] Screenshot准备好（3-5张）
- [ ] Demo GIF/Video（可选）
- [ ] 一句话描述写好
- [ ] 3个核心价值写好
- [ ] Product Hunt账号准备好

## 🚦 Go / No Go 决策

### 可以上线的标准

```
✅ 核心功能work
✅ 用户可以完成主要任务
✅ 没有critical bugs
✅ Landing page清楚
✅ Mobile基本能用

可以有的问题：
⚠️ UI不完美
⚠️ 有些小bug
⚠️ 功能不全
⚠️ 性能不是最优

这些都ok，先上线
```

### 不能上线的问题

```
❌ 核心功能完全不work
❌ 无法注册/登录
❌ 数据会丢失
❌ 有security漏洞
❌ 网站打不开

这些必须修复才能上线
```

## ⚠️ 常见问题

### 问题1：完美主义

```
症状：
"这里还不够好..."
"UI还要改..."
"功能还不完整..."

解决：
✅ 提醒自己：Week 1的目标是验证需求
✅ 不完美的产品上线 > 完美的产品永远不上线
✅ 设定deadline：Day 7必须上线
```

### 问题2：部署失败

```
常见原因：
- 环境变量没设置
- Build errors
- Dependencies问题

解决：
✅ 检查Vercel的build logs
✅ 本地运行 npm run build
✅ 修复errors后重新deploy
```

### 问题3：域名不确定

```
纠结：
"买什么域名？"
"要不要买？"

解决：
✅ Day 7先用 xxx.vercel.app 上线
✅ 看反应
✅ 有人用再买域名
```

## 📱 Soft Launch vs Hard Launch

### Soft Launch（推荐Week 1）

```
什么是：
- 悄悄上线
- 只告诉几个朋友
- 测试一下流程
- 修复发现的问题

好处：
✅ 低压力
✅ 有时间修bug
✅ 获得早期反馈

时间：
Day 7-8（周末）
```

### Hard Launch（Week 2）

```
什么是：
- 正式发布
- Product Hunt
- 社交媒体
- 所有渠道

等Soft Launch后：
✅ 修复了明显bug
✅ 确认核心功能work
✅ 准备好handle流量
```

## ✅ 上线后立即做的事

### Day 7晚上

```
1. 发给3-5个朋友
   "我做了个XXX，帮我试试？"

2. 观察他们的反馈
   - 哪里卡住？
   - 什么confused？
   - 什么work well？

3. 快速修复critical bugs

4. 准备Week 2的推广
```

### 监控

```
持续监控：
- Vercel Analytics（错误、性能）
- GA4 Real-Time（有人访问吗）
- Supabase（有人注册吗）

不要：
❌ 每5分钟刷新
❌ 焦虑地盯着数据
✅ 一天看2-3次就够了
```

## 🎉 庆祝

**你上线了！这已经超过90%的人。**

大部分人：
- 想法阶段就放弃
- 做到一半放弃
- 做完了不敢上线

你不一样，你做出来了，而且上线了。

不管结果如何，这是很大的成就。

---

## 下一步

产品上线后：

→ [05 - 推广](05-marketing.md)

把产品推广出去，获得第一批用户。

---

**Prev:** [03 - 开发](03-development.md)  
**Next:** [05 - 推广](05-marketing.md)
