# 两个月 B端 AI 技能学习计划
> 目标：从 entry level 出发，两个月内掌握所有核心技能，开始服务本地中小企业

---

## 🧭 核心思路

B端 AI 项目的本质是**把 AI 接进企业已有系统**，而不是训练模型。你需要掌握的是"连接层"技能：

```
API调用 → 自动化工作流 → Agent构建 → 系统集成 → 交付给本地企业
```

---

## 📋 技术栈全景（先整体看懂再分周学）

```
基础层：Python + API 调用
  ↓
AI层：OpenAI / Claude API（Prompt 工程）
  ↓
记忆层：向量数据库（Pinecone / Chroma）+ RAG
  ↓
框架层：LangChain / LangGraph（Agent 编排）
  ↓
自动化层：n8n / Make.com（无代码流程）
  ↓
集成层：CRM API / Webhook / REST API
  ↓
部署层：FastAPI + Railway/Render 上线
```

---

## 📅 第一个月：打地基（Week 1–4）

---

### Week 1：Python 快速补强 + OpenAI API 入门

**目标：能写能跑，不卡工具**

每天时间：2–3 小时

#### Day 1–2：Python 核心语法速通

学习资源：Python官方教程（中文版）或 B站"Python入门"

重点掌握：
- `list` / `dict` / `for` / `if` / `function`
- `requests` 库发 HTTP 请求
- 读写 `.json` 文件
- `pip install` 装包

> ⚠️ 不需要学：类继承、多线程、装饰器（暂时跳过）

#### Day 3–4：调用 OpenAI API

注册 OpenAI，拿到 API Key，安装：`pip install openai`

```python
from openai import OpenAI
client = OpenAI(api_key="你的key")

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "你是一个客服助手"},
        {"role": "user", "content": "我的订单在哪里？"}
    ]
)
print(response.choices[0].message.content)
```

练习变体：改 system prompt、加上下文记忆（把历史对话传入 messages）

#### Day 5–6：Prompt 工程（B端核心技能）

这是 B 端项目里用得最多的技能，必须精通：

| 技巧 | 说明 | 示例 |
|---|---|---|
| Role Prompting | 给模型设定角色 | "你是一个专业的销售顾问" |
| Few-shot | 给例子 | "以下是3个好回复的例子..." |
| Chain of Thought | 让模型分步思考 | "请一步步分析..." |
| Output Format | 控制输出格式 | "请以JSON格式返回，字段包含..." |
| Constraint | 限制行为 | "只回答与产品相关的问题，其他一律拒绝" |

**⭐ 重点强化：Structured Output（结构化输出）**

> 这是 B 端系统对接的关键。AI 结果要填入 CRM / Excel / 数据库时，必须保证格式 100% 准确，否则下游系统会出错。

```python
from openai import OpenAI
import json

client = OpenAI()

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {
            "role": "system",
            "content": """你是一个线索分析助手。
请分析以下线索信息，并严格按照JSON格式返回，不要输出任何其他内容：
{
  "score": 1-10的整数,
  "industry": "所属行业",
  "pain_point": "核心痛点（一句话）",
  "priority": "high/medium/low",
  "suggested_action": "建议的第一步行动"
}"""
        },
        {
            "role": "user",
            "content": "公司：某律所，联系人：张律师，需求：想把合同审查自动化，团队10人"
        }
    ]
)

# 解析JSON，确保格式正确
result = json.loads(response.choices[0].message.content)
print(result["score"])       # 可以直接取字段
print(result["priority"])    # 写入CRM不会出错
```

练习要求：让输出格式出错（故意给错误prompt），再修复——这个debug能力在实际项目中非常重要。

**练习项目**：写一个"AI 客服机器人"的 system prompt，能回答产品FAQ、拒绝无关问题、以 JSON 格式输出结构化回复（包含 answer、confidence、category 三个字段）

#### Day 7：做一个完整的小项目

**项目：AI 邮件回复助手**
- 输入：客户邮件原文
- 输出：3种不同风格的回复草稿（正式 / 友好 / 简洁）
- 用 Python 脚本跑通，结果存入 txt 文件

---

### Week 2：LangChain 核心 + RAG 知识库系统

**目标：能构建有记忆的对话系统，并让 AI 读懂企业文档**

#### Day 1–2：LangChain 基础

安装：`pip install langchain langchain-openai`

学习资源：LangChain 官方文档（只看 Get Started 部分）

重点理解：
- `ChatPromptTemplate` — 模板化 prompt
- `ChatOpenAI` — 模型调用
- `chain = prompt | model | parser` — LCEL 管道写法

#### Day 3：对话记忆（Memory）

```python
from langchain_openai import ChatOpenAI
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain

llm = ChatOpenAI(model="gpt-4o")
memory = ConversationBufferMemory()
conversation = ConversationChain(llm=llm, memory=memory)

conversation.predict(input="我叫张三")
conversation.predict(input="我叫什么名字？")  # 应该回答：张三
```

练习：ConversationBufferMemory vs ConversationSummaryMemory 的区别

#### Day 4–5：RAG 系统（检索增强生成）— B端最刚需

让 AI 读懂企业自己的文档，是客户愿意付高价的核心功能：

```python
from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma
from langchain.chains import RetrievalQA
from langchain_openai import ChatOpenAI

# 1. 加载文档
loader = PyPDFLoader("company_manual.pdf")
docs = loader.load()

# 2. 切片
splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
chunks = splitter.split_documents(docs)

# 3. 向量化存储
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(chunks, embeddings)

# 4. 问答链
qa = RetrievalQA.from_chain_type(
    llm=ChatOpenAI(model="gpt-4o"),
    retriever=vectorstore.as_retriever()
)
print(qa.invoke("公司的退款政策是什么？"))
```

**⭐ 重点强化：显示引用来源（Citations）**

> 本地企业老板最怕 AI "胡说"。能显示"这个答案来自第3页第2段"，是打消客户顾虑、拿下订单的直接武器。

```python
from langchain.chains import RetrievalQA
from langchain_openai import ChatOpenAI
from langchain.chains.question_answering import load_qa_chain

# 使用 return_source_documents=True 返回来源
qa = RetrievalQA.from_chain_type(
    llm=ChatOpenAI(model="gpt-4o"),
    retriever=vectorstore.as_retriever(search_kwargs={"k": 3}),
    return_source_documents=True  # 关键参数
)

result = qa.invoke("公司的退款政策是什么？")

print("📌 AI 回答：")
print(result["result"])

print("\n📄 来源段落：")
for i, doc in enumerate(result["source_documents"]):
    page = doc.metadata.get("page", "未知")
    print(f"  [{i+1}] 第{page+1}页：{doc.page_content[:100]}...")
```

演示给客户看时，输出格式如下：
```
📌 AI 回答：
退款需在购买后7天内申请，提供订单号即可全额退款。

📄 来源段落：
  [1] 第3页：7.2 退款政策——客户在购买后7天内可申请无理由退款...
  [2] 第5页：附录A——退款流程说明，需提供有效订单编号...
```

这个细节让你的演示比其他人专业一个档次。

#### Day 6–7：Week 2 项目（作品集 #1）

**项目：企业内部知识库问答系统**
- 上传一个 PDF（任何公司手册或产品文档）
- 用户输入问题，AI 从文档中找答案
- 显示来源段落（引用来源是 B 端的加分项）
- 录制演示视频，放入作品集 ✅

---

### Week 3：AI Agent 构建

**目标：能构建能自主决策、调用工具的 Agent**

#### Day 1–2：理解 Agent 的本质

Agent = LLM + Tools + Loop（让模型不断决策直到任务完成）

```
用户：帮我查一下苹果公司今天的股价，然后写一份分析报告

Agent 思考：
→ 我需要先查股价（调用 search_tool）
→ 拿到数据后写报告（调用 write_tool）
→ 任务完成
```

#### Day 3–4：用 LangChain 构建 Tool-calling Agent

```python
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain.tools import tool
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate

@tool
def search_crm(customer_name: str) -> str:
    """在CRM系统中搜索客户信息"""
    # 实际项目中这里调用 HubSpot API
    return f"客户{customer_name}：VIP用户，上次购买日期2024-12-01，总消费$5000"

@tool
def send_email(to: str, subject: str, body: str) -> str:
    """发送邮件给客户"""
    return f"邮件已发送给{to}"

tools = [search_crm, send_email]
llm = ChatOpenAI(model="gpt-4o")

prompt = ChatPromptTemplate.from_messages([
    ("system", "你是一个销售助手，帮助查询客户信息并发送个性化邮件"),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}")
])

agent = create_tool_calling_agent(llm, tools, prompt)
executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
executor.invoke({"input": "查询张三的信息，然后给他发一封感谢邮件"})
```

#### Day 5：LangGraph（进阶 Agent 框架）

为什么要学：复杂 B 端项目需要多步骤、条件分支的 Agent 流程

只学核心概念：State、Node、Edge

资源：LangGraph 官方 Quickstart（langchain-ai.github.io/langgraph）

#### Day 6–7：Week 3 项目（作品集 #2）

**项目：AI 销售线索处理 Agent**
- 输入：一条新线索（公司名、联系人、需求描述）
- Agent 自动执行：
  1. 分析线索质量（打分 1–10）
  2. 搜索公司信息（用 DuckDuckGo Search Tool）
  3. 生成个性化的第一封开发信
  4. 输出结构化报告

---

### Week 4：n8n 无代码自动化（B端必备神器）

**目标：能用 n8n 搭建企业级自动化流程，快速交付项目**

> 💡 很多本地中小企业预算有限，n8n 可以快速交付，不需要全程写代码，性价比极高。

#### Day 1–2：n8n 安装与基础

安装方式：
- 本地：`npx n8n` 或用 Docker
- 注册 n8n Cloud 免费试用（推荐）

核心概念：Trigger（触发器）→ Node（处理节点）→ Action（执行动作）

练习：
- 每天早上9点，自动发一封天气邮件给自己
- 当 Google Sheet 新增一行数据时，发微信/邮件通知

#### Day 3–4：n8n 接入 AI

在 n8n 中使用 OpenAI 节点，搭建这个流程：

```
客户填写表单（Typeform / 腾讯问卷）
  → n8n 触发
  → OpenAI 分析客户需求
  → 自动生成回复邮件
  → 发送邮件（Gmail 节点）
  → 记录到 Google Sheet
```

#### Day 5：n8n + Webhook + CRM

- 学会 Webhook 节点（B端集成的关键）
- 练习：CRM 有新联系人时 → AI 自动打标签分类

#### Day 6–7：Week 4 项目（作品集 #3）

**项目：全自动线索跟进流程**
- 触发：新线索填写表单
- 步骤1：AI 分析线索 → 判断是否为目标客户
- 步骤2：是目标客户 → 发个性化邮件 + 记录 CRM
- 步骤3：不是目标客户 → 发婉拒邮件
- 步骤4：3天无回复 → 自动发跟进邮件
- 录制 Loom 视频演示 ✅

---

## 📅 第二个月：实战拔高（Week 5–8）

---

### Week 5：API 集成与 FastAPI 部署

**目标：能把 AI 功能部署成在线服务，让客户系统直接调用**

#### Day 1–2：REST API 基础

- 理解 GET / POST / PUT / DELETE
- 理解 JSON 数据格式
- 理解 API Key 鉴权
- 工具：用 Postman 测试各种 API

#### Day 3–4：FastAPI 快速入门

安装：`pip install fastapi uvicorn`
运行：`uvicorn main:app --reload`

```python
from fastapi import FastAPI
from pydantic import BaseModel
from openai import OpenAI

app = FastAPI()
client = OpenAI()

class QueryRequest(BaseModel):
    question: str
    company_id: str

@app.post("/ask")
async def ask_ai(request: QueryRequest):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": f"你是{request.company_id}的专属客服助手"},
            {"role": "user", "content": request.question}
        ]
    )
    return {"answer": response.choices[0].message.content}
```

#### Day 5：部署上线

- 注册 Railway（railway.app）或 Render（render.com）— 免费额度够用
- 把 FastAPI 项目部署上去，得到真实 HTTPS 链接
- 这样你可以告诉本地客户："你们系统直接调用这个接口就行"

#### Day 6–7：Week 5 项目（作品集 #4）

**项目：企业知识库 API 服务**
- 把 Week 2 的 RAG 项目包装成 API
- 接口：`POST /ask` → 输入问题 → 返回答案 + 来源段落
- 部署上线，得到真实 URL ✅

---

### Week 6：主流 B端工具集成

**目标：能对接企业常用工具（CRM / 通讯 / 文档系统）**

#### Day 1–2：CRM API 集成

以 HubSpot 为例（免费版可用）：

```python
import requests

HUBSPOT_TOKEN = "你的token"
headers = {"Authorization": f"Bearer {HUBSPOT_TOKEN}"}

# 创建联系人
data = {
    "properties": {
        "email": "test@example.com",
        "firstname": "张",
        "lastname": "三",
        "company": "ABC公司"
    }
}
requests.post(
    "https://api.hubapi.com/crm/v3/objects/contacts",
    json=data,
    headers=headers
)
```

常见操作：获取联系人列表 / 创建联系人 / 更新属性 / 创建 Deal

#### Day 3：企业通讯集成

- 企业微信 / 钉钉 Webhook：AI 完成任务后推送消息到群
- 这是国内本地企业最常用的通知方式
- 练习：n8n 定时任务 → AI 生成日报 → 推送到企业微信群

#### Day 4：Notion / 飞书文档 API

- 学会读写文档数据库
- 常见场景：AI 处理完内容后，自动写入飞书多维表格

#### Day 5–7：Week 6 综合项目（作品集 #5）

**项目：AI 销售日报自动化系统**
- 每天下班时触发（n8n 定时任务）
- 从 CRM 拉取当天所有销售动态
- AI 生成销售日报（成交情况、待跟进建议）
- 推送到企业微信群
- 同时写入飞书多维表格存档

> 这是最接近真实本地企业需求的项目，演示效果极好

---

### Week 7：Voice AI Agent（高价方向）

**目标：能构建企业电话 / 语音 AI 系统**

> 💰 语音 AI 是 B 端单价最高的方向之一，本地企业（餐饮、诊所、门店）需求非常旺盛，一个项目交付价 5000–20000 元不等。

#### Day 1–2：VAPI 平台入门

注册 VAPI.ai，理解整体架构：

```
电话呼入
  → VAPI 转成文字（STT）
  → 发给 LLM 处理
  → LLM 回复内容
  → 转成语音播放（TTS）
  → 继续对话
```

在 VAPI 控制台创建第一个语音 Agent，配置：
- System Prompt（角色设定 / 性格）
- 开场白
- 结束语条件

#### Day 3–4：VAPI 高级配置

Functions（工具调用）：电话中 AI 实时查询数据库 / CRM

示例对话流程：
```
AI：您好，请问您的订单号是多少？
用户：123456
AI：（调用查询工具）您的订单将在明天下午送达，请注意签收。
```

配置项：
- End Call 条件（何时挂断）
- Voicemail 检测（无人接听时留言）
- 语音角色选择（音色 / 语速 / 语言）

#### Day 5：VAPI + n8n 联动

```
通话结束
  → VAPI 发 Webhook 到 n8n
  → n8n 自动处理：
      记录通话摘要
      更新 CRM 联系人
      发企业微信通知给销售
```

#### Day 6–7：Week 7 项目（作品集 #6）

**项目：AI 预约接待语音机器人**
- 功能：接听客户电话 → 了解预约需求 → 查询可用时间 → 确认预约 → 发短信确认
- 适用客户：诊所、美容院、餐厅、律所
- 录制演示视频（用 VAPI 的测试功能打给自己）✅

---

### Week 8：作品集打磨 + 本地客户开发

**目标：准备好所有材料，开始联系本地中小企业，拿下第一个付费客户**

#### Day 1–2：整理作品集

你现在已经有 6 个项目：

| # | 项目名称 | 展示的核心技能 |
|---|---|---|
| 1 | 企业知识库问答系统 | RAG / LangChain |
| 2 | AI 销售线索处理 Agent | Tool-calling Agent |
| 3 | 全自动线索跟进流程 | n8n 自动化 |
| 4 | 企业知识库 API 服务 | FastAPI / 部署 |
| 5 | AI 销售日报自动化 | 多系统集成 |
| 6 | AI 预约接待语音机器人 | Voice AI |

每个项目整理：
- 录制 2–3 分钟录屏演示（可用 OBS / 剪映）
- 截图 + 流程图放入 GitHub README
- 用一句话总结项目价值（写给老板看，不是给程序员看）
  - ❌ "基于 LangChain 构建 RAG 系统"
  - ✅ "让员工直接问 AI 查公司文件，节省每天 2 小时人工翻查时间"

#### Day 3–4：准备客户沟通材料

**一页介绍文档（发给老板看的）**

```
标题：用 AI 帮您的企业自动化日常工作

我可以帮您做什么：
• 搭建 AI 客服：7×24 自动回答客户问题，无需人工值守
• 自动整理线索：新客户信息自动录入、分类、跟进
• 语音接待机器人：电话自动接听、预约、查询
• 内部知识库：员工直接问 AI，不用翻手册

合作方式：
• 项目制，按功能交付，不按小时收费
• 先做免费演示，满意再付款
• 提供1个月免费维护

联系方式：[你的微信 / 电话]
```

**定价参考（本地企业版）**

| 项目类型 | 建议报价 | 交付周期 |
|---|---|---|
| 简单 n8n 自动化（如线索跟进） | 2000–5000 元 | 3–5天 |
| AI 客服知识库 | 5000–12000 元 | 1–2周 |
| AI Agent 定制 | 8000–20000 元 | 2–3周 |
| 语音预约机器人 | 10000–30000 元 | 2–4周 |

> 💡 前 2–3 个客户可以半价，目的是拿案例和口碑，之后恢复正常定价

#### Day 5–7：开始接触本地企业

**目标客户画像（最容易成单）**

优先找这类企业：
- **诊所 / 口腔 / 美容院**：需要语音预约机器人，重复电话多
- **中小律所**：需要 AI 检索内部案例文档
- **本地零售 / 连锁店**：需要自动化线索跟进和客户运营
- **教培机构**：需要 AI 客服回答课程咨询、自动发资料
- **本地 SaaS / 软件公司**：需要给产品加 AI 功能

**找客户的方式**

1. **身边人**：先问家人 / 朋友做不做生意，或者认不认识做生意的
2. **微信朋友圈**：发一条"帮本地企业做 AI 自动化"的内容，配演示视频
3. **本地商会 / 创业群**：加入后观察需求，主动提供解决方案
4. **线下拜访**：带着 iPad，当场演示 AI 语音接待机器人，直观震撼
5. **抖音 / 小红书**：发"我帮XX类企业做了AI自动化"的案例视频（用练习项目演示）

**第一次见面话术**

```
"我最近在帮本地企业用 AI 自动化一些日常工作，
比如客服回复、线索跟进、电话接待这些。
我们可以先聊聊你们现在哪些事情最耗人工时间，
我帮你看看有没有办法用 AI 省掉——
第一次我可以免费给你做个演示。"
```

**跟进节奏**

```
第1次：见面演示 / 发演示视频
第2次（3天后）：发一页介绍文档 + 简单方案
第3次（1周后）：提供一个针对他们问题的免费小原型
签单：用微信收款，合同可用简单协议
```

---

## 🛠️ 工具账号清单（提前注册）

| 工具 | 用途 | 费用 |
|---|---|---|
| OpenAI | LLM API | 按量付费，$20够练习 |
| n8n Cloud | 自动化流程 | 免费试用 |
| VAPI.ai | 语音 AI | 按分钟付费 |
| Railway / Render | 项目部署 | 免费额度 |
| HubSpot | CRM 练习 | 免费版 |
| Pinecone | 向量数据库 | 免费版 |
| GitHub | 代码托管 + 作品集 | 免费 |
| OBS / 剪映 | 录制演示视频 | 免费 |
| Canva | 做一页介绍文档 | 免费版 |

---

## 📚 核心学习资源

| 资源 | 内容 | 地址 |
|---|---|---|
| LangChain 官方文档 | Agent / RAG | python.langchain.com |
| LangGraph Quickstart | 复杂 Agent 流程 | langchain-ai.github.io/langgraph |
| n8n 官方教程 | 自动化节点 | docs.n8n.io |
| VAPI 文档 | 语音 AI | docs.vapi.ai |
| DeepLearning.AI | LLM 应用免费课程 | deeplearning.ai |
| FastAPI 文档 | API 部署 | fastapi.tiangolo.com |

---

## ⚡ 每日时间分配（2–3小时/天）

```
前 45 分钟：看文档 / 教程（输入）
中 60 分钟：动手写代码 / 搭流程（实践）
后 30 分钟：Debug / 记录问题（巩固）
剩余时间：观察本地企业痛点，思考用哪个项目演示
```

---

## 🗓️ 全计划一览表

| 周次 | 核心内容 | 交付物 |
|---|---|---|
| Week 1 | Python + OpenAI API + Prompt 工程 | AI 邮件助手脚本 |
| Week 2 | LangChain + 记忆 + RAG | 知识库问答系统（作品集#1） |
| Week 3 | AI Agent + Tool Calling + LangGraph | 线索处理 Agent（作品集#2） |
| Week 4 | n8n 自动化 + AI 节点 + Webhook | 线索跟进流程（作品集#3） |
| Week 5 | FastAPI + REST API + 云部署 | 知识库 API 上线（作品集#4） |
| Week 6 | CRM / 企业微信 / 飞书集成 | 销售日报自动化（作品集#5） |
| Week 7 | VAPI 语音 AI + 通话后自动化 | 预约语音机器人（作品集#6） |
| Week 8 | 作品集打磨 + 本地客户开发 | **第一个付费客户** |

---

> 📌 **最重要的一句话**：Week 2 结束后就开始整理作品集、联系身边的人演示。不要等"学完"再出发——边学边接触客户，才是最快拿到第一单的路径。

---

*文档生成日期：2026年3月*
