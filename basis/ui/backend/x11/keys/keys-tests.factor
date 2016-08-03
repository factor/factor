USING: tools.test ui.backend.x11.keys x11.keysymdef ;
IN: ui.backend.x11.keys.tests

{
    65 f
    "RET" t
    f f
} [
    65 code>sym
    XK_Return code>sym
    XK_Hyper_R code>sym
] unit-test
