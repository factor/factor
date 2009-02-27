IN: pango.layouts.tests
USING: pango.layouts tools.test glib fonts accessors
sequences combinators.short-circuit math destructors ;

[ t ] [
    [
        "OH, HAI"
        <font> "Helvetica" >>name 12 >>size
        dummy-cairo
        <layout> &g_object_unref
        layout-dim
    ] with-destructors [ { [ integer? ] [ 0 > ] } 1&& ] all?
] unit-test