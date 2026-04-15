# Doppelgang - Product Proposal

## One-liner

Distill real customers into AI sparring partners. Sales reps practice against AI customers that have hidden goals, emotional state, and adaptive difficulty — then get multi-dimensional coaching feedback.

---

## Problem

B2B sales training is broken:

- **New rep ramp-up is slow** — 6-12 months from hire to independently running big-customer negotiations, paid in blown deals.
- **Tacit knowledge doesn't transfer** — senior reps' gut feel about customers ("he says budget's tight but he's just testing you") never makes it into SOPs.
- **Role-play training is expensive and rare** — external coaches cost thousands per session, happens 2-3 times a year. Daily practice happens in live deals at real dollar cost.
- **CRM handoffs lose the customer** — when a rep quits, the replacement gets CRM notes but knows nothing about the customer's decision style, red lines, or internal politics.
- **Generic AI assistants are too compliant** — ChatGPT "playing a difficult customer" won't actually push back, won't have emotional shifts, won't withhold information. Practicing against it teaches nothing.

## Solution

A three-engine product:

1. **Distiller** — raw materials (emails, meeting transcripts, CRM data, rep's verbal description) → structured customer persona card (business profile + 5-layer persona).
2. **Simulator** — scenario-based role-play (discovery / pitch / negotiation / objection handling / contract review / renewal). Customer has hidden goals, emotional state machine, adaptive difficulty. Reps must _dig_ information out, not just receive it.
3. **Coach** — multi-agent evaluation with dimension scoring (needs discovery / objection handling / value articulation / active listening / pace / trust). Shows what was revealed vs. missed, with concrete improvement suggestions.

Plus: **archetype library** (8-10 pre-built customer types), **correction layer** (coaches annotate "this customer wouldn't react that way" and it takes effect immediately), **evolution** (append new materials / record deal outcomes to refine the persona over time).

## Target Users

- **Primary**: B2B sales reps (new hires ramping up, experienced reps prepping for big meetings)
- **Primary**: Sales managers / trainers (team capability building, onboarding programs)
- **Secondary**: Sales engineers, customer success managers, product marketing

## Differentiation

| vs | Diff |
|----|------|
| Gong / Chorus | They analyze real calls post-hoc. We simulate before the call. |
| Second Nature / Rehearsal | Their customers are template configurations. Ours are distilled from real customer data. |
| ChatGPT role-play | No persistence, no hidden goals, no emotional state, no structured feedback. |
| External role-play coaches | $$$, 2-3x/year. We're 24/7 and repeatable. |
| Senior rep mentorship | Depends on individual willingness. We capture tacit knowledge in the Correction layer. |

## Technical Approach

- Next.js 16 + Supabase (Auth + Postgres + Storage) + Prisma v7
- Anthropic Claude API via `lib/llm/` abstraction
- Heavy reuse of `colleague-skill`'s prompt templates and 5-layer persona architecture (fork and remap, don't rewrite)
- See [`docs/technical_spec.md`](https://github.com/dongzhang84/doppelgang/blob/main/docs/technical_spec.md) in the repo for the full implementation guide

## Status

**Phase 0 — scaffolding** (2026-04-14)

- Product spec + technical spec written
- Next.js + Supabase + Prisma + Claude SDK skeleton committed and building
- Private repo: https://github.com/dongzhang84/doppelgang

**Next**: Phase 1 — Distiller engine (prompts forked from colleague-skill, adapted for customer domain).

## Sprint Summary

_This section is auto-updated by the sync-from-projects workflow on each push to main._
