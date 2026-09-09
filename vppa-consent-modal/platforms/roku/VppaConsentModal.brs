' VppaConsentModal.brs — behavior for VppaConsentModal.xml (PBS VPPA Consent Modal, Roku).
'
' Ports the focus + input model from component-spec.json. Single row of two buttons;
' default focus = Agree (index 0). Left/Right move without wrapping; OK activates the
' focused button; Back dismisses. The focus ring is drawn by toggling a per-button
' "ring" Poster and a small scale animation (PROPOSED focus spec — confirm with design).

sub init()
    m.top.setFocus(true)

    m.body = m.top.findNode("body")
    m.body.text = bodyCopy()

    m.buttons = [m.top.findNode("agree"), m.top.findNode("decline")]
    m.rings   = [m.top.findNode("agreeRing"), m.top.findNode("declineRing")]
    m.results = ["agree", "decline"]
    m.index = 0

    m.top.observeField("showDisclaimer", "onDisclaimerChanged")
    setFocusIndex(0)
end sub

function bodyCopy() as string
    p1 = "By clicking " + chr(8220) + "Agree" + chr(8221) + " below, you consent under the Video Privacy Protection Act (VPPA) to PBS" + chr(8217) + "s potential sharing of your viewing history and related information with third parties, like its service providers or your local station including to personalize your digital experience and to ensure that our websites and apps function properly. Consent is not required to view our content, but some functionality may be unavailable to you if you decline consent."
    p2 = "This VPPA consent is separate from your cookie consent preference and applies only to the viewing information discussed above."
    p3 = "You can change your selection at any time by visiting Privacy Settings."
    return p1 + chr(10) + chr(10) + p2 + chr(10) + chr(10) + p3
end function

sub onDisclaimerChanged()
    m.top.findNode("disclaimer").visible = m.top.showDisclaimer
end sub

sub setFocusIndex(i as integer)
    m.index = i
    for j = 0 to m.rings.count() - 1
        focused = (j = i)
        m.rings[j].visible = focused
        ' PROPOSED: 1.06 scale on focus (scale about the button center)
        m.buttons[j].scale = focused ? [1.06, 1.06] : [1.0, 1.0]
    end for
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if key = "right" and m.index < m.buttons.count() - 1
        setFocusIndex(m.index + 1) : return true
    else if key = "left" and m.index > 0
        setFocusIndex(m.index - 1) : return true
    else if key = "OK"
        m.top.result = m.results[m.index] : return true
    else if key = "back"
        m.top.result = "dismiss" : return true
    end if

    return false
end function
