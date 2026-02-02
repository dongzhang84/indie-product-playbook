# 06 - 数据分析 (Metrics)

> 看对的数字，快速决策。

## 🎯 目标

**用最少的metrics，做出正确的决策：继续 or 放弃。**

### 不是什么

```
❌ 不是做复杂的dashboard
❌ 不是cohort analysis
❌ 不是A/B testing
❌ 不是优化转化率

Week 1-4的目标：
看3个核心数字，决定要不要继续
```

## 📊 3个核心Metrics

### Metric 1: Visits（流量）

**看什么：**
```
- 7天总visits
- 每日trend
- 来源分布

目标：
Week 1: 100+ visits
Week 2: 持续或增长
```

**在哪看：**
- Google Analytics 4
- 或Vercel Analytics

**判断：**
```
✅ >200 visits: 很好
✅ 100-200 visits: 可以
⚠️ 50-100 visits: 勉强
❌ <50 visits: 不够
```

### Metric 2: Usage（使用）

**看什么：**
```
- 多少人注册（如果需要注册）
- 多少人实际用了核心功能
- 多少人第二天回来

不是：
❌ 只看注册数
✅ 看实际usage
```

**在哪看：**
- Supabase Dashboard
- 或自己的数据库

**判断：**
```
Conversion:
Visits → Signups: 5-20% 正常
Signups → Active Use: >50% 才算好

Retention:
Day 1 → Day 2: >10% 才算好
```

### Metric 3: Revenue（收入）

**看什么：**
```
Early stage:
- 不一定有收入
- 但要看"willingness to pay"的signal

Signal包括：
- 有人问"能付费吗"
- 有人点pricing页面
- 有人试图付费但失败
```

**在哪看：**
- Stripe Dashboard（如果有）
- 用户反馈
- Email询问

**判断：**
```
Week 1-2: 有signal就好
Week 3-4: 如果还没收入，要担心了
Month 2: 至少要有$50-100 MRR
```

## 🎛 实际Setup

### 简单的Google Sheets Dashboard

**不需要复杂工具，一个表格够了：**

```
日期 | Visits | Signups | Active | Revenue | 来源
-----|--------|---------|--------|---------|------
2/1  | 45     | 8       | 5      | $0      | PH
2/2  | 120    | 15      | 10     | $0      | PH
2/3  | 80     | 12      | 8      | $0      | Reddit
...
```

**每天花5分钟更新：**
- 打开GA4 → 记录visits
- 打开Supabase → 记录signups/active
- 打开Stripe → 记录revenue

### 自动化（可选，以后再做）

**如果你做了3+个产品，可以考虑自动化：**

```
用Next.js做一个dashboard：
- 调用GA API
- 调用Supabase API
- 调用Stripe API
- 展示所有产品的数据

但Week 1-4不需要
手动够了
```

## 📈 看Trends，不是绝对值

### 好的Trend

```
Day 1: 50 visits
Day 2: 80 visits  ↗
Day 3: 120 visits ↗
Day 4: 100 visits →
Day 5: 110 visits ↗

= 在增长，好信号
```

### 坏的Trend

```
Day 1: 200 visits (PH launch)
Day 2: 50 visits  ↘
Day 3: 20 visits  ↘
Day 4: 10 visits  ↘

= 纯靠PH，没有organic，坏信号
```

### 判断标准

```
✅ 持续增长
✅ 或者稳定在高位
✅ 有organic traffic（不只是launch spike）

❌ 只有launch day有流量
❌ 之后断崖式下降
❌ 没有回头客
```

## 🔍 深入分析（仅当有必要）

### 什么时候需要深入分析？

```
信号：
- 有流量，但bounce rate很高
- 有signups，但没人用
- 有人用，但没人付费

这时候才需要deeper analysis
```

### 用GA4看用户行为

```
1. Engagement → Pages and screens
   → 哪些页面停留时间长？
   → 哪些页面立即跳出？

2. Acquisition → Traffic acquisition
   → 哪个来源质量最好？
   → 哪个来源bounce rate最高？

3. Events
   → 用户click了什么？
   → 哪里卡住了？
```

### 用Supabase看数据

```
基础SQL queries：

-- 注册但没用的用户
SELECT * FROM users 
WHERE created_at > NOW() - INTERVAL '7 days'
AND last_active_at IS NULL

-- 最活跃的功能
SELECT feature, COUNT(*) 
FROM usage_logs 
GROUP BY feature 
ORDER BY COUNT(*) DESC

-- 留存率
SELECT 
  DATE(created_at) as signup_date,
  COUNT(*) as signups,
  COUNT(CASE WHEN last_active > created_at + INTERVAL '1 day' THEN 1 END) as returned
FROM users
GROUP BY DATE(created_at)
```

## ⚠️ 常见错误

### 错误1：看太多数字

```
❌ 盯着20个metrics
❌ 做复杂的分析
❌ 花一整天看数据

✅ 看3个核心数字
✅ 一天看2-3次
✅ 快速判断方向
```

### 错误2：过早优化

```
❌ Day 2就开始A/B testing
❌ 优化conversion funnel
❌ 做retention analysis

✅ 先确保有足够的流量
   (至少100+ users)
   再考虑优化
```

### 错误3：被虚荣指标迷惑

```
虚荣指标：
❌ Pageviews（不代表usage）
❌ Signups（可能都不活跃）
❌ Social media likes

真实指标：
✅ Active users
✅ Retention
✅ Revenue
```

### 错误4：忽略qualitative feedback

```
❌ 只看数字，不看反馈
❌ 数字说好，但用户在抱怨

✅ 结合数字和反馈
✅ 数字告诉你"什么"
✅ 反馈告诉你"为什么"
```

## 📋 Week 1-4 Review Checklist

### Week 1 结束

```
记录：
- [ ] 总visits:
- [ ] 总signups:
- [ ] Active users:
- [ ] Revenue:
- [ ] Bounce rate:
- [ ] Top来源:

决策：
- [ ] 继续？是/否
- [ ] 如果继续，优先做什么？
- [ ] 如果放弃，为什么？
```

### Week 2-4 每周

```
对比：
- [ ] 和上周比，增长多少？
- [ ] Trend是什么？
- [ ] 有organic growth吗？
- [ ] 用户反馈有什么pattern？

调整：
- [ ] 需要改什么？
- [ ] 下周focus在什么？
```

## 🎯 决策框架

### Level 1: 继续观察（20% 时间）

```
信号：
- 100-200 visits/week
- 10-20 active users
- 有人在用，但没付费
- Trend稳定或微增

行动：
- 继续做，但不all in
- 80%时间做新产品
- 20%时间维护这个
```

### Level 2: 值得投入（50% 时间）

```
信号：
- 500+ visits/week
- 50+ active users
- 有人问付费
- Trend持续增长

行动：
- 50%时间优化这个
- 50%时间做新产品
- 加入付费功能
```

### Level 3: 全力投入（80%+ 时间）

```
信号：
- $500+ MRR
- 或明显的增长趋势
- 用户engagement很高

行动：
- 80%时间专注这个
- 优化、增长、scale
```

### Level 0: 放弃（0% 时间）

```
信号：
- <50 visits/week (Week 2+)
- <5 active users
- Trend下降
- 没有positive反馈

行动：
- 快速复盘
- Archive这个产品
- 做下一个
```

## 📝 记录模板

**使用 templates/weekly-review.md**

每周填写：
- 数字summary
- Top insights
- 用户反馈highlights
- 下周计划
- 决策（继续/放弃/pivot）

## ✅ 下一步

根据数据决定：

好信号 → [07 - 成功后](07-success.md)
坏信号 → [08 - 失败后](08-failure.md)

---

**Prev:** [05 - 推广](05-marketing.md)  
**Next:** [07 - 成功后](07-success.md) or [08 - 失败后](08-failure.md)
