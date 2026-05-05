# Plan · AIfy — Product Flow

## Reader need

> After seeing this diagram, the reader understands the entire 4-step product flow (describe → flowchart → 3-tier diagnosis → share/consult), and immediately gets the meaning of the three tiers (🟢 AI does it, 🟡 AI helps, ⚪ you must do it yourself).

## Type decision

- **Type**: flowchart (vertical stacked steps, baoyu style)
- 4 steps stacked top-to-bottom with arrows + caption labels between
- Step 3 (3-tier diagnosis) is the heart of the product → uses `layer-key` accent (the only one in the diagram, per design-system rule "max 1 layer-key per diagram")
- Modeled on `vibe-reading/diagram/product-flow/` (same aesthetic, similar 4-step structure)

## Layout math

- viewBox 680 × 740
- Title y=42, subtitle y=64
- Step 1 (input):       y=100..170 (h=70)
- Step 2 (flowchart):   y=210..310 (h=100)
- Step 3 (diagnosis):   y=350..530 (h=180, layer-key)
- Step 4 (share):       y=570..660 (h=90)
- Footer:               caption-strong y=697, caption y=719
- 3 arrows between steps with mid-caption text
- The arrow into Step 3 uses `arr-accent` (coral) to signal "you've crossed into the value zone"

## Right-corner accent

- Step 3 only: `→ 看清楚谁该做什么`
- This is the punchy takeaway — what makes AIfy different from "more AI tools"

## Tier visualization inside Step 3

Three text rows with circle emoji as tier markers:

- 🟢 AI 替你做 — 你只需要 review 结果
- 🟡 AI 帮你做 — 你定方向、AI 跑细节（human in the loop）
- ⚪ 你必须自己做 — 这部分是判断 / 关系 / 品味，不该外包

The emojis carry color semantics without violating the "≤ 2 accent ramp" rule (they render as full-color via the system font, not via SVG fill). Coral `layer-key` background on the container makes the tiers feel "highlighted" without drawing focus away from the labels themselves.

## Footer punchline

> AI 提效不是"全部交给 AI"，而是"分清楚哪些不该交"。
> AIfy 的产品价值是这个区分本身——一份让人愿意分享出去的清单。

This is the philosophy hook — what the reader walks away repeating.
