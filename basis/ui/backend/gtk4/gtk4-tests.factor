USING: gdk4.ffi kernel math math.bitwise tools.test ui.backend.gtk4
ui.gestures ;
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
