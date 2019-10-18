IN: pango.layouts.tests
USING: pango.layouts pango.cairo tools.test glib fonts accessors
sequences combinators.short-circuit math destructors ;

[ t ] [
    [
        <font> "Helvetica" >>name 12 >>size
        "OH, HAI"
        cached-layout ink-rect>> dim>>
    ] with-destructors [ 0 > ] all?
] unit-test