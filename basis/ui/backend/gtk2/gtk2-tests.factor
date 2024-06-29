USING: alien.syntax classes.struct gdk2.ffi kernel sequences system
tools.test ui.backend.gtk2 ui.gestures ;
IN: ui.backend.gtk2.tests

: gdk-key-release-event ( -- event )
    S{ GdkEventKey
        { type 9 }
        { window ALIEN: 1672900 }
        { send_event 0 }
        { time 1332590199 }
        { state 17 }
        { keyval 72 }
        { length 1 }
        { string ALIEN: 1b25c80 }
        { hardware_keycode 43 }
        { group 0 }
        { is_modifier 0 }
    } ;

: gdk-key-press-event ( -- event )
    S{ GdkEventKey
        { type 8 }
        { window ALIEN: 16727e0 }
        { send_event 0 }
        { time 1332864912 }
        { state 16 }
        { keyval 65471 }
        { length 0 }
        { string ALIEN: 19c9700 }
        { hardware_keycode 68 }
        { group 0 }
        { is_modifier 0 }
    } ;

: gdk-space-key-press-event ( -- event )
    S{ GdkEventKey
        { type 8 }
        { window ALIEN: 1b66360 }
        { send_event 0 }
        { time 28246628 }
        { state 0 }
        { keyval 32 }
        { length 0 }
        { string ALIEN: 20233b0 }
        { hardware_keycode 64 }
        { group 0 }
        { is_modifier 1 }
    } ;

: gdk-windows-key-release-event ( -- event )
    S{ GdkEventKey
        { type 9 }
        { window ALIEN: 1a71d80 }
        { send_event 0 }
        { time 47998769 }
        { state 67108928 }
        { keyval 119 }
        { length 1 }
        { string ALIEN: 2017640 }
        { hardware_keycode 25 }
        { group 0 }
        { is_modifier 0 }
    } ;


! The macOS build servers don't have the gtk libs
os linux? [
    ! key-event>gesture
    {
        T{ key-down f f "F2" }
        T{ key-up f f "H" }
        T{ key-down f f " " }
        T{ key-up { mods { M+ } } { sym "w" } }
    } [
        gdk-key-press-event key-event>gesture
        gdk-key-release-event key-event>gesture
        gdk-space-key-press-event key-event>gesture
        gdk-windows-key-release-event key-event>gesture
    ] unit-test

    ! key-sym
    { "F2" t } [
        GDK_KEY_F2 key-sym
    ] unit-test
] when

{ 9854 } [
    "gpu.demos.bunny" vocab-icon-data length
] unit-test
