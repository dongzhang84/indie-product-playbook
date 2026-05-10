# HomeGPT · 产品计划

> 给国内家人用的网页版 ChatGPT，部署在 Vercel，密码保护、不做用户系统。

## One-liner

A personal home ChatGPT for family in China — Vercel-deployed, password-gated, OpenAI API hidden behind a backend, chat history stored locally in the browser.

---

## 一、产品定位

**家庭内部工具，不是商业产品**。把 ChatGPT 的核心交互（流式对话、Markdown 渲染、历史记录、侧边栏）打包成一个简单的网页应用，部署一次给家里人用。

不卖、不做注册、不做运营、不做留存优化。一个人维护，几个人使用，每月 OpenAI API 成本由部署者承担。

不是 Track A，不是 Track 0+——是一个**实用 utility**。它在 `ideas/` 里因为它是要建的东西，但不进入战略主线。

---

## 二、目标用户

- **直接用户**：家里几个人（父母、伴侣、亲戚朋友）
- **不目标**：陌生人、推广用户、商业客户

## 三、核心功能

### 必做

- 聊天界面，UI 参考 chatgpt.com
- 接 OpenAI API（默认 `gpt-4o-mini`，环境变量可换）
- 流式输出（streaming response，逐字出现）
- Markdown 渲染：**代码高亮 + 表格 + 数学公式（KaTeX）**
- 多轮对话
- 侧边栏会话列表，按时间分组：**今天 / 昨天 / 更早**
- 移动端适配
- 深色模式
- **密码即身份**：`MEMBERS` 环境变量配置每位家庭成员的简单密码（如 4 位数字）。输入密码即识别成员身份——无注册、无昵称选择、1 步到位
- **每位成员独立的会话历史和侧边栏**——历史按成员分组存服务端

### 安全约束（不能让步）

- `OPENAI_API_KEY` 走环境变量，**严禁** `NEXT_PUBLIC_` 前缀，**严禁**暴露到前端
- 所有 OpenAI 调用经过自己的后端 API route，前端只把 messages 发到自己的后端
- 密码在后端校验。校验通过后给前端一个签名 cookie（包含成员 id），后续请求带 cookie 识别
- 密码错误限速：5 次失败 → 1 分钟锁定（防爆破）

---

## 四、明确不做什么

- ❌ 注册流程、邮箱验证、账单——密码即身份代替
- ❌ 多模型供应商（默认 OpenAI；要换其他厂商就直接改代码，不做配置层）
- ❌ 面具 / 角色预设
- ❌ 插件 / Function calling 工具调用
- ❌ 知识库 / RAG / 文件上传
- ❌ 用户自助修改密码——部署者（你）改环境变量
- ❌ 团队协作、共享对话、URL 分享
- ❌ 收费 / 计量 / 限额

---

## 五、技术栈

| 模块 | 选型 |
|------|------|
| Framework | Next.js 14 App Router + TypeScript |
| Styling | Tailwind CSS + Shadcn/ui |
| Markdown | `react-markdown` + `remark-gfm` + `rehype-highlight` + KaTeX |
| State | zustand 或纯 React state（无需 Redux） |
| **Database** | **Vercel Postgres**（一张表 `messages`，按 `member_id` 分组） |
| Cookie | iron-session 或 jose 签名 cookie（不引 Supabase Auth） |
| AI | OpenAI SDK |
| Deploy | Vercel |
| **不要** | Supabase Auth / Stripe / Resend / 第三方注册系统 |

---

## 六、部署 & 环境变量

### Vercel 环境变量

```bash
# 必填
OPENAI_API_KEY=                            # 后端 only，禁止 NEXT_PUBLIC_ 前缀
MEMBERS=爸爸:1234,妈妈:4321,小明:5678      # 成员:密码,成员:密码（密码必须唯一）
SESSION_SECRET=                            # cookie 签名密钥，openssl rand -base64 32

# 数据库（Vercel Postgres，部署时一键创建）
POSTGRES_URL=                              # Vercel 自动注入

# 可选
OPENAI_BASE_URL=                           # 走第三方 API 代理时填（如国内中转）
OPENAI_MODEL=                              # 默认 gpt-4o-mini，要换就在这里
```

### MEMBERS 格式约定

- 格式：`成员名:密码,成员名:密码,...`
- 成员名：任意中英文，不含逗号 `,` 和冒号 `:`
- 密码：建议 4-6 位数字（家人好记），不允许重复
- 部署时校验：解析失败 / 密码重复 → app 启动失败并报错（避免悄悄出问题）

### 加 / 删成员

改 Vercel `MEMBERS` 环境变量 → 重新部署。

- **删某成员**：删掉对应 `名:密码` 段。**该成员的历史记录保留在 DB 里**（无 UI 入口访问），后续可手动清理
- **改某成员密码**：直接改密码部分，历史不变（按 member_id 关联，不是按密码）

### 域名绑定（重要）

`*.vercel.app` 默认域名在国内**不稳定**（被墙概率高）。需要：
- 买独立域名（aliyun / cloudflare / namecheap 任意）
- Vercel Settings → Domains 绑定
- DNS 按 Vercel 提示配置 A / CNAME
- 验证国内可达：用手机 4G、家里 wifi 都试一下

如果绑定后国内仍打不开，需要 Cloudflare Workers reverse proxy——但这超出 MVP 范围，留给 v0.2。

### OpenAI API 区域

OpenAI 官方 API 在中国大陆封禁。**但部署在 Vercel 上不受影响**——前端在国内访问的是 Vercel 域名，Vercel 服务端（美国 IP）调用 OpenAI 是 server-to-server 通信。

如果发现 Vercel 偶尔抽风，备选：
- 走第三方 OpenAI 兼容 API 代理（oneapi.icu / 各种 relay）：填 `OPENAI_BASE_URL`
- 保持 OpenAI 官方：默认就是这条路

---

## 七、MVP 范围

一句话：**聊天 UI + 后端 OpenAI proxy + localStorage 历史 + 密码门 + Vercel 部署 + 自己域名**。

预计 vibe coding **3-7 天能跑通**。

---

## 八、下一步

1. **命名**：HomeGPT / JiaChat / PrivateGPT / ChatHome —— 待定
2. **写 implementation guide**：参考 `implementation-guides/vibe-reading.md` 简化版（无 auth / 无 DB / 无 Stripe）
3. **跑** `bash stack/new-project.sh HomeGPT "HomeGPT"` 建 repo
4. **Phase 0 vibe code MVP**
5. **部署 + 域名 + 给家人发链接和密码**

---

## 命名候选

| 候选 | 倾向 |
|------|------|
| **HomeGPT** | 直接、英文、易记 |
| JiaChat | "家"拼音 + Chat，中文味道 |
| PrivateGPT | 隐私感强（但已有同名开源项目，避免） |
| ChatHome | 平淡 |

倾向 `HomeGPT`，待你拍板。
