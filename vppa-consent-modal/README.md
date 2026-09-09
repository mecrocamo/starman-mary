# VPPA Consent Modal — Cross-Platform TV Package

A one-source-of-truth implementation of the PBS **VPPA (Video Privacy Protection Act)
consent modal** — CTV variant — built so it can be applied across HTML smart TVs,
tvOS, Android TV, and Roku without redrawing the design four times.

**Source:** [Figma · Apps Design System, node 3692-42209](https://www.figma.com/design/VVoljCt5vEbj0qCSLv2SgY/Apps-Design-System?node-id=3692-42209)

> The modal is a dark translucent panel over a blurred backdrop: a centered title
> "Your Privacy Matters to Us", three paragraphs of legal body copy, and a row with a
> white **Agree** pill (PBS-blue label) and a translucent **Decline** pill. Open
> `vppa-modal.html` to see it live.

## Why this shape

The four target platforms share no common runtime language — HTML/CSS, Swift/SwiftUI,
Kotlin/Compose, and BrightScript/SceneGraph are all different. So the portable
"language" here is **the design itself, expressed as data**:

- **`tokens.json`** — every color, type style, dimension, and effect as
  [W3C Design Token](https://tr.designtokens.org/format/) values. The single source of
  truth. Feed it to Style Dictionary (or read it directly) to generate per-platform
  constants.
- **`component-spec.json`** — the structure, content, states, and D-pad behavior,
  described independently of any framework and bound to token names.
- **`vppa-modal.html`** — the runnable reference: the real implementation for HTML
  smart TVs **and** the visual gold standard everyone else matches. Open it in a
  browser; use ← → to move focus, Enter to select, Esc to dismiss.
- **`PORTING.md`** — how tokens + spec map to native primitives on each platform, with
  a starter snippet for tvOS, Android TV, and Roku.

## Files

| File | Role |
|---|---|
| `tokens.json` | Design tokens (source of truth) |
| `component-spec.json` | Structure, states, behavior |
| `vppa-modal.html` | Runnable HTML-TV reference + visual gold standard |
| `PORTING.md` | tvOS / Android TV / Roku mapping + snippets |

## How to use it

1. **Change a value once** in `tokens.json` (e.g. a color or size).
2. Regenerate per-platform constants (Style Dictionary, or by hand from the table in
   `PORTING.md`).
3. Each platform re-reads its constants — the design stays in lockstep everywhere.

## Two things to confirm with design

Both are called out inline in `tokens.json` and `PORTING.md`:

1. **Focus state** — the provided Figma node doesn't specify a D-pad focus appearance,
   so the package uses a proposed default (white ring + 1.06 scale). TV apps require a
   focus state; confirm against the design system's focus tokens.
2. **Button normalization** — Figma authored Agree and Decline as two instances with
   slightly different height/size/radius/padding. The component uses one shared button
   geometry so the pair matches. Confirm that's intended.

## Notes

- **Font:** the design uses *PBS Sans*; bundle it per platform. The HTML falls back to
  Helvetica/Arial where it isn't loaded.
- **Blur:** the CTV `Blur=Yes` variant blurs the backdrop. Roku can't blur — use
  `Blur=No` (opaque panel) there, and on any firmware without backdrop-blur support.
- **Scale:** everything is authored at OTT 1920 (1080p). The HTML scales its
  1920×1080 stage to any viewport.
