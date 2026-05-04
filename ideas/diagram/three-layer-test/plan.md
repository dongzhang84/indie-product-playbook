# Plan · Three-Layer Test

## Reader need

> After seeing this diagram, the reader understands what each of the three stages tests, what counts as passing, what failure looks like, and that cross-stage consistency is the deepest signal.

## Type decision

- **Type**: structural (3-container vertical stack, baoyu style)
- Modeled on `chip-ban-three-channels` — 3 stage containers with eyebrow + th + ts on left, divider, body lines on right, right-top accent eyebrow for typical failure mode
- Cross-stage consistency and meta-cognitive check go in the footer captions, not as additional containers (keeps the diagram simple — user feedback was the previous mermaid version was "太复杂")

## Layout math

- viewBox 0 0 680 600
- Title y=42, subtitle y=64
- 3 containers × 125 high × 16 gap, starting y=96:
  - Stage 1: y=96..221
  - Stage 2: y=237..362
  - Stage 3: y=378..503
- Footer:
  - caption-strong y=535 ("The deepest signal is cross-stage consistency.")
  - caption y=557 (per-stage pass vs cross-stage coherence)
  - caption y=579 (meta-cognitive question)
- Buffer 21px → H=600

## Container content

Each container uses left-zone (60-220) for eyebrow / th / ts + right-zone (238-640) for 3 body lines (Input / Task / Pass). Right-top accent shows the typical failure mode in 15-character coral text.

| Stage | Failure accent | Notes |
|---|---|---|
| 1 Induction | → slips to F=ma | violates "no modern physics" instruction |
| 2 Formulation | → premise drift | smuggles in contradictions while formalizing |
| 3 Prediction | → leaks intuition | predicts using real-physics priors not stated laws |

## Color usage

- All 3 containers gray (`.layer`) — equal weight
- Coral accent only on right-top eyebrow text (one per container)
- No `.layer-key` highlight; cross-stage emphasis goes in the footer prose
