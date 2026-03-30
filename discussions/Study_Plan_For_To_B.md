# Two-Month B2B AI Skills Learning Plan
> Goal: Starting from entry level, master all core skills within two months and begin serving local small and medium-sized businesses.

---

## Core Approach

The essence of B2B AI projects is **connecting AI into a company's existing systems** — not training models. The skills you need are in the "integration layer":

```
API calls → Automated workflows → Agent building → System integration → Deliver to local businesses
```

---

## Tech Stack Overview (understand the full picture before diving in week by week)

```
Foundation:   Python + API calls
     ↓
AI Layer:     OpenAI / Claude API (Prompt Engineering)
     ↓
Memory Layer: Vector databases (Pinecone / Chroma) + RAG
     ↓
Framework:    LangChain / LangGraph (Agent orchestration)
     ↓
Automation:   n8n / Make.com (no-code workflows)
     ↓
Integration:  CRM API / Webhook / REST API
     ↓
Deployment:   FastAPI + Railway/Render
```

---

## Month 1: Build the Foundation (Week 1–4)

---

### Week 1: Python Quick Review + OpenAI API Basics

**Goal: Write it, run it, don't get stuck on tools**

Daily time: 2–3 hours

#### Day 1–2: Python Core Syntax Speed Run

Learning resources: Official Python Tutorial or any beginner Python course on YouTube

Key topics:
- `list` / `dict` / `for` / `if` / `function`
- `requests` library for HTTP calls
- Reading and writing `.json` files
- Installing packages with `pip install`

> Skip for now: class inheritance, multithreading, decorators

#### Day 3–4: Calling the OpenAI API

Sign up for OpenAI, get an API key, install: `pip install openai`

```python
from openai import OpenAI
client = OpenAI(api_key="your-key")

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "You are a customer service assistant."},
        {"role": "user", "content": "Where is my order?"}
    ]
)
print(response.choices[0].message.content)
```

Practice variations: change the system prompt, add conversation memory (pass chat history into `messages`)

#### Day 5–6: Prompt Engineering (Core B2B Skill)

This is the most-used skill in B2B projects — you must master it:

| Technique | Description | Example |
|---|---|---|
| Role Prompting | Assign a role to the model | "You are a professional sales advisor." |
| Few-shot | Provide examples | "Here are 3 examples of good responses..." |
| Chain of Thought | Ask the model to reason step by step | "Please analyze this step by step..." |
| Output Format | Control the output format | "Return JSON with fields: ..." |
| Constraint | Restrict behavior | "Only answer product-related questions; decline everything else." |

**⭐ Key focus: Structured Output**

> This is critical for B2B system integration. When AI results need to go into a CRM, Excel, or database, the format must be 100% accurate — otherwise downstream systems break.

```python
from openai import OpenAI
import json

client = OpenAI()

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {
            "role": "system",
            "content": """You are a lead analysis assistant.
Analyze the lead below and return ONLY a JSON object — no other text:
{
  "score": integer from 1 to 10,
  "industry": "industry name",
  "pain_point": "core pain point in one sentence",
  "priority": "high/medium/low",
  "suggested_action": "recommended first step"
}"""
        },
        {
            "role": "user",
            "content": "Company: a law firm, Contact: Attorney Zhang, Need: automate contract review, Team size: 10"
        }
    ]
)

result = json.loads(response.choices[0].message.content)
print(result["score"])     # Access fields directly
print(result["priority"])  # Safe to write to CRM
```

Practice: intentionally break the format with a bad prompt, then fix it — this debug skill is critical in real projects.

**Practice project**: Write a system prompt for an "AI customer service bot" that answers product FAQs, rejects off-topic questions, and returns structured JSON replies with three fields: `answer`, `confidence`, and `category`.

#### Day 7: Build One Complete Mini-Project

**Project: AI Email Reply Assistant**
- Input: original customer email
- Output: 3 reply drafts in different tones (formal / friendly / concise)
- Run as a Python script, save results to a `.txt` file

---

### Week 2: LangChain Core + RAG Knowledge Base System

**Goal: Build conversation systems with memory, and let AI understand company documents**

#### Day 1–2: LangChain Basics

Install: `pip install langchain langchain-openai`

Learning resource: LangChain official docs (Get Started section only)

Key concepts:
- `ChatPromptTemplate` — templated prompts
- `ChatOpenAI` — model invocation
- `chain = prompt | model | parser` — LCEL pipe syntax

#### Day 3: Conversation Memory

```python
from langchain_openai import ChatOpenAI
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain

llm = ChatOpenAI(model="gpt-4o")
memory = ConversationBufferMemory()
conversation = ConversationChain(llm=llm, memory=memory)

conversation.predict(input="My name is John.")
conversation.predict(input="What is my name?")  # Should answer: John
```

Practice: understand the difference between `ConversationBufferMemory` and `ConversationSummaryMemory`

#### Day 4–5: RAG System (Retrieval-Augmented Generation) — Most In-Demand B2B Feature

Letting AI understand a company's own documents is the core feature clients will pay top dollar for:

```python
from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Chroma
from langchain.chains import RetrievalQA
from langchain_openai import ChatOpenAI

# 1. Load document
loader = PyPDFLoader("company_manual.pdf")
docs = loader.load()

# 2. Split into chunks
splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
chunks = splitter.split_documents(docs)

# 3. Embed and store
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(chunks, embeddings)

# 4. Q&A chain
qa = RetrievalQA.from_chain_type(
    llm=ChatOpenAI(model="gpt-4o"),
    retriever=vectorstore.as_retriever()
)
print(qa.invoke("What is the company's refund policy?"))
```

**⭐ Key focus: Show citation sources**

> Business owners are most afraid of AI "making things up." Being able to show "this answer comes from page 3, paragraph 2" directly removes client skepticism and helps close deals.

```python
qa = RetrievalQA.from_chain_type(
    llm=ChatOpenAI(model="gpt-4o"),
    retriever=vectorstore.as_retriever(search_kwargs={"k": 3}),
    return_source_documents=True  # key parameter
)

result = qa.invoke("What is the company's refund policy?")

print("Answer:")
print(result["result"])

print("\nSources:")
for i, doc in enumerate(result["source_documents"]):
    page = doc.metadata.get("page", "unknown")
    print(f"  [{i+1}] Page {page+1}: {doc.page_content[:100]}...")
```

Demo output format:
```
Answer:
Refunds can be requested within 7 days of purchase by providing the order number for a full refund.

Sources:
  [1] Page 3: 7.2 Refund Policy — customers may request a no-questions-asked refund within 7 days...
  [2] Page 5: Appendix A — Refund process requires a valid order number...
```

This detail makes your demo look a full level more professional than competitors.

#### Day 6–7: Week 2 Project (Portfolio #1)

**Project: Company Internal Knowledge Base Q&A System**
- Upload a PDF (any company manual or product document)
- User types a question; AI finds the answer from the document
- Show source paragraphs (citations are a major plus in B2B)
- Record a demo video and add it to your portfolio ✅

---

### Week 3: AI Agent Development

**Goal: Build agents that can make decisions autonomously and call tools**

#### Day 1–2: Understand What an Agent Actually Is

Agent = LLM + Tools + Loop (the model keeps deciding until the task is done)

```
User: Check Apple's stock price today and write an analysis report.

Agent reasoning:
→ I need to look up the price first (call search_tool)
→ Then write the report with that data (call write_tool)
→ Task complete
```

#### Day 3–4: Build a Tool-Calling Agent with LangChain

```python
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain.tools import tool
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate

@tool
def search_crm(customer_name: str) -> str:
    """Search for customer information in the CRM system."""
    # In a real project, this calls the HubSpot API
    return f"Customer {customer_name}: VIP, last purchase 2024-12-01, total spend $5,000"

@tool
def send_email(to: str, subject: str, body: str) -> str:
    """Send an email to a customer."""
    return f"Email sent to {to}"

tools = [search_crm, send_email]
llm = ChatOpenAI(model="gpt-4o")

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a sales assistant. Look up customer information and send personalized emails."),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}")
])

agent = create_tool_calling_agent(llm, tools, prompt)
executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
executor.invoke({"input": "Look up John's info, then send him a thank-you email."})
```

#### Day 5: LangGraph (Advanced Agent Framework)

Why learn this: complex B2B projects require multi-step, conditional-branch agent workflows.

Learn only the core concepts: State, Node, Edge

Resource: LangGraph official Quickstart (langchain-ai.github.io/langgraph)

#### Day 6–7: Week 3 Project (Portfolio #2)

**Project: AI Sales Lead Processing Agent**
- Input: one new lead (company name, contact, need description)
- Agent automatically:
  1. Scores lead quality (1–10)
  2. Researches the company (using DuckDuckGo Search Tool)
  3. Generates a personalized first outreach email
  4. Outputs a structured report

---

### Week 4: n8n No-Code Automation (Essential B2B Tool)

**Goal: Build enterprise-grade automated workflows with n8n for fast project delivery**

> Many local small businesses have limited budgets. n8n lets you deliver quickly without writing code for everything — extremely high value-for-effort.

#### Day 1–2: Install n8n and Learn the Basics

Installation options:
- Local: `npx n8n` or via Docker
- Sign up for n8n Cloud free trial (recommended)

Core concept: Trigger → Node (processing) → Action

Practice:
- Every morning at 9am, automatically send yourself a weather email
- When a new row is added to Google Sheets, send an email or notification

#### Day 3–4: Connect AI to n8n

Use the OpenAI node in n8n to build this workflow:

```
Customer fills out a form (Typeform / Google Forms)
  → n8n triggers
  → OpenAI analyzes the customer's needs
  → Auto-generates a reply email
  → Sends email (Gmail node)
  → Logs to Google Sheets
```

#### Day 5: n8n + Webhook + CRM

- Learn the Webhook node (key for B2B integrations)
- Practice: when a new CRM contact is added → AI auto-tags and classifies them

#### Day 6–7: Week 4 Project (Portfolio #3)

**Project: Fully Automated Lead Follow-Up Workflow**
- Trigger: new lead submits a form
- Step 1: AI analyzes the lead → decides if they are a target customer
- Step 2: Target customer → send personalized email + log to CRM
- Step 3: Not a target → send polite decline email
- Step 4: No reply in 3 days → auto-send follow-up email
- Record a Loom video demo ✅

---

## Month 2: Advanced Practice (Week 5–8)

---

### Week 5: API Integration + FastAPI Deployment

**Goal: Deploy AI features as an online service that client systems can call directly**

#### Day 1–2: REST API Basics

- Understand GET / POST / PUT / DELETE
- Understand JSON data format
- Understand API key authentication
- Tool: use Postman to test various APIs

#### Day 3–4: FastAPI Quick Start

Install: `pip install fastapi uvicorn`
Run: `uvicorn main:app --reload`

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
            {"role": "system", "content": f"You are the dedicated support assistant for {request.company_id}."},
            {"role": "user", "content": request.question}
        ]
    )
    return {"answer": response.choices[0].message.content}
```

#### Day 5: Deploy to Production

- Sign up for Railway (railway.app) or Render (render.com) — free tier is enough
- Deploy the FastAPI project and get a real HTTPS URL
- You can then tell clients: "Just call this endpoint from your system."

#### Day 6–7: Week 5 Project (Portfolio #4)

**Project: Company Knowledge Base API Service**
- Wrap the Week 2 RAG project as an API
- Endpoint: `POST /ask` → input a question → return answer + source paragraphs
- Deploy and get a live URL ✅

---

### Week 6: Mainstream B2B Tool Integrations

**Goal: Integrate with common enterprise tools (CRM / messaging / document systems)**

#### Day 1–2: CRM API Integration

Using HubSpot as an example (free tier available):

```python
import requests

HUBSPOT_TOKEN = "your-token"
headers = {"Authorization": f"Bearer {HUBSPOT_TOKEN}"}

data = {
    "properties": {
        "email": "test@example.com",
        "firstname": "John",
        "lastname": "Doe",
        "company": "ABC Corp"
    }
}
requests.post(
    "https://api.hubapi.com/crm/v3/objects/contacts",
    json=data,
    headers=headers
)
```

Common operations: get contact list / create contact / update properties / create a Deal

#### Day 3: Enterprise Messaging Integration

- Slack / Teams Webhook: push a message to a channel when AI completes a task
- Practice: n8n scheduled job → AI generates a daily report → posts to a Slack channel

#### Day 4: Notion / Airtable API

- Learn to read and write document databases
- Common use case: AI processes content, then automatically writes to an Airtable base

#### Day 5–7: Week 6 Integrated Project (Portfolio #5)

**Project: AI Sales Daily Report Automation**
- Triggers at end of each workday (n8n scheduled job)
- Pulls all sales activity for the day from CRM
- AI generates a sales report (deals closed, follow-up recommendations)
- Posts to a Slack channel
- Also writes to an Airtable base for archiving

> This is the project closest to real local business needs — it demos extremely well.

---

### Week 7: Voice AI Agent (High-Value Direction)

**Goal: Build enterprise phone / voice AI systems**

> Voice AI is one of the highest-ticket B2B directions. Local businesses (restaurants, clinics, salons) have strong demand — a single project can fetch $1,000–$5,000+.

#### Day 1–2: VAPI Platform Basics

Sign up at VAPI.ai and understand the overall architecture:

```
Incoming call
  → VAPI converts to text (STT)
  → Sends to LLM
  → LLM generates a reply
  → Converts reply to speech (TTS)
  → Continues conversation
```

Create your first voice agent in the VAPI console and configure:
- System Prompt (role / personality)
- Opening greeting
- End-call conditions

#### Day 3–4: VAPI Advanced Configuration

Functions (tool calling): AI queries a database or CRM in real time during a call

Example conversation flow:
```
AI: Hi, could you give me your order number?
User: 123456
AI: (calls lookup tool) Your order will arrive tomorrow afternoon. Please be available to receive it.
```

Configuration options:
- End Call conditions (when to hang up)
- Voicemail detection (leave a message if unanswered)
- Voice selection (tone / speed / language)

#### Day 5: VAPI + n8n Integration

```
Call ends
  → VAPI sends Webhook to n8n
  → n8n automatically:
      Saves call summary
      Updates CRM contact
      Sends Slack notification to sales team
```

#### Day 6–7: Week 7 Project (Portfolio #6)

**Project: AI Appointment Reception Voice Bot**
- Function: answer customer calls → understand appointment needs → check available times → confirm booking → send SMS confirmation
- Target clients: clinics, beauty salons, restaurants, law firms
- Record a demo video (use VAPI's test feature to call yourself) ✅

---

### Week 8: Portfolio Polish + Local Client Outreach

**Goal: Have all materials ready and start contacting local small businesses to land the first paying client**

#### Day 1–2: Organize Your Portfolio

You now have 6 projects:

| # | Project Name | Core Skills Demonstrated |
|---|---|---|
| 1 | Company Knowledge Base Q&A System | RAG / LangChain |
| 2 | AI Sales Lead Processing Agent | Tool-calling Agent |
| 3 | Fully Automated Lead Follow-Up | n8n Automation |
| 4 | Knowledge Base API Service | FastAPI / Deployment |
| 5 | AI Sales Daily Report Automation | Multi-system Integration |
| 6 | AI Appointment Reception Voice Bot | Voice AI |

For each project, prepare:
- A 2–3 minute screen recording demo (OBS or Loom)
- Screenshots + flow diagrams in the GitHub README
- One sentence summarizing business value (written for a business owner, not a developer)
  - Bad: "Built a RAG system using LangChain"
  - Good: "Lets employees ask AI to find company documents instantly, saving 2 hours of manual searching per day"

#### Day 3–4: Prepare Client-Facing Materials

**One-page introduction (for business owners)**

```
Title: Using AI to Automate Your Business's Daily Work

What I can do for you:
• AI Customer Service: 24/7 automatic replies, no human needed
• Lead Automation: New contacts auto-logged, categorized, and followed up
• Voice Reception Bot: Automatically answers calls, books appointments, handles queries
• Internal Knowledge Base: Staff ask AI directly instead of flipping through manuals

How we work together:
• Fixed-price per project, delivered by feature — not hourly billing
• Free demo first; pay only when you're satisfied
• 1 month of free maintenance included

Contact: [your email / phone]
```

**Pricing reference (local business rates)**

| Project Type | Suggested Price | Delivery Time |
|---|---|---|
| Simple n8n automation (e.g., lead follow-up) | $300–$700 | 3–5 days |
| AI customer service knowledge base | $700–$1,800 | 1–2 weeks |
| Custom AI Agent | $1,200–$3,000 | 2–3 weeks |
| Voice appointment bot | $1,500–$5,000 | 2–4 weeks |

> For your first 2–3 clients, offer a discount to get case studies and referrals — then return to full pricing.

#### Day 5–7: Start Reaching Out to Local Businesses

**Ideal client profile (easiest to close)**

Prioritize these business types:
- **Clinics / dental offices / beauty salons**: high volume of repetitive phone calls, great fit for voice bots
- **Small law firms**: need AI to search internal case document libraries
- **Local retail / chain stores**: need automated lead follow-up and customer management
- **Education / tutoring centers**: need AI to answer course inquiries and send materials automatically
- **Local software companies**: need to add AI features to their existing products

**Ways to find clients**

1. **Your network**: ask family and friends if they or anyone they know owns a business
2. **Social media**: post "I help local businesses automate with AI" + demo video
3. **Local business groups / Chambers of Commerce**: join and watch for needs, offer solutions
4. **In-person visits**: bring a laptop, demo the voice bot on the spot — the live effect is striking
5. **TikTok / Instagram / LinkedIn**: post "I built AI automation for [business type]" case study videos (use your practice projects)

**First-meeting script**

```
"I've been helping local businesses automate repetitive work with AI —
things like customer service replies, lead follow-up, and phone reception.
Can we spend a few minutes talking about where your team spends the most manual time?
I can take a look and see if AI can eliminate it —
and I'm happy to do a free demo for you first."
```

**Follow-up cadence**

```
Day 1:  In-person meeting or send demo video
Day 3:  Send one-page intro + simple proposal
Day 7:  Provide a free mini-prototype specific to their problem
Close:  Collect payment, use a simple written agreement
```

---

## Tool Accounts to Register in Advance

| Tool | Purpose | Cost |
|---|---|---|
| OpenAI | LLM API | Pay-as-you-go, $20 is enough to practice |
| n8n Cloud | Automation workflows | Free trial |
| VAPI.ai | Voice AI | Per-minute billing |
| Railway / Render | Project deployment | Free tier |
| HubSpot | CRM practice | Free tier |
| Pinecone | Vector database | Free tier |
| GitHub | Code hosting + portfolio | Free |
| OBS / Loom | Record demo videos | Free |
| Canva | One-page intro document | Free tier |

---

## Core Learning Resources

| Resource | Content | URL |
|---|---|---|
| LangChain Docs | Agent / RAG | python.langchain.com |
| LangGraph Quickstart | Complex Agent workflows | langchain-ai.github.io/langgraph |
| n8n Docs | Automation nodes | docs.n8n.io |
| VAPI Docs | Voice AI | docs.vapi.ai |
| DeepLearning.AI | Free LLM application courses | deeplearning.ai |
| FastAPI Docs | API deployment | fastapi.tiangolo.com |

---

## Daily Time Allocation (2–3 hours/day)

```
First 45 min:  Read docs / watch tutorials (input)
Next 60 min:   Write code / build workflows (practice)
Last 30 min:   Debug / note down questions (reinforce)
Remaining:     Observe local business pain points; think about which project to demo
```

---

## Full Plan at a Glance

| Week | Core Content | Deliverable |
|---|---|---|
| Week 1 | Python + OpenAI API + Prompt Engineering | AI email assistant script |
| Week 2 | LangChain + Memory + RAG | Knowledge base Q&A system (Portfolio #1) |
| Week 3 | AI Agent + Tool Calling + LangGraph | Lead processing agent (Portfolio #2) |
| Week 4 | n8n Automation + AI nodes + Webhooks | Lead follow-up workflow (Portfolio #3) |
| Week 5 | FastAPI + REST API + Cloud deployment | Knowledge base API live (Portfolio #4) |
| Week 6 | CRM / Slack / Airtable integration | Sales daily report automation (Portfolio #5) |
| Week 7 | VAPI Voice AI + post-call automation | Appointment voice bot (Portfolio #6) |
| Week 8 | Portfolio polish + local client outreach | **First paying client** |

---

> **Most important takeaway**: Start organizing your portfolio and reaching out to people in your network after Week 2 — don't wait until you've "finished learning." Working with real clients while you learn is the fastest path to your first sale.

---

*Document created: March 2026*
