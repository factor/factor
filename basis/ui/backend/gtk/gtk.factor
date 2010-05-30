! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.enums alien.strings arrays
ascii assocs classes.struct combinators.short-circuit
command-line destructors io.backend.unix.multiplexers
io.encodings.utf8 io.thread kernel libc literals locals math
math.bitwise namespaces sequences strings threads ui ui.backend
ui.clipboards ui.event-loop ui.gadgets ui.gadgets.private
ui.gadgets.worlds ui.gestures ui.private
glib.ffi gobject.ffi gtk.ffi gdk.ffi gdk.gl.ffi gtk.gl.ffi ;
IN: ui.backend.gtk

SINGLETON: gtk-ui-backend

TUPLE: handle ;
TUPLE: window-handle < handle window fullscreen? ;

: <window-handle> ( window -- window-handle )
    [ window-handle new ] dip >>window ;

TUPLE: gtk-clipboard handle ;

C: <gtk-clipboard> gtk-clipboard

CONSTANT: events-mask
    {
        GDK_POINTER_MOTION_MASK
        GDK_POINTER_MOTION_HINT_MASK
        GDK_ENTER_NOTIFY_MASK
        GDK_LEAVE_NOTIFY_MASK
        GDK_BUTTON_PRESS_MASK
        GDK_BUTTON_RELEASE_MASK
        GDK_KEY_PRESS_MASK
        GDK_KEY_RELEASE_MASK
        GDK_FOCUS_CHANGE_MASK
    }

CONSTANT: modifiers
    {
        { S+ $[ GDK_SHIFT_MASK enum>number ] }
        { C+ $[ GDK_CONTROL_MASK enum>number ] }
        { A+ $[ GDK_MOD1_MASK enum>number ] }
    }

CONSTANT: action-key-codes
    H{
        ${ GDK_BackSpace "BACKSPACE" }
        ${ GDK_Tab "TAB" }
        ${ GDK_Return "RET" }
        ${ GDK_KP_Enter "ENTER" }
        ${ GDK_Escape "ESC" }
        ${ GDK_Delete "DELETE" }
        ${ GDK_Home "HOME" }
        ${ GDK_Left "LEFT" }
        ${ GDK_Up "UP" }
        ${ GDK_Right "RIGHT" }
        ${ GDK_Down "DOWN" }
        ${ GDK_Page_Up "PAGE_UP" }
        ${ GDK_Page_Down "PAGE_DOWN" }
        ${ GDK_End "END" }
        ${ GDK_Begin "BEGIN" }
        ${ GDK_F1 "F1" }
        ${ GDK_F2 "F2" }
        ${ GDK_F3 "F3" }
        ${ GDK_F4 "F4" }
        ${ GDK_F5 "F5" }
        ${ GDK_F6 "F6" }
        ${ GDK_F7 "F7" }
        ${ GDK_F8 "F8" }
        ${ GDK_F9 "F9" }
        ${ GDK_F10 "F10" }
        ${ GDK_F11 "F11" }
        ${ GDK_F12 "F12" }
    }

: event-modifiers ( event -- seq )
    state>> modifiers modifier ;

: event-loc ( event -- loc )
    [ x>> ] [ y>> ] bi [ >fixnum ] bi@ 2array ;

: event-dim ( event -- dim )
    [ width>> ] [ height>> ] bi 2array ;

: scroll-direction ( event -- pair )
    direction>> {
        ${ GDK_SCROLL_UP { 0 -1 } }
        ${ GDK_SCROLL_DOWN { 0 1 } }
        ${ GDK_SCROLL_LEFT { -1 0 } }
        ${ GDK_SCROLL_RIGHT { 1 0 } }
    } at ;

: mouse-event>gesture ( event -- modifiers button loc )
    [ event-modifiers ] [ button>> ] [ event-loc ] tri ;

: on-motion ( sender event user-data -- result )
    drop swap
    [ GdkEventMotion memory>struct event-loc ] dip window
    move-hand fire-motion t ;

: on-enter ( sender event user-data -- result )
    on-motion ;

: on-leave ( sender event user-data -- result )
    3drop forget-rollover t ;

: on-button-press ( sender event user-data -- result )
    drop swap [
        GdkEventButton memory>struct
        mouse-event>gesture [ <button-down> ] dip
    ] dip window send-button-down t ;

: on-button-release ( sender event user-data -- result )
    drop swap [
        GdkEventButton memory>struct
        mouse-event>gesture [ <button-up> ] dip
    ] dip window send-button-up t ;

: on-scroll ( sender event user-data -- result )
    drop swap [
        GdkEventScroll memory>struct
        [ scroll-direction ] [ event-loc ] bi
    ] dip window send-scroll t ;

: key-sym ( event -- sym action? )
    keyval>> dup action-key-codes at
    [ t ] [ gdk_keyval_to_unicode 1string f ] ?if ;

: key-event>gesture ( event -- modifiers sym action? )
    [ event-modifiers ] [ key-sym ] bi ;

: valid-input? ( string gesture -- ? )
    over empty? [ 2drop f ] [
        mods>> { f { S+ } } member? [
            [ { [ 127 = not ] [ CHAR: \s >= ] } 1&& ] all?
        ] [
            [ { [ 127 = not ] [ CHAR: \s >= ] [ alpha? not ] } 1&& ] all?
        ] if
    ] if ;

:: on-key-press ( sender event user-data -- result )
    sender window :> world
    event GdkEventKey memory>struct :> ev
    ev key-event>gesture <key-down> :> gesture
    gesture world propagate-key-gesture
    ev keyval>> gdk_keyval_to_unicode 1string dup
    gesture valid-input?
    [ world user-input ] [ drop ] if
    t ;

: on-key-release ( sender event user-data -- result )
    drop swap [
        GdkEventKey memory>struct
        key-event>gesture <key-up>
    ] dip window propagate-key-gesture t ;

: on-focus-in ( sender event user-data -- result )
    2drop window focus-world t ;

: on-focus-out ( sender event user-data -- result )
    2drop window unfocus-world t ;

: on-expose ( sender event user-data -- result )
    2drop window relayout t ;

: on-configure ( sender event user-data -- result )
    drop [ window ] dip GdkEventConfigure memory>struct
    [ event-loc >>window-loc ] [ event-dim >>dim  ] bi
    relayout-1 t ;

: on-delete ( sender event user-data -- result )
    2drop window ungraft t ;

: init-clipboard ( -- )
    selection "PRIMARY"
    clipboard "CLIPBOARD"
    [
        utf8 string>alien gdk_atom_intern_static_string
        gtk_clipboard_get <gtk-clipboard> swap set-global
    ] 2bi@ ;

: io-source-prepare ( source timeout -- result )
    2drop f ;

: io-source-check ( source -- result )
    poll_fds>> 0 g_slist_nth_data GPollFD memory>struct
    revents>> 0 = not ;

: io-source-dispatch ( source callback user_data -- result )
     3drop
     0 mx get wait-for-events
     yield t ;

: timeout-func ( -- func )
    [ drop yield t ] GSourceFunc ;

: init-timeout ( interval -- )
    G_PRIORITY_DEFAULT swap timeout-func f f
    g_timeout_add_full drop ;

CONSTANT: poll-fd-events
    {
        G_IO_IN
        G_IO_OUT
        G_IO_PRI
        G_IO_ERR
        G_IO_HUP
        G_IO_NVAL
    }

: create-poll-fd ( -- poll-fd )
    GPollFD malloc-struct &free
        mx get fd>> >>fd
        poll-fd-events [ enum>number ] [ bitor ] map-reduce >>events ;

: init-io-event-source ( -- )
    GSourceFuncs malloc-struct &free
        [ io-source-prepare ] GSourceFuncsPrepareFunc >>prepare
        [ io-source-check ] GSourceFuncsCheckFunc >>check
        [ io-source-dispatch ] GSourceFuncsDispatchFunc >>dispatch
    GSource heap-size g_source_new &g_source_unref
    [ create-poll-fd g_source_add_poll ]
    [ f g_source_attach drop ] bi ;

M: gtk-ui-backend (with-ui)
    [
        f f gtk_init
        f f gtk_gl_init
        init-clipboard
        start-ui
        f io-thread-running? set-global
        [
            init-io-event-source
            ! is it correct to use timeouts with 'yield'?
            10 init-timeout
            gtk_main
        ] with-destructors
    ] ui-running ;

: connect-signal ( object signal-name callback -- )
    [ utf8 string>alien ] dip f f 0 g_signal_connect_data drop ;

:: connect-signals ( win -- )
    win events-mask [ enum>number ] [ bitor ] map-reduce
    gtk_widget_add_events
    
    win "expose-event" [ on-expose ]
    GtkWidget:expose-event connect-signal
    win "configure-event" [ on-configure ]
    GtkWidget:configure-event connect-signal
    win "motion-notify-event" [ on-motion ]
    GtkWidget:motion-notify-event connect-signal
    win "leave-notify-event" [ on-leave ]
    GtkWidget:leave-notify-event connect-signal
    win "enter-notify-event" [ on-enter ]
    GtkWidget:enter-notify-event connect-signal
    win "button-press-event" [ on-button-press ]
    GtkWidget:button-press-event connect-signal
    win "button-release-event" [ on-button-release ]
    GtkWidget:button-release-event connect-signal
    win "scroll-event" [ on-scroll ]
    GtkWidget:scroll-event connect-signal
    win "key-press-event" [ on-key-press ]
    GtkWidget:key-press-event connect-signal
    win "key-release-event" [ on-key-release ]
    GtkWidget:key-release-event connect-signal
    win "focus-in-event" [ on-focus-in ]
    GtkWidget:focus-in-event connect-signal
    win "focus-out-event" [ on-focus-out ]
    GtkWidget:focus-out-event connect-signal
    win "delete-event" [ on-delete ]
    GtkWidget:delete-event connect-signal ;

: enable-gl ( win -- ? )
    ${
        GDK_GL_MODE_RGBA
        GDK_GL_MODE_DOUBLE
        GDK_GL_MODE_DEPTH
        GDK_GL_MODE_STENCIL
        GDK_GL_MODE_ALPHA
    } [ enum>number ] [ bitor ] map-reduce
    gdk_gl_config_new_by_mode
    f t GDK_GL_RGBA_TYPE enum>number gtk_widget_set_gl_capability ;

CONSTANT: window-controls>decor-flags
    H{
        { close-button 0 }
        { minimize-button $[ GDK_DECOR_MINIMIZE enum>number ] }
        { maximize-button $[ GDK_DECOR_MAXIMIZE enum>number ] }
        { resize-handles $[ GDK_DECOR_RESIZEH enum>number ] }
        { small-title-bar $[ GDK_DECOR_TITLE enum>number ] }
        { normal-title-bar $[ GDK_DECOR_TITLE enum>number ] }
        { textured-background 0 }
    }
    
CONSTANT: window-controls>func-flags
    H{
        { close-button $[ GDK_FUNC_CLOSE enum>number ] }
        { minimize-button $[ GDK_FUNC_MINIMIZE enum>number ] }
        { maximize-button $[ GDK_FUNC_MAXIMIZE enum>number ] }
        { resize-handles $[ GDK_FUNC_RESIZE enum>number ] }
        { small-title-bar 0 }
        { normal-title-bar 0 }
        { textured-background 0 }
    }

: configure-window-controls ( win controls -- )
    [
        small-title-bar swap member-eq?
        GDK_WINDOW_TYPE_HINT_UTILITY GDK_WINDOW_TYPE_HINT_NORMAL ?
        gtk_window_set_type_hint
    ] [
        [ gtk_widget_get_window ] dip
        window-controls>decor-flags symbols>flags
        GDK_DECOR_BORDER enum>number bitor gdk_window_set_decorations
    ] [
        [ gtk_widget_get_window ] dip
        window-controls>func-flags symbols>flags
        GDK_FUNC_MOVE enum>number bitor gdk_window_set_functions
    ] 2tri ;

M:: gtk-ui-backend (open-window) ( world -- )
    GTK_WINDOW_TOPLEVEL gtk_window_new :> win
    world [ window-loc>> win swap first2 gtk_window_move ]
    [ dim>> win swap first2 gtk_window_set_default_size ] bi
    
    win enable-gl drop ! сделать проверку на доступность OpenGL

    win connect-signals
    
    win gtk_widget_realize
    win world window-controls>> configure-window-controls
    
    win <window-handle> world handle<<
    world win register-window
    
    win gtk_widget_show_all ;

M: gtk-ui-backend (close-window) ( handle -- )
    window>> [ unregister-window ] [ gtk_widget_destroy ] bi
    event-loop? [ gtk_main_quit ] unless ;

M: gtk-ui-backend set-title
    swap [ handle>> window>> ] [ utf8 string>alien ] bi*
    gtk_window_set_title ;

M: gtk-ui-backend (set-fullscreen)
    [ handle>> ] dip [ >>fullscreen? ] keep
    [ window>> ] dip
    [ gtk_window_fullscreen ]
    [ gtk_window_unfullscreen ] if ;

M: gtk-ui-backend (fullscreen?)
    handle>> fullscreen?>> ;
    
M: gtk-ui-backend raise-window*
    handle>> window>> gtk_window_present ;

: set-cursor ( win cursor -- )
    [
        [ gtk_widget_get_window ] dip
        gdk_cursor_new &gdk_cursor_unref
        gdk_window_set_cursor
    ] with-destructors ;

M: gtk-ui-backend (grab-input)
    handle>> window>>
    [ gtk_grab_add ] [ GDK_BLANK_CURSOR set-cursor ] bi ;

M: gtk-ui-backend (ungrab-input)
    handle>> window>>
    [ gtk_grab_remove ] [ GDK_ARROW set-cursor ] bi ;

M: window-handle select-gl-context ( handle -- )
    window>>
    [ gtk_widget_get_gl_window ] [ gtk_widget_get_gl_context ] bi
    gdk_gl_drawable_make_current drop ;

M: window-handle flush-gl-context ( handle -- )
    window>> gtk_widget_get_gl_window
    gdk_gl_drawable_swap_buffers ;

M: gtk-ui-backend beep
    gdk_beep ;

M:: gtk-ui-backend system-alert ( caption text -- )
    f GTK_DIALOG_MODAL GTK_MESSAGE_WARNING GTK_BUTTONS_OK
    caption utf8 string>alien f gtk_message_dialog_new
    [ text utf8 string>alien f gtk_message_dialog_format_secondary_text ]
    [ gtk_dialog_run drop ]
    [ gtk_widget_destroy ] tri ;

M: gtk-clipboard clipboard-contents
    handle>> gtk_clipboard_wait_for_text utf8 alien>string ;

M: gtk-clipboard set-clipboard-contents
    swap [ handle>> ] [ utf8 string>alien ] bi*
    -1 gtk_clipboard_set_text ;

gtk-ui-backend ui-backend set-global

[ "ui.tools" ] main-vocab-hook set-global

