// VppaConsentModal.kt
// PBS VPPA Consent Modal — Android TV (Jetpack Compose for TV).
//
// Ports component-spec.json using values from tokens.json. The `Tok` object is the
// hand-written equivalent of what style-dictionary emits (see ../../style-dictionary).
// Match the visual gold standard in ../../vppa-modal.html.
//
// Depends on androidx.tv:tv-material3. The TV focus system drives D-pad; default focus
// is requested on Agree at composition, and the focused-button treatment (ring + scale)
// is applied via onFocusChanged. Blur=Yes uses RenderEffect.blur (API 31+); below that,
// fall back to Blur=No (opaque panel).

package org.pbs.tv.vppa

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.focus.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.material3.Text

// PBS Sans must be registered as a FontFamily; falls back to sans-serif until then.
private val PbsSans = FontFamily.SansSerif

// Tokens (generated-equivalent; see tokens.json)
object Tok {
    val White = Color(0xFFFFFFFF)
    val PbsBlue = Color(0xFF2638C4)
    val Surface = Color(0xFF0A145A).copy(alpha = 0.60f)
    val SecFill = Color.White.copy(alpha = 0.10f)
    val Disclaimer = Color(0xFFC0CBDA)
    val FocusRing = Color.White

    val RadiusModal = 24.dp
    val Pill = 40.dp
    val PadX = 80.dp; val PadY = 60.dp
    val Section = 40.dp; val ParagraphGap = 14.dp; val ButtonGap = 40.dp
    val ButtonPadX = 48.dp
    val ContentW = 946.dp; val RowW = 789.dp; val ButtonH = 80.dp

    // focus values are PROPOSED — confirm with design
    const val FocusScale = 1.06f
    val FocusRingW = 4.dp
}

private const val BODY1 = "By clicking “Agree” below, you consent under the Video Privacy Protection Act (VPPA) to PBS’s potential sharing of your viewing history and related information with third parties, like its service providers or your local station including to personalize your digital experience and to ensure that our websites and apps function properly. Consent is not required to view our content, but some functionality may be unavailable to you if you decline consent."
private const val BODY2 = "This VPPA consent is separate from your cookie consent preference and applies only to the viewing information discussed above."
private const val BODY3 = "You can change your selection at any time by visiting Privacy Settings."

@Composable
fun VppaConsentModal(
    blur: Boolean = true,               // variant: Blur = Yes/No (needs a RenderEffect layer behind; see note)
    showDisclaimer: Boolean = false,    // variant: Disclaimer text
    onAgree: () -> Unit = {},
    onDecline: () -> Unit = {},
) {
    val agree = remember { FocusRequester() }

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(Tok.Section),
        modifier = Modifier
            .clip(RoundedCornerShape(Tok.RadiusModal))
            .background(Tok.Surface)   // draw the blurred backdrop on a layer *behind* this Column for Blur=Yes
            .padding(horizontal = Tok.PadX, vertical = Tok.PadY),
    ) {
        // Text block
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(Tok.Section),
            modifier = Modifier.widthIn(max = Tok.ContentW),
        ) {
            Text(
                "Your Privacy Matters to Us",
                color = Tok.White, fontFamily = PbsSans, fontWeight = FontWeight.Bold,
                fontSize = 48.sp, textAlign = TextAlign.Center,
            )
            Column(verticalArrangement = Arrangement.spacedBy(Tok.ParagraphGap)) {
                listOf(BODY1, BODY2, BODY3).forEach { p ->
                    Text(
                        p, color = Tok.White, fontFamily = PbsSans,
                        fontSize = 28.sp, lineHeight = (28 * 1.3).sp, textAlign = TextAlign.Start,
                    )
                }
            }
        }

        // Buttons
        Row(
            horizontalArrangement = Arrangement.spacedBy(Tok.ButtonGap),
            modifier = Modifier.widthIn(max = Tok.RowW),
        ) {
            PillButton("Agree", Tok.White, Tok.PbsBlue,
                Modifier.weight(1f).focusRequester(agree), onAgree)
            PillButton("Decline", Tok.SecFill, Tok.White,
                Modifier.weight(1f), onDecline)
        }

        if (showDisclaimer) {
            Text(
                "A selection is required to continue.",
                color = Tok.Disclaimer, fontFamily = PbsSans,
                fontSize = 28.sp, textAlign = TextAlign.Center,
            )
        }
    }

    LaunchedEffect(Unit) { agree.requestFocus() }   // default focus = Agree
}

@Composable
private fun PillButton(
    title: String,
    fill: Color,
    label: Color,
    modifier: Modifier = Modifier,
    onClick: () -> Unit,
) {
    var focused by remember { mutableStateOf(false) }
    val scale by animateFloatAsState(if (focused) Tok.FocusScale else 1f, label = "focusScale")

    androidx.tv.material3.Surface(
        onClick = onClick,
        shape = androidx.tv.material3.ClickableSurfaceDefaults.shape(RoundedCornerShape(Tok.Pill)),
        colors = androidx.tv.material3.ClickableSurfaceDefaults.colors(
            containerColor = fill, focusedContainerColor = fill,
        ),
        modifier = modifier
            .height(Tok.ButtonH)
            .scale(scale)
            .onFocusChanged { focused = it.isFocused }
            .then(if (focused)                                    // PROPOSED focus ring
                Modifier.border(Tok.FocusRingW, Tok.FocusRing, RoundedCornerShape(Tok.Pill))
            else Modifier),
    ) {
        Box(Modifier.fillMaxSize().padding(horizontal = Tok.ButtonPadX), Alignment.Center) {
            Text(title, color = label, fontFamily = PbsSans,
                fontWeight = FontWeight.Bold, fontSize = 32.sp, textAlign = TextAlign.Center)
        }
    }
}
