USING: accessors calendar continuations gdk4.ffi kernel locals math math.bitwise
namespaces sequences sets system threads tools.test ui ui.backend
ui.backend.gtk4 ui.gadgets ui.gadgets.tracks ui.gadgets.worlds
ui.gestures vectors ;
IN: ui.backend.gtk4.tests

! GDK4 moved Super out of the X11 Mod4 bit. Ordinary pointer state must
! never turn into a keyboard modifier.
{ { M+ } } [ GDK_SUPER_MASK gtk4-modifiers modifier ] unit-test
{ { S+ C+ A+ M+ } } [
    GDK_SHIFT_MASK GDK_CONTROL_MASK bitor
    GDK_ALT_MASK bitor GDK_SUPER_MASK bitor
    gtk4-modifiers modifier
] unit-test
{ f } [ GDK_BUTTON1_MASK gtk4-modifiers modifier ] unit-test
{ "F1" t } [ 0xffbe key-sym ] unit-test
{ " " f } [ 0x20 key-sym ] unit-test
{ "λ" f } [ 0x010003bb key-sym ] unit-test
{ f f } [ 0xffe1 key-sym ] unit-test

{ 3 } [ "aλz" 2 cursor>byte-offset ] unit-test
{ 5 } [ "a😀z" 2 cursor>byte-offset ] unit-test

TUPLE: resize-test-world < world
    { invalid-frames integer initial: 0 } rendered-dimensions ;

M: resize-test-world draw-world*
    dup dim>> over rendered-dimensions>> push
    dup children>> last [ loc>> second ] [ dim>> second ] bi +
    over dim>> second number=
    [ ] [ [ 1 + ] change-invalid-frames ] if
    call-next-method ;

:: native-resize-layout ( -- invalid-frames dimensions )
    f :> test-world!
    [
        <world-attributes> resize-test-world >>world-class
        "Resize layout test" >>title
        <gadget> { 640 360 } >>pref-dim >>gadgets <world>
        V{ } clone >>rendered-dimensions
        <gadget> { 100 24 } >>pref-dim f track-add
        dup test-world! open-world-window
        [
            [
                nano-count 5,000,000,000 + :> deadline
                [
                    test-world rendered-dimensions>> empty?
                    nano-count deadline < and
                ] [ 10 milliseconds sleep ] while
                test-world 0 >>invalid-frames drop
                { { 800 600 } { 900 700 } { 750 550 } } [
                    test-world swap resize-window
                    50 milliseconds sleep
                ] each
            ] [ test-world close-window ] finally
        ] in-thread
    ] with-ui
    test-world invalid-frames>>
    test-world rendered-dimensions>> members ;

ui-backend get-global gtk4-ui-backend eq?
ui-backend-available? and ui-running? not and [
    { 0 t } [ native-resize-layout length 2 >= ] unit-test
] when
