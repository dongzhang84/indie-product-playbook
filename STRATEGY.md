# Strategy — New Project Direction

*Last updated: 2026-04-21*
*Status: Current source of truth*
*Supersedes: [strategy-2026-early.md](./strategy-2026-early.md)*

---

## 0. Context: Why this document exists

I've spent the past 5 weeks shipping 6 products with 0 paying users. After a long discussion, I realized the failures weren't technical—they were strategic. This document captures the new direction I want to take, so that Claude Code (and any future AI collaborator) understands the "why" behind what I'm building, not just the "what".

---

## 1. My background (context for any collaborator)

- PhD in Astrophysics, Nanjing University (first in class, physics honors program)
- AI Applied Scientist at Amazon (current or recent)
- Transitioning to independent developer
- Based in Seattle
- Writes in Chinese and English
- Target audience for my work: Chinese-speaking tech community (X, Jike, Xiaohongshu, Zhihu)

This background is my most unique asset in the Chinese AI indie dev community. I've been under-using it.

---

## 2. The long-term vision

**Build a large company in the "AI + human cognition augmentation" space.**

Not a personal brand. Not a lifestyle business. Not a reputation play. The goal is a real company.

But the long-term vision does **not** dictate short-term actions. Startup-stage moves look very different from scale-stage moves.

---

## 3. The framework I'm adopting (inspired by Guo Yu / turingou)

Two parallel product tracks, same as Guo Yu's model:

### Track A: For Human (my personal experiment ground)

- Each product comes from a real pain point I personally experience
- **Ship cadence: 1 day for MVP, 3-day buffer max.** Vibe coding + existing `stack/new-project.sh` pipeline makes this realistic. The real time cost is **distribution** (self-use + friends + content), not the build.
- Expect most of them to not "blow up"—that's fine
- Purpose: each For Human product feeds the next track

### Track B: For Agents (the real commercial asset)

- Extracted from real friction encountered while building For Human products
- NOT pre-designed—let it emerge naturally
- Target market: infrastructure for "cognition-oriented AI products"
- This is the layer that could eventually become a large company

**Critical rule: Never try to jump directly to Track B without Track A experience. The shovel needs to come from having dug real holes.**

---

## 4. Current state of products

### Active
- **Vibe Reading** (web app, in development)
  - MVP spec already written (separate document)
  - For my own use first, potentially public later
  - Philosophy: AI doesn't summarize books—it checks my understanding

- **Vibe Writing** (Claude Skill, self-use only)
  - Not planning to ship as a public web app
  - Exists as a Claude Skill for my personal writing workflow

### Philosophy shared across all Vibe X products

1. **I (the Thinker) am outside the system. The system is a tool.**
2. **Tools can be outsourced. Thinking cannot.**
3. **AI's job: compression-check, error-finding, structured briefing.**
4. **My job: judgment, decisions, forming opinions.**

---

## 5. Key lessons from recent experience

### Lesson 1: My past 5 weeks failed for the same reason each time

All 6 previous products targeted **niche / vertical / B2B** markets where:
- I was not the user
- I had no network in the target space
- Distribution required cold outreach (which doesn't scale for a solo founder)

**Never again.** If I'm not the user, and I don't have a 0.5-degree connection into the market, don't build it.

### Lesson 2: Follower count is the prerequisite, not the consequence

Guo Yu can ship 13 products and have them get attention because he has 167K followers—each failed product still gets real user feedback. I have 0 followers, so each failed product is an isolated failure with no learning signal.

**No sample size = no learning. I have to build the audience in parallel with building products.**

### Lesson 3: "Cold start" is a myth

Every successful indie I've looked at had some network advantage:
- Guo Yu: ByteDance alumni network + Japanese Chinese community + 6 years of content
- Clara J (a paid-social-group case I analyzed): paid into a ¥499 Discord growth program
- Yu Bo / YouMind: Alibaba alumni network + Chinese tech KOL circle

**My potential networks (mostly unused):**
- Amazon AI scientist colleagues
- Nanjing University astro alumni (now in academia/industry globally)
- PhD program cohort
- Seattle Chinese tech scene

I need to activate at least one of these.

### Lesson 4: Shovel logic = friction → automation

The rule Guo Yu's 6 for-agents products follow:
> "Notice what steps still require manual work while building For Human products, then automate them—that automation is the shovel you sell."

This is NOT: "plan a list of shovels and build them."
This IS: "build products, log friction, extract shovels from real friction."

### Lesson 5: Speed > Perfection in vibe coding era

Traditional startup: "All in on one product for 5 years."
Vibe coding era: "Ship 20 products, keep the 2 that land."

Expected hit rate: 1/10 to 2/10. Don't over-invest in any single For Human product.

---

## 6. What I'm actively rejecting

Written down to prevent myself from drifting back:

- ❌ Niche B2B products (past 5 weeks' failure mode)
- ❌ Vibe Decision as the next For Human (looked good on paper, doesn't survive scrutiny—decision-making is too emotional/social to productize)
- ❌ Directly going for "shovel company" without For Human experience
- ❌ Using the long-term vision ("billion-dollar company") to guide week-1 actions
- ❌ Synthetic follower growth via paid "互推 groups"—low-quality followers with no real conversion potential
- ❌ Planning multiple products at once before shipping the first

---

## 7. 3-month action plan

### Priority 1: Ship Vibe Reading MVP

- Complete the web app based on existing product spec
- Use it myself weekly
- Get 3-5 real friends to try it
- Log both user-side pain and developer-side friction throughout

### Priority 2: Start public presence (non-negotiable)

- Pick one primary platform (likely X Chinese community + Jike)
- Use real identity: PhD + Amazon AI scientist + indie dev
- Post daily (at least 1 substantive tweet)
- Content theme: vibe coding practice, Vibe OS philosophy, Vibe Reading build-in-public
- Target (3 months): 300-500 real followers from my natural circle
- Target (6 months): 1000-2000 followers, starting to attract strangers

### Priority 3: Maintain a "friction log"

Two types of logs, kept from day 1:

1. **User-side log**: What confuses me or friends when using Vibe Reading
2. **Developer-side log**: What I end up doing manually, what AI fails at, what I rebuild from scratch

These logs are the seed for future For Agents products.

### Priority 4: Don't plan the next For Human yet

The next For Human will emerge from either:
- A new pain point I encounter while using Vibe Reading daily
- A pattern I notice in the friction log

**Do NOT try to decide it in advance.**

---

## 8. Success metrics (3-month)

**Included:**
- ✅ Vibe Reading MVP is live and I use it weekly
- ✅ 300-500 real X/Jike followers
- ✅ 30+ friction log entries accumulated
- ✅ 3-5 real users have tried Vibe Reading with recorded feedback

**Deliberately excluded:**
- ❌ Paying users (too early, misleading metric for 3 months)
- ❌ MRR/ARR (same reason)
- ❌ Number of products built (quality over quantity at this stage)

---

## 9. Open questions I'm still working through

These are things I haven't decided yet. Claude Code should be aware these are unresolved:

1. **Which public platform to start with?** X Chinese community? Jike? Both?
2. **Whether to use real name or a pseudonym** for the public identity
3. **What content format feels sustainable?** Short tweets? Long-form essays? Thread series?
4. **How to activate the Amazon / Nanjing alumni networks** without feeling pushy
5. **Whether Vibe Reading should eventually be public or stay personal**

---

## 10. What I need from Claude Code

When building Vibe Reading (and future Vibe X products), please:

1. **Respect the philosophy**: Every AI output in the product must serve "compression-check" not "compression-replacement". I'll flag violations.
2. **Help me maintain the friction log**: Remind me to log developer-side friction we encounter, especially places where automation is still needed.
3. **Don't let me scope-creep**: If I start suggesting features that don't serve "AI as error-checker", push back.
4. **Push for ship-ability**: My past failure was over-planning. If something can ship at 70% quality and let me iterate, ship it.
5. **Surface shovel candidates**: When you notice a pattern like "we've written this kind of utility three times now", flag it—that's a potential For Agents extraction.

---

*This document will be updated when:*
- *Vibe Reading MVP ships*
- *Any major strategic shift happens*
- *3 months from today (2026-07-21) as a regular checkpoint*
