USING: alien.syntax classes.struct gdk.ffi tools.test ui.backend.gtk
ui.gestures ;
IN: ui.backend.gtk.tests

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

{
    T{ key-down f f "F2" }
    T{ key-up f f "H" }
} [
    gdk-key-press-event key-event>gesture
    gdk-key-release-event key-event>gesture
] unit-test
