USING: arrays kernel sequences tools.test ui.backend.x11.keys x11.keysymdef ;
IN: ui.backend.x11.keys.tests

{
    65 f
    "RET" t
    f f
    "F10" t
    "F11" t
    "F12" t
} [
    65 code>sym
    XK_Return code>sym
    XK_Hyper_R code>sym
    XK_F10 code>sym
    XK_F11 code>sym
    XK_F12 code>sym
] unit-test

! GitHub #1954: printable keypad keysyms are not Unicode code points.
{
    {
        { 48 f } { 49 f } { 50 f } { 51 f } { 52 f }
        { 53 f } { 54 f } { 55 f } { 56 f } { 57 f }
        { 42 f } { 43 f } { 44 f } { 45 f } { 46 f } { 47 f }
        { 61 f } { 32 f }
    }
} [
    {
        XK_KP_0 XK_KP_1 XK_KP_2 XK_KP_3 XK_KP_4
        XK_KP_5 XK_KP_6 XK_KP_7 XK_KP_8 XK_KP_9
        XK_KP_Multiply XK_KP_Add XK_KP_Separator XK_KP_Subtract
        XK_KP_Decimal XK_KP_Divide XK_KP_Equal XK_KP_Space
    } [ execute( -- code ) code>sym 2array ] map
] unit-test

! NumLock-off navigation and keypad Enter retain their action-key semantics.
{ "END" t "ENTER" t } [
    XK_KP_End code>sym XK_KP_Enter code>sym
] unit-test
