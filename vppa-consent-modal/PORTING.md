# VPPA Consent Modal — Porting Guide

One design, four TV platforms. `tokens.json` (the values) and `component-spec.json`
(the structure and behavior) are the **single source of truth**. This guide shows how
each platform maps those two files to native primitives. `vppa-modal.html` is the
runnable reference and the visual gold standard — match it.

Author scale is **OTT 1920** (1920×1080, 10-foot UI). Every dimension token is in
1080p design pixels. Scale to the device's render resolution (most TV surfaces
render a 1920×1080 or 1280×720 canvas and letterbox/upscale to the panel).

---

## 1. What every platform must reproduce

| Element | Token(s) | Notes |
|---|---|---|
| Modal panel | `color.surface.modal`, `dimension.radius.modal`, `padding.modalX/Y`, `effect.shadow.modal` | Translucent dark-blue panel over a blurred backdrop. |
| Backdrop blur | `effect.blur.backdrop` (`Blur=Yes`) | Turn **off** where unsupported (Roku) → `Blur=No`. |
| Title | `typography.title`, `color.text.onSurface` | Centered, single line: "Your Privacy Matters to Us". |
| Body | `typography.body`, `color.text.onSurface`, `space.paragraphGap` | Left-aligned, 3 paragraphs. |
| Agree (primary) | `color.primary.white` fill, `color.primary.pbsBlue` label | Default focus. |
| Decline (secondary) | `color.button.secondaryFill` fill, `color.primary.white` label | |
| Button geometry | `size.buttonHeight`, `radius.pill`, `padding.buttonX`, `typography.buttonLabel` | Both buttons identical geometry; flex to equal width. |
| Focus (D-pad) | `color.focus.ring`, `motion.focus.*` | **Proposed** spec — see §6. |

**Spacing:** `space.sectionGap` (40) between title, body, and button row.
**Content width:** `size.contentWidth` (946) caps the column; `size.buttonRowWidth` (789) caps the button row.

---

## 2. HTML smart TV (Tizen / webOS / Vizio / Comcast)

Already implemented — `vppa-modal.html`. Tokens become CSS custom properties in
`:root`; the 1920×1080 stage is scaled with `transform: scale()`. D-pad is handled
in the keydown listener (arrow keys + Enter/Back). Ship as-is, or generate the
`:root` block from `tokens.json` with your build (e.g. Style Dictionary).

- **Font:** bundle *PBS Sans* as a web font; the stack falls back to Helvetica/Arial.
- **Blur:** `backdrop-filter: blur(15px)`. Confirm on target firmware; fall back to
  `Blur=No` (opaque panel) on older WebKit that lacks `backdrop-filter`.

---

## 3. tvOS (SwiftUI)

> Full implementation: [`platforms/tvos/VppaConsentModal.swift`](platforms/tvos/VppaConsentModal.swift).
> Generated color constants: `style-dictionary/build/ios/Colors.swift`.

Map tokens to a `Tokens` enum; SwiftUI's focus engine handles D-pad natively.

```swift
enum T {
    static let white   = Color(hex: 0xFFFFFF)
    static let pbsBlue  = Color(hex: 0x2638C4)
    static let surface  = Color(red: 10/255, green: 20/255, blue: 90/255).opacity(0.60)
    static let secFill  = Color.white.opacity(0.10)
    static let radiusModal: CGFloat = 24, pill: CGFloat = 40
    static let padX: CGFloat = 80, padY: CGFloat = 60, section: CGFloat = 40
    static let btnH: CGFloat = 80, contentW: CGFloat = 946, rowW: CGFloat = 789
}

struct VppaConsentModal: View {
    var onAgree: () -> Void, onDecline: () -> Void
    var body: some View {
        VStack(spacing: T.section) {
            VStack(spacing: T.section) {
                Text("Your Privacy Matters to Us")
                    .font(.custom("PBS Sans", size: 48)).bold()
                Text(bodyCopy)                       // 3 paragraphs joined by "\n\n"
                    .font(.custom("PBS Sans", size: 28))
                    .lineSpacing(28 * 0.3).multilineTextAlignment(.leading)
            }
            .foregroundStyle(T.white).frame(maxWidth: T.contentW)

            HStack(spacing: T.section) {
                PillButton("Agree",   fill: T.white,   label: T.pbsBlue, action: onAgree)
                PillButton("Decline", fill: T.secFill, label: T.white,   action: onDecline)
            }
            .frame(maxWidth: T.rowW)
        }
        .padding(.horizontal, T.padX).padding(.vertical, T.padY)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: T.radiusModal)) // Blur=Yes
        .background(T.surface, in: RoundedRectangle(cornerRadius: T.radiusModal))
        .shadow(color: .black.opacity(0.25), radius: 20)
    }
}
```

- **Focus:** SwiftUI gives focus for free. Use `.prefersDefaultFocus(in:)` on the
  Agree button so it is focused first; add `@FocusState` if you need to read it. Match
  the proposed ring/scale in §6 with `.scaleEffect` + an overlay stroke keyed on focus.
- **Blur=Yes:** `.ultraThinMaterial` behind the surface color. For `Blur=No`, drop the
  material layer and raise the panel opacity.

---

## 4. Android TV (Jetpack Compose for TV)

> Full implementation: [`platforms/android-tv/VppaConsentModal.kt`](platforms/android-tv/VppaConsentModal.kt).
> Generated color resources: `style-dictionary/build/android/colors.xml`.

Use `androidx.tv.material3`. Author in `.dp` at the 1080p scale (Android scales dp for you).

```kotlin
object T {
    val White = Color(0xFFFFFFFF); val PbsBlue = Color(0xFF2638C4)
    val Surface = Color(0xFF0A145A).copy(alpha = 0.60f)
    val SecFill = Color.White.copy(alpha = 0.10f)
    val RadiusModal = 24.dp; val Pill = 40.dp
    val PadX = 80.dp; val PadY = 60.dp; val Section = 40.dp
    val BtnH = 80.dp; val ContentW = 946.dp; val RowW = 789.dp
}

@Composable fun VppaConsentModal(onAgree: () -> Unit, onDecline: () -> Unit) {
    val agree = remember { FocusRequester() }
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(T.Section),
        modifier = Modifier
            .clip(RoundedRectangle(T.RadiusModal))   // + RenderEffect.blur behind for Blur=Yes (API 31+)
            .background(T.Surface)
            .padding(horizontal = T.PadX, vertical = T.PadY)
    ) {
        Text("Your Privacy Matters to Us", color = T.White,
             fontFamily = PbsSans, fontWeight = FontWeight.Bold, fontSize = 48.sp)
        Text(bodyCopy, color = T.White, fontFamily = PbsSans, fontSize = 28.sp,
             lineHeight = (28 * 1.3).sp, textAlign = TextAlign.Start,
             modifier = Modifier.widthIn(max = T.ContentW))
        Row(horizontalArrangement = Arrangement.spacedBy(T.Section),
            modifier = Modifier.widthIn(max = T.RowW)) {
            PillButton("Agree",   T.White,   T.PbsBlue, Modifier.weight(1f).focusRequester(agree), onAgree)
            PillButton("Decline", T.SecFill, T.White,   Modifier.weight(1f), onDecline)
        }
    }
    LaunchedEffect(Unit) { agree.requestFocus() }   // default focus
}
```

- **Focus:** the TV Compose focus system handles D-pad. Request focus on Agree at
  composition. Style the focused state (`Modifier.onFocusChanged`) to match §6.
- **Blur=Yes:** `RenderEffect.createBlurEffect` on a background layer (API 31+).
  Below API 31, use `Blur=No` (opaque panel).

---

## 5. Roku (SceneGraph + BrightScript)

> Full implementation: [`platforms/roku/VppaConsentModal.xml`](platforms/roku/VppaConsentModal.xml)
> + [`platforms/roku/VppaConsentModal.brs`](platforms/roku/VppaConsentModal.brs).

Roku has **no backdrop blur** → always render **`Blur=No`** (opaque panel). Build the
tree in a component's `<children>` XML; drive focus in BrightScript. Roku positions in
absolute 1080p pixels, so the design tokens map directly. Roku label fonts need a
registered font; register *PBS Sans* (`font:RegistrationURI`) or fall back to the
system font at the token sizes.

```xml
<!-- VppaConsentModal.xml -->
<component name="VppaConsentModal" extends="Group">
  <children>
    <Rectangle id="panel" color="0x141E5AFF" width="1106" height="684"
               translation="[407,198]"> <!-- centered on 1920x1080; radius via 9-patch below -->
      <Poster id="panelBg" uri="pkg:/images/panel_r24.9.png" width="1106" height="684"/>
      <Label id="title" text="Your Privacy Matters to Us" color="0xFFFFFFFF"
             width="946" horizAlign="center" translation="[80,60]"
             font="font:BoldSystemFont" /> <!-- size 48 via a Font node -->
      <Label id="body" wrap="true" color="0xFFFFFFFF" width="946"
             translation="[80,153]" /> <!-- size 28, 3 paragraphs joined with newlines -->
      <Group id="buttons" translation="[158,544]">
        <Group id="agree"   role="button"/>   <!-- white pill,  blue label -->
        <Group id="decline" role="button"/>   <!-- 10% white pill, white label -->
      </Group>
    </Rectangle>
  </children>
</component>
```

```brightscript
' focus + D-pad (init sets Agree focused; onKeyEvent moves left/right)
sub init()
    m.buttons = ["agree","decline"] : m.idx = 0
    setFocus(0)
end sub
function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    if key = "right" and m.idx < 1 then m.idx = m.idx + 1 : setFocus(m.idx) : return true
    if key = "left"  and m.idx > 0 then m.idx = m.idx - 1 : setFocus(m.idx) : return true
    if key = "OK" then activate(m.idx) : return true
    return false
end function
```

- **Pill shape:** Roku `Rectangle` has no corner radius — use a **9-patch `Poster`**
  (`.9.png`) for each pill and the panel, one per fill color.
- **Focus:** no automatic ring — draw it. Swap the focused pill's `Poster` to a
  ring/scaled variant, or animate `scale` with an `Animation` node to match §6.
- **Colors** are `0xRRGGBBAA`: surface `0x141E5A99` if you keep translucency, else the
  opaque `Blur=No` value; secondary fill `0xFFFFFF1A`.

---

## 6. Focus state (proposed — needs design confirmation)

The provided Figma node does not define a focus appearance, but every TV platform
requires a clear focused state for D-pad. The reference uses this default; confirm it
against the design system's focus tokens before shipping:

| Property | Token | Value |
|---|---|---|
| Ring color | `color.focus.ring` | `#FFFFFF` (offset ring reads on both button fills over the dark panel) |
| Ring width | `motion.focus.ringWidth` | `4px` |
| Ring offset | `motion.focus.ringOffset` | `4px` |
| Scale | `motion.focus.scale` | `1.06` |
| Transition | `motion.focus.duration` | `150ms` |

Default focus = **Agree**. Single row → Up/Down are no-ops; Left/Right move without
wrapping. Trap focus in the modal; restore focus to the invoking element on close.

---

## 7. Normalization decisions (flagged for design review)

The Figma placed the two buttons as separate instances with slightly different specs.
The component collapses them to one button geometry so the pair matches:

| Property | Figma (Agree / Decline) | Component |
|---|---|---|
| Height | 80 / 74 | **80** |
| Label size | 32 / 30 | **32** (`typography.buttonLabel`) |
| Corner radius | 79 / 72 | **40** (full pill, identical) |
| Horizontal padding | 71 / 65 | **48** (buttons flex to equal width) |

If design intends the two buttons to differ, update `tokens.json` /
`component-spec.json` and this table together.
