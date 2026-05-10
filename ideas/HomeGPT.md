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
- 多轮对话，对话历史本地保存（localStorage / IndexedDB）
- 侧边栏会话列表，按时间分组：**今天 / 昨天 / 更早**
- 移动端适配
- 深色模式
- 访问密码：`CODE` 环境变量

### 安全约束（不能让步）

- `OPENAI_API_KEY` 走环境变量，**严禁** `NEXT_PUBLIC_` 前缀，**严禁**暴露到前端
- 所有 OpenAI 调用经过自己的后端 API route，前端只把 messages 发到自己的后端
- 密码 `CODE` 在后端校验，前端只持有"已通过校验"的会话 token（cookie / localStorage flag）

---

## 四、明确不做什么

- ❌ 用户系统、注册登录、账单（密码挡门就够）
- ❌ 多模型供应商（默认 OpenAI；要换其他厂商就直接改代码，不做配置层）
- ❌ 面具 / 角色预设
- ❌ 插件 / Function calling 工具调用
- ❌ 知识库 / RAG / 文件上传
- ❌ 服务端历史持久化（历史只存浏览器；换浏览器就重来——刻意决定，省后端 DB）
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
| Storage | localStorage（简单）或 IndexedDB（`dexie.js`，对话量大时） |
| AI | OpenAI SDK |
| Deploy | Vercel |
| **不要** | Supabase / Postgres / Auth / Stripe / Resend |

---

## 六、部署 & 环境变量

### Vercel 环境变量

```bash
# 必填
OPENAI_API_KEY=          # 后端 only，禁止 NEXT_PUBLIC_ 前缀
CODE=                    # 访问密码

# 可选
OPENAI_BASE_URL=         # 走第三方 API 代理时填（如国内中转）
OPENAI_MODEL=            # 默认 gpt-4o-mini，要换就在这里
```

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
