// VppaConsentModal.swift
// PBS VPPA Consent Modal — tvOS (SwiftUI) implementation.
//
// Ports component-spec.json using values from tokens.json. The `Tok` enum is the
// hand-written equivalent of what style-dictionary emits (see ../../style-dictionary).
// Match the visual gold standard in ../../vppa-modal.html.
//
// tvOS handles D-pad focus natively via the focus engine: default focus is set with
// `.prefersDefaultFocus`, and the focused-button treatment (ring + scale) is applied
// with `@FocusState`. Blur=Yes uses `.ultraThinMaterial`.

import SwiftUI

// MARK: - Tokens (generated-equivalent; see tokens.json)

enum Tok {
    // color
    static let white       = Color(hex: 0xFFFFFF)
    static let pbsBlue     = Color(hex: 0x2638C4)
    static let surface     = Color(red: 10/255, green: 20/255, blue: 90/255).opacity(0.60)
    static let secFill     = Color.white.opacity(0.10)
    static let disclaimer  = Color(hex: 0xC0CBDA)
    static let focusRing   = Color.white

    // typography
    static let titleFont   = Font.custom("PBS Sans", size: 48).weight(.bold)
    static let bodyFont    = Font.custom("PBS Sans", size: 28)
    static let labelFont   = Font.custom("PBS Sans", size: 32).weight(.bold)
    static let bodyLine: CGFloat = 28 * (1.3 - 1.0)   // lineSpacing = size * (lineHeight - 1)

    // dimension
    static let radiusModal: CGFloat = 24
    static let pill: CGFloat        = 40
    static let padX: CGFloat        = 80
    static let padY: CGFloat        = 60
    static let section: CGFloat     = 40
    static let paragraphGap: CGFloat = 14
    static let buttonGap: CGFloat   = 40
    static let buttonPadX: CGFloat  = 48
    static let contentW: CGFloat    = 946
    static let rowW: CGFloat        = 789
    static let buttonH: CGFloat     = 80

    // effect / focus (focus values are PROPOSED — confirm with design)
    static let shadowRadius: CGFloat = 20
    static let focusScale: CGFloat   = 1.06
    static let focusRingW: CGFloat   = 4
    static let focusRingOffset: CGFloat = 4
    static let focusDuration: Double = 0.15
}

// MARK: - Component

struct VppaConsentModal: View {
    var blur: Bool = true                 // variant: Blur = Yes/No
    var showDisclaimer: Bool = false      // variant: Disclaimer text
    var onAgree: () -> Void = {}
    var onDecline: () -> Void = {}

    private enum Field { case agree, decline }
    @FocusState private var focus: Field?

    private let body1 = "By clicking “Agree” below, you consent under the Video Privacy Protection Act (VPPA) to PBS’s potential sharing of your viewing history and related information with third parties, like its service providers or your local station including to personalize your digital experience and to ensure that our websites and apps function properly. Consent is not required to view our content, but some functionality may be unavailable to you if you decline consent."
    private let body2 = "This VPPA consent is separate from your cookie consent preference and applies only to the viewing information discussed above."
    private let body3 = "You can change your selection at any time by visiting Privacy Settings."

    var body: some View {
        VStack(spacing: Tok.section) {
            // Text block
            VStack(spacing: Tok.section) {
                Text("Your Privacy Matters to Us")
                    .font(Tok.titleFont)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: Tok.paragraphGap) {
                    Text(body1); Text(body2); Text(body3)
                }
                .font(Tok.bodyFont)
                .lineSpacing(Tok.bodyLine)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(Tok.white)
            .frame(maxWidth: Tok.contentW)

            // Buttons
            HStack(spacing: Tok.buttonGap) {
                PillButton(title: "Agree", fill: Tok.white, label: Tok.pbsBlue,
                           isFocused: focus == .agree, action: onAgree)
                    .focused($focus, equals: .agree)
                    .prefersDefaultFocus(in: namespace)     // default focus = Agree

                PillButton(title: "Decline", fill: Tok.secFill, label: Tok.white,
                           isFocused: focus == .decline, action: onDecline)
                    .focused($focus, equals: .decline)
            }
            .frame(maxWidth: Tok.rowW)

            if showDisclaimer {
                Text("A selection is required to continue.")
                    .font(Tok.bodyFont)
                    .foregroundStyle(Tok.disclaimer)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, Tok.padX)
        .padding(.vertical, Tok.padY)
        .background {
            RoundedRectangle(cornerRadius: Tok.radiusModal)
                .fill(Tok.surface)
                .background(blur ? AnyView(BlurView()) : AnyView(Color.clear))   // Blur=Yes
        }
        .clipShape(RoundedRectangle(cornerRadius: Tok.radiusModal))
        .shadow(color: .black.opacity(0.25), radius: Tok.shadowRadius)
        .focusScope(namespace)
    }

    @Namespace private var namespace
}

// MARK: - Pill button

private struct PillButton: View {
    let title: String
    let fill: Color
    let label: Color
    let isFocused: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Tok.labelFont)
                .foregroundStyle(label)
                .frame(maxWidth: .infinity)
                .frame(height: Tok.buttonH)
                .padding(.horizontal, Tok.buttonPadX)
                .background(fill, in: Capsule())
        }
        .buttonStyle(.plain)
        .overlay {                                   // PROPOSED focus ring
            if isFocused {
                Capsule()
                    .strokeBorder(Tok.focusRing, lineWidth: Tok.focusRingW)
                    .padding(-Tok.focusRingOffset)
            }
        }
        .scaleEffect(isFocused ? Tok.focusScale : 1.0)
        .animation(.easeOut(duration: Tok.focusDuration), value: isFocused)
    }
}

// Blur=Yes backing (tvOS)
private struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    }
    func updateUIView(_ v: UIVisualEffectView, context: Context) {}
}

// Hex color helper
extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red:   Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue:  Double(hex & 0xFF) / 255)
    }
}
