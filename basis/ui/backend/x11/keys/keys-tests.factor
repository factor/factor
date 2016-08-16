USING: tools.test ui.backend.x11.keys x11.keysymdef ;
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
