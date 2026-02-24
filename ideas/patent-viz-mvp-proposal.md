# PatentMotion：专利机械原理可视化工具
## Indie MVP 完整提案

> **版本**: v1.0  
> **状态**: 待验证  
> **目标**: 一周出demo，找到第一个愿意试用的用户

---

## 目录

1. [问题定义](#1-问题定义)
2. [目标客户](#2-目标客户)
3. [市场规模（诚实版）](#3-市场规模诚实版)
4. [产品定义](#4-产品定义)
5. [技术实现](#5-技术实现)
6. [一周MVP计划](#6-一周mvp计划)
7. [验证标准](#7-验证标准)
8. [风险与坑](#8-风险与坑)
9. [商业模式](#9-商业模式)
10. [下一步行动](#10-下一步行动)

---

## 1. 问题定义

### 现状

专利诉讼中，律师需要向法官和陪审团解释一个装置的物理工作原理。现在的做法：

- **PPT + 静态图**：拿专利局的原始黑白线稿讲解，陪审团看不懂
- **雇专家证人**：出庭讲解技术原理，时薪 $300-600，整个案子专家费用 $50,000-200,000+
- **外包litigation graphics公司**：制作3D动画，单条视频 $5,000-$20,000，交付周期 2-4 周
- **自己用PowerPoint做动画**：律师不会，做出来也很丑

### 核心痛点

**两个字：慢、贵。**

一个案子从立案到Markman Hearing可能只有几个月，律师需要快速做出Technical Tutorial材料。外包公司排期、沟通、修改来回要几周，经常赶不上deadline。而且改一次又要加钱。

### 如果有工具

律师或litigation graphics freelancer输入专利描述，5分钟内得到一个可以在浏览器里转动、播放运动过程的交互模型，用于：

- Markman Hearing（专利术语界定听证）的Technical Tutorial
- 向陪审团解释"专利是什么、被告产品怎么工作"
- 和解谈判时展示己方技术理解
- 专家证人用作辅助说明材料

---

## 2. 目标客户

### 不是律师本人

律师没时间学工具。他们的时间按小时计费，不会自己建3D模型。

### 真正的客户：Litigation Graphics Freelancer

这群人：
- 专门为律所提供试讲材料、3D动画、courtroom demonstratives
- 现在用Blender/Maya/3ds Max手工建模，一个案子2-4周
- 接单模式：律所找他们，按项目或小时计费
- 如果你的工具让他们从2周做到2天，他们会付钱

**代表性公司/个人**：
- LegalGraphicsPro（小型，freelancer模式）
- Cogent Legal（小型精品所）
- 独立做litigation animation的设计师（LinkedIn上搜"litigation graphics"可以找到几百个）

### 次要客户：中小型IP律所

大律所有自己的in-house graphics团队或长期合作的外包公司，不是你的客户。

中小型IP律所（5-30人）：
- 没有固定的graphics vendor
- 每年可能有3-10个需要visual材料的案子
- 愿意为能快速出结果的工具付钱

---

## 3. 市场规模（诚实版）

### Bottom-up 计算

| 数据 | 来源 | 数字 |
|------|------|------|
| 美国每年专利案立案 | USPTO/IPWatchdog | ~3,800 件 |
| 机械/工业类占比 | Unified Patents 2024 | ~30% |
| 机械专利案数量 | 计算得出 | ~1,140 件/年 |
| 实际需要visual材料的案子（含和解阶段） | 保守估计50% | ~570 件/年 |
| 其中负担得起工具费用的 | 保守估计50% | ~280 件/年 |

### 如果卖工具给freelancer

- 美国做litigation graphics的freelancer/小公司：估计300-500人
- 其中做机械专利的：约100-200人
- 愿意付费使用工具的：乐观估计50人
- 定价 $200/月 = **$120,000 ARR**
- 定价 $500/月 = **$300,000 ARR**

### 如果卖per-case给律所

- 280件案子/年
- 每件 $500-$2,000
- 市场天花板：**$140,000 - $560,000/年**

### 结论

**这不是一个大市场。** 对一个indie来说够活，但不够做成大公司。

如果目标是 $50万 ARR 然后卖掉，有可能。如果目标是 Series A，换方向。

---

## 4. 产品定义

### MVP 边界（非常重要）

**做什么：**
- 用户用自然语言描述一个机械装置的工作原理
- 系统生成一个在浏览器里可以交互的2D/简单3D动画
- 支持播放、暂停、慢放
- 支持标注零件名称（对应专利引线编号）
- 可以导出为视频文件或分享链接

**不做什么（MVP阶段）：**
- 不做文字→精确3D模型（技术上不可行）
- 不做专利PDF自动解析（太复杂，留到v2）
- 不做流体、电磁、柔性体
- 不做侵权对比功能
- 不做中文专利（先做美国市场）

### 核心用户流程

```
用户输入（自然语言）
↓
"一个凸轮带动推杆做往复运动，推杆推动阀门开闭"
↓
AI理解机构关系，生成运动参数
↓
前端渲染成可交互动画
↓
用户可以：
  - 拖动查看角度
  - 点击零件高亮
  - 播放/暂停/调速
  - 添加文字标注
  - 导出视频或分享链接
```

### 支持的机构类型（MVP范围）

| 机构类型 | 举例 | 难度 |
|----------|------|------|
| 曲柄连杆 | 发动机活塞 | ⭐⭐ |
| 凸轮机构 | 阀门开合 | ⭐⭐ |
| 齿轮传动 | 减速器 | ⭐⭐ |
| 铰链四杆 | 折叠机构 | ⭐⭐⭐ |
| 棘轮机构 | 单向传动 | ⭐⭐⭐ |
| 丝杠螺母 | 线性运动 | ⭐⭐ |

---

## 5. 技术实现

### 整体架构

```
用户输入（自然语言）
        ↓
   [Claude API]
   理解机构关系
   输出结构化JSON
        ↓
   [前端渲染引擎]
   Three.js / Canvas
   根据JSON驱动动画
        ↓
   [用户交互层]
   React界面
   控制播放/标注/导出
```

### 技术栈选择

**前端**
- React（界面框架）
- Three.js（3D渲染，如果做简单3D）或 Canvas API（如果做2D）
- Framer Motion（UI动画）

**AI层**
- Claude API（理解自然语言描述，输出结构化运动参数）

**后端（MVP可以极简）**
- Next.js（前后端一体）
- 不需要数据库（MVP阶段）
- Vercel部署

**导出**
- html2canvas 或 puppeteer（截图）
- CCapture.js（视频导出）

---

### 最关键的技术问题：AI如何理解机构关系

这是整个系统的核心。用Claude API做以下事情：

**输入**（用户的自然语言）：
```
一个内燃机的曲柄连杆机构。曲轴以匀速旋转，
通过连杆带动活塞在气缸内做往复直线运动。
曲轴转一圈，活塞完成一次往复。
```

**Prompt设计（关键）**：
```
你是一个机构运动分析专家。用户描述了一个机械机构，
请分析其运动关系，输出严格的JSON格式，包含：

{
  "components": [
    {
      "id": "crankshaft",
      "name": "曲轴",
      "shape": "circle",  // circle/rectangle/custom
      "motion_type": "rotation",  // rotation/translation/oscillation/fixed
      "params": {
        "radius": 50,
        "rpm": 1,
        "pivot": [200, 200]
      }
    },
    {
      "id": "connecting_rod",
      "name": "连杆",
      "shape": "rectangle",
      "motion_type": "complex",
      "driven_by": "crankshaft",
      "params": {
        "length": 120,
        "width": 15
      }
    },
    {
      "id": "piston",
      "name": "活塞",
      "shape": "rectangle",
      "motion_type": "translation",
      "driven_by": "connecting_rod",
      "params": {
        "axis": "vertical",
        "stroke": 100
      }
    }
  ],
  "connections": [
    {
      "from": "crankshaft",
      "to": "connecting_rod",
      "joint_type": "revolute",
      "offset": 50
    },
    {
      "from": "connecting_rod",
      "to": "piston",
      "joint_type": "revolute"
    }
  ],
  "constraints": [
    {
      "component": "piston",
      "type": "slider",
      "axis": "vertical"
    }
  ]
}

只输出JSON，不要解释。如果机构太复杂无法表达，
在JSON里加 "error": "描述原因"
```

**前端根据这个JSON**：
- 每个component按shape渲染成几何体
- 每帧根据运动学方程计算各零件位置
- 用requestAnimationFrame驱动动画

---

### 运动学计算（以曲柄连杆为例）

这是初中物理，不需要物理引擎：

```javascript
// 曲柄连杆运动学
function calculatePositions(crankAngle, crankRadius, rodLength) {
  // 曲柄销位置
  const crankPinX = crankRadius * Math.cos(crankAngle);
  const crankPinY = crankRadius * Math.sin(crankAngle);
  
  // 活塞位置（沿Y轴）
  const pistonY = crankPinY + 
    Math.sqrt(rodLength * rodLength - crankPinX * crankPinX);
  
  // 连杆角度
  const rodAngle = Math.asin(crankPinX / rodLength);
  
  return { crankPinX, crankPinY, pistonY, rodAngle };
}

// 动画循环
let angle = 0;
function animate() {
  angle += 0.02; // 转速
  const pos = calculatePositions(angle, 50, 120);
  drawMechanism(pos);
  requestAnimationFrame(animate);
}
```

其他机构（凸轮、齿轮等）都有类似的解析解，不需要物理引擎。

---

### 为什么不用物理引擎（Matter.js/Cannon.js）

物理引擎是为了模拟碰撞、重力、摩擦力。专利演示不需要这些，需要的是**精确可预测的运动**，直接用运动学方程更稳定、更快、更容易控制。

---

### 技术风险评估

| 风险 | 概率 | 影响 | 应对 |
|------|------|------|------|
| AI输出的JSON格式不稳定 | 高 | 高 | 做严格的validation + fallback |
| 复杂机构运动学方程难推导 | 中 | 中 | MVP只做5种标准机构 |
| 用户描述太模糊AI无法理解 | 高 | 中 | 提供模板和例句 |
| Three.js性能问题 | 低 | 低 | MVP先用Canvas 2D |
| 视频导出在不同浏览器兼容性 | 中 | 低 | 先只做GIF |

---

## 6. 一周MVP计划

### Day 1（周一）：搭骨架

- [ ] Next.js项目初始化
- [ ] 基础UI：左边输入框，右边Canvas画布
- [ ] 手写一个硬编码的曲柄连杆动画，跑通渲染流程
- [ ] 确认Canvas动画没有性能问题

**目标**：屏幕上出现一个会动的曲柄连杆，哪怕是写死的

### Day 2（周二）：接AI

- [ ] 接入Claude API
- [ ] 写Prompt模板
- [ ] 测试10种不同描述的输出JSON质量
- [ ] 写JSON validator（防止AI输出乱码）

**目标**：输入文字，AI返回JSON，JSON格式正确

### Day 3（周三）：渲染引擎

- [ ] 写通用的"JSON to Canvas Animation"渲染器
- [ ] 支持：circle/rectangle两种形状
- [ ] 支持：rotation/translation两种运动
- [ ] 支持：revolute joint连接

**目标**：任意符合格式的JSON都能渲染成动画

### Day 4（周四）：交互功能

- [ ] 播放/暂停按钮
- [ ] 速度控制滑块
- [ ] 点击零件高亮
- [ ] 文字标注功能（点击空白处加标签）

**目标**：能交互，不只是看

### Day 5（周五）：测试5种机构

- [ ] 曲柄连杆
- [ ] 凸轮推杆
- [ ] 齿轮传动（简单版）
- [ ] 铰链四杆
- [ ] 丝杠螺母

每种机构用3-5种不同表述测试AI理解稳定性

### Day 6（周六）：收尾

- [ ] 导出为GIF
- [ ] 分享链接（Vercel部署后URL直接分享）
- [ ] 清理UI，写3个示例模板
- [ ] 录制30秒demo视频

### Day 7（周日）：找用户

- [ ] 在LinkedIn搜索"litigation graphics"，找5-10个freelancer发冷邮件
- [ ] 在r/law、r/patents发帖（要写成"我在做一个工具，想听取反馈"）
- [ ] 如果认识IP律师，发demo链接给他们

---

## 7. 验证标准

### MVP成功的最低标准

> **一个litigation graphics freelancer看了demo后说：**
> **"我下周有一个专利案，可以用这个试试吗？"**

这一句话，比任何市场分析都值钱。

### 具体验证问题（用户访谈时问）

1. 你现在做一个机械专利的Technical Tutorial动画，平均花多少时间？
2. 你会为一个能把时间缩短到1小时的工具付多少钱？
3. 你的客户（律所）在意动画的精确度到什么程度？
4. 你们用什么软件做现在的工作？
5. 最大的痛点是什么？

### 放弃的标准

以下情况出现，停止这个方向：

- 联系20个potential users，没有一个人表示有兴趣试用（哪怕免费）
- 用户反馈"我们的客户要求精确到毫米，你这个不够用"
- 发现有一个已经存在的工具在做同样的事

---

## 8. 风险与坑

### 风险1：市场太小

**可能性：高**

美国机械专利案每年约1000件，真正愿意付钱用工具的可能只有几十个客户。这个市场很难做到$1M ARR以上。

**应对**：把它当作一个"lifestyle business"来做，或者用它作为敲门砖，后续扩展到更大的市场（产品设计、工程培训等）。

### 风险2：AI生成质量不稳定

**可能性：高**

Claude对"凸轮带动推杆"的理解可能时好时坏，同样的输入不同次可能输出完全不同的JSON。

**应对**：做大量的prompt工程，固化几十种标准机构的描述模板，让用户从模板出发修改，而不是完全自由输入。

### 风险3：客户其实不需要这个

**可能性：中**

Litigation graphics公司已经有成熟的工作流，他们可能不愿意改变。

**应对**：MVP阶段重点找那些**刚入行的freelancer**，他们还没有固化的工作流，更愿意尝试新工具。

### 风险4：法庭可采性问题

**可能性：低（MVP阶段）**

如果律师把你的动画直接用作courtroom exhibit，对方律师可能挑战其准确性。

**应对**：明确定位为"草稿工具"和"沟通辅助"，不是"法庭证据"。这是给律师和专家证人讨论用的，最终的正式材料还是要由人工确认。

### 风险5：竞争对手

目前没有发现直接竞争对手做完全相同的事。但要注意：
- Canva/PowerPoint的AI功能在进化
- Adobe Firefly可能会进入这个领域
- 大型LegalTech公司可能内部在做

---

## 9. 商业模式

### 定价方案（建议测试）

**方案A：Per-case订阅**
- $299/月，无限案件
- 目标客户：litigation graphics freelancer（每月接多个案子）

**方案B：Pay-per-export**
- 免费生成和预览
- $99/次导出（视频/GIF/分享链接）
- 目标客户：偶尔需要的中小律所

**方案C：年度订阅（针对律所）**
- $3,000/年/律所，5个席位
- 目标客户：5-30人的IP律所

### MVP阶段定价策略

**前10个用户：免费，换反馈**

不要太早收钱。先找10个人免费用，每周和他们通一次电话，理解他们的真实需求。产品方向会因此完全改变——这比收$99更值钱。

---

## 10. 下一步行动

### 本周必做（按优先级）

1. **今天**：去Google Patents找3张典型的机械专利图（泵、阀门、齿轮箱），记下专利号
2. **今天**：测试Claude API能否正确理解这3个机构，输出合理的JSON
3. **明天**：用Canvas写一个硬编码的曲柄连杆动画，确认技术路线可行
4. **本周**：找到5个LinkedIn上的litigation graphics freelancer，发消息问他们愿不愿意5分钟通话

### 验证这个想法最快的方法

**不是做产品，是先做一个假的。**

用Claude API生成一个曲柄连杆的SVG动画，手工调整，做成一个看起来像产品的demo页面。把这个发给potential users，问"如果有这样的工具，你会付多少钱？"

这一步不需要写任何产品代码，2小时能完成，但能给你最直接的市场反馈。

---

## 附录：参考资源

### 专利数据库（找测试素材）
- Google Patents: https://patents.google.com
- USPTO: https://www.uspto.gov/patents/search
- Espacenet（欧洲）: https://worldwide.espacenet.com

### 找用户的地方
- LinkedIn搜索："litigation graphics" / "trial graphics" / "patent animation"
- AIGA（美国设计师协会）有法律设计分支
- r/IPLaw / r/Patents（Reddit）
- ABA（美国律师协会）的IP分支论坛

### 技术参考
- Three.js文档: https://threejs.org/docs/
- 机构运动学教材：任何《机械原理》都有四杆机构/凸轮机构的解析公式
- Claude API文档: https://docs.anthropic.com

### 竞品参考（做什么不要做成这样）
- LegalGraphicsPro: https://www.legalgraphicspro.com（手工，贵，慢）
- Demonstratives.com（同上）
- 这些是你要替代的工作流，不是竞品

---

*最后说一句实话：这个市场不大，但足够一个indie活得好。做之前先花3天找用户访谈，比花3个月写代码要聪明。*
