! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data alien.strings android.ffi arrays
assocs calendar classes.struct combinators io io.encodings.utf8 kernel locals math
namespaces opengl sequences strings system threads ui ui.backend ui.clipboards ui.event-loop
ui.gadgets ui.gadgets.worlds ui.gestures ui.render ;
QUALIFIED-WITH: ui.private uip
QUALIFIED-WITH: ui.gadgets.private ugp
IN: ui.backend.android

SINGLETON: android-ui-backend
SINGLETON: android-window
SYMBOL: android-world

TUPLE: android-clipboard ;
C: <android-clipboard> android-clipboard

M: android-clipboard clipboard-contents
    drop factor_android_clipboard_get
    [ utf8 alien>string ] [ factor_android_free ] bi ;

M: android-clipboard set-clipboard-contents
    drop utf8 string>alien factor_android_clipboard_set ;

: init-clipboard ( -- )
    <android-clipboard> clipboard set-global
    <clipboard> selection set-global ;

: android-dim ( -- dim )
    factor_android_surface_width factor_android_surface_height 2array
    [ gl-unscale ] map ;

: update-density ( -- )
    factor_android_density dup 0.0 > [ gl-scale-factor set-global ] [ drop ] if ;

M: android-window select-gl-context
    drop factor_android_gl_make_current
    [ "Unable to make the Android EGL context current" throw ] unless ;

M: android-window flush-gl-context
    drop factor_android_gl_swap
    [ "Unable to swap the Android EGL surface" throw ] unless ;

M: android-ui-backend current-gl-context factor_android_gl_context ;

M:: android-ui-backend (open-window) ( world -- )
    android-world get-global [ "Android presents one Factor world at a time" throw ] when
    30000 factor_android_wait_for_surface
    [ "Android did not provide a native window" throw ] unless
    factor_android_gl_open
    [ "Unable to create an Android OpenGL ES 3 context" throw ] unless
    world android-window uip:register-window
    world android-world set-global
    android-window world handle<<
    update-density
    1 factor_android_show_keyboard
    world android-dim >>dim t >>active? drop ;

M: android-ui-backend (close-window)
    0 factor_android_show_keyboard
    f android-world set-global
    [ uip:unregister-window ] [ drop factor_android_gl_close ] bi ;

M: android-ui-backend set-title 2drop ;
M: android-ui-backend resize-window 2drop ;
M: android-ui-backend raise-window* drop ;
M: android-ui-backend (grab-input) drop ;
M: android-ui-backend (ungrab-input) drop ;
M: android-ui-backend (set-fullscreen) 2drop ;
M: android-ui-backend (fullscreen?) drop t ;
M: android-ui-backend beep ;
M: android-ui-backend system-alert 2drop ;
M: android-ui-backend ui-backend-available? t ;
M: android-ui-backend stop-event-loop factor_android_finish ;

CONSTANT: android-key-names H{
    { 4 "ESC" } { 19 "UP" } { 20 "DOWN" } { 21 "LEFT" } { 22 "RIGHT" }
    { 61 "TAB" } { 62 " " } { 66 "ENTER" } { 67 "BACKSPACE" }
    { 111 "ESC" } { 112 "DELETE" } { 122 "HOME" } { 123 "END" }
}

CONSTANT: android-modifiers {
    { S+ 0x000000c1 }
    { A+ 0x00000032 }
    { C+ 0x00007000 }
}

: event-modifiers ( event -- modifiers/f )
    modifiers>> android-modifiers modifier ;

: event-location ( event -- loc )
    [ x>> ] [ y>> ] bi 2array [ gl-unscale ] map ;

: event-key ( event -- key/f )
    dup code>> android-key-names at
    [ nip ] [ character>> dup 0 = [ drop f ] [ 1string ] if ] if* ;

: event-character ( event -- key )
    character>> 1string ;

:: dispatch-pointer ( event world -- )
    event event-modifiers 1 <button-down>
    event event-location world send-button-down ;

:: dispatch-pointer-up ( event world -- )
    event event-modifiers 1 <button-up>
    event event-location world send-button-up ;

:: dispatch-key ( event world down? -- )
    event event-key [
        event event-modifiers swap f
        down? [ <key-down> ] [ <key-up> ] if
        world propagate-key-gesture
    ] when* ;

:: dispatch-android-event ( event world -- )
    event type>> {
        { FACTOR_ANDROID_EVENT_SURFACE [
            factor_android_gl_open
            [ "Unable to restore the Android EGL context" throw ] unless
            android-window select-gl-context
            update-density
            world android-dim >>dim t >>active? relayout
        ] }
        { FACTOR_ANDROID_EVENT_SURFACE_LOST [
            world f >>active? drop factor_android_gl_suspend
        ] }
        { FACTOR_ANDROID_EVENT_RESIZE [
            update-density
            world android-dim >>dim relayout
        ] }
        { FACTOR_ANDROID_EVENT_FOCUS [
            event code>> 0 = [ world uip:unfocus-world ] [ world uip:focus-world ] if
        ] }
        { FACTOR_ANDROID_EVENT_POINTER_DOWN [ event world dispatch-pointer ] }
        { FACTOR_ANDROID_EVENT_POINTER_UP [ event world dispatch-pointer-up ] }
        { FACTOR_ANDROID_EVENT_POINTER_MOVE [
            event event-location world move-hand fire-motion
        ] }
        { FACTOR_ANDROID_EVENT_KEY_DOWN [ event world t dispatch-key ] }
        { FACTOR_ANDROID_EVENT_KEY_UP [ event world f dispatch-key ] }
        { FACTOR_ANDROID_EVENT_TEXT [
            event event-modifiers event event-character f <key-down>
            world propagate-key-gesture
        ] }
        { FACTOR_ANDROID_EVENT_QUIT [ world ugp:ungraft ] }
        [ drop ]
    } case ;

M: android-ui-backend do-events
    factor-android-event <struct> dup factor_android_poll_event [
        android-world get-global dup [ dispatch-android-event ] [ 2drop ] if
    ] [ drop 10 milliseconds sleep ] if ;

M: android-ui-backend (with-ui)
    setup-gl3-hooks init-clipboard uip:start-ui event-loop ;

android-ui-backend ui-backend set-global
