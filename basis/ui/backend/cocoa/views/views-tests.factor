IN: ui.backend.cocoa.views.tests
USING: ui.backend.cocoa.views tools.test kernel math.rectangles
namespaces ;

! #2379: unbound control keys must not insert invisible characters.
{ f } [ "\x05" cocoa-input-text ] unit-test
{ f } [ "\x00\x05\x0b\x1b\x7f" cocoa-input-text ] unit-test
{ "USE: math" } [ "USE: math\x05" cocoa-input-text ] unit-test
{ "\t\n\r" } [ "\t\n\r" cocoa-input-text ] unit-test
{ "日本語 é 🍆 —" } [ "日本語 é 🍆 —" cocoa-input-text ] unit-test
{ "" } [ "" cocoa-input-text ] unit-test

{ t } [
    T{ rect
        { loc { 0 0 } }
        { dim { 1000 1000 } }
    } "world" set

    T{ rect
        { loc { 1.5 2.25 } }
        { dim { 13.0 14.0 } }
    } dup "world" get rect>NSRect "world" get NSRect>rect =
] unit-test
