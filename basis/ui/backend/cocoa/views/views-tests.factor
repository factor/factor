IN: ui.backend.cocoa.views.tests
USING: accessors arrays assocs continuations kernel locals math.rectangles
namespaces opengl sequences tools.test ui.backend
ui.backend.cocoa.views ui.backend.cocoa.views.private ui.gadgets
ui.gadgets.private ui.gadgets.worlds ui.private vectors ;

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

TUPLE: test-scale-handle scale ;

M: test-scale-handle select-gl-context scale>> set-scale-factor ;

:: test-backing-scale-change ( -- scale text-empty? images-empty? pref queued? )
    gl-scale-factor get-global :> original-scale
    world get-global :> original-world
    [
        V{ } clone \ layout-queue [
            <gadget> { 20 10 } >>pref-dim :> child
            <world-attributes> child 1array >>gadgets <world>
                2.0 test-scale-handle boa >>handle
                H{ { "old text texture" t } } clone >>text-handle
                H{ { "old image texture" t } } clone >>images :> window
            window backing-scale-changed
            gl-scale-factor get-global
            window text-handle>> assoc-empty?
            window images>> assoc-empty?
            child pref-dim>>
            window layout-queue member?
        ] with-variable
    ] [
        original-scale gl-scale-factor set-global
        original-world world set-global
    ] finally ;

{ 2.0 t t f t } [ test-backing-scale-change ] unit-test

TUPLE: scale-layout-probe < gadget observed-scale ;

M: scale-layout-probe layout*
    gl-scale-factor get-global 1.0 or >>observed-scale drop ;

:: queue-scale-layout ( scale -- child )
    scale-layout-probe new :> child
    <world-attributes> child 1array >>gadgets <world>
        scale test-scale-handle boa >>handle drop
    child \ invalidate >>layout-state dup layout-later ;

:: test-mixed-scale-layout ( -- normal-scale retina-scale )
    gl-scale-factor get-global :> original-scale
    world get-global :> original-world
    [
        V{ } clone \ layout-queue [
            1.0 queue-scale-layout :> normal
            2.0 queue-scale-layout :> retina
            layout-queued drop
            normal observed-scale>> retina observed-scale>>
        ] with-variable
    ] [
        original-scale gl-scale-factor set-global
        original-world world set-global
    ] finally ;

{ 1.0 2.0 } [ test-mixed-scale-layout ] unit-test
