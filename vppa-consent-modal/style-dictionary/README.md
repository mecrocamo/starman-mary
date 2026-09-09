# Token build (Style Dictionary)

Generates per-platform constants from [`../tokens.json`](../tokens.json) so every platform
stays in lockstep with one source of truth.

```bash
cd style-dictionary
npm install
npm run build
```

## What it emits (`build/`)

| Output | Consumes | Use it for |
|---|---|---|
| `css/tokens.css` | all primitives (px) | Paste into `vppa-modal.html` `:root` (HTML smart TV). |
| `ios/Colors.swift` | colors → `UIColor` | Replace the color values in the tvOS `Tok` enum. |
| `android/colors.xml` | colors → `<color>` | Compose/XML color resources (Android TV). |
| `json/tokens.flat.json` | **all** tokens (with units) | Neutral machine-readable export for any other tool (incl. Roku tooling). |

The `build/` folder is committed so colleagues can read the generated output without running
the build. Re-run after editing `tokens.json`.

## Why colors generate natively but dimensions don't

**Colors** are unambiguous across platforms, so they are emitted straight to Swift and Android
— the highest-value thing to keep machine-synced.

**Dimensions** are authored at the **OTT 1920 (1080p) px** scale. Each platform applies its own
scale factor to that:

- **HTML smart TV** — used as-is (the `:root` px values; the 1920×1080 stage is scaled to fit).
- **tvOS** — points are ~1:1 with px on 1080p Apple TV HD, so the hand-tuned `Tok` values match.
- **Android TV** — dp depends on the density baseline (commonly `1dp = 2px` on a 1080p TV).
- **Roku** — absolute 1080p px, 1:1.

So dimensions ship in `css/tokens.css` (px) and `json/tokens.flat.json` (raw, with units), and
each native platform keeps its dimension constants hand-tuned in its own file. Feeding one
`XXXdp` number to every platform would be wrong for at least one of them.

Composite **typography** and **shadow** tokens land in `tokens.flat.json` only; each platform
expresses fonts/shadows differently, so they are read from
[`../component-spec.json`](../component-spec.json).
