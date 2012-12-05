! Copyright (C) 2010, 2011 Anton Gorenko, Philipp Bruschweiler.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types alien.data
alien.strings arrays assocs classes.struct command-line
continuations destructors environment gdk.ffi gdk.gl.ffi
gdk.pixbuf.ffi glib.ffi gobject-introspection.standard-types
gobject.ffi gtk.ffi gtk.gl.ffi io io.encodings.binary
io.encodings.utf8 io.files kernel libc literals locals math
math.bitwise math.order math.vectors namespaces sequences
strings system threads ui ui.backend
ui.backend.gtk.input-methods ui.backend.gtk.io ui.clipboards
ui.event-loop ui.gadgets ui.gadgets.private ui.gadgets.worlds
ui.gestures ui.pixel-formats ui.pixel-formats.private ui.private
vocabs.loader combinators ;
IN: ui.backend.gtk

SINGLETON: gtk-ui-backend

TUPLE: handle ;
TUPLE: window-handle < handle window fullscreen? im-context ;

: <window-handle> ( window im-context -- window-handle )
    window-handle new
        swap >>im-context
        swap >>window ;

: connect-signal-with-data ( object signal-name callback data -- )
    [ utf8 string>alien ] 2dip g_signal_connect drop ;

: connect-signal ( object signal-name callback -- )
    f connect-signal-with-data ;

! Clipboards

TUPLE: gtk-clipboard handle ;

C: <gtk-clipboard> gtk-clipboard

M: gtk-clipboard clipboard-contents
    [
        handle>> gtk_clipboard_wait_for_text
        [ &g_free utf8 alien>string ] [ f ] if*
    ] with-destructors ;

M: gtk-clipboard set-clipboard-contents
    swap [ handle>> ] [ utf8 string>alien ] bi*
    -1 gtk_clipboard_set_text ;

: init-clipboard ( -- )
    selection "PRIMARY"
    clipboard "CLIPBOARD"
    [
        utf8 string>alien gdk_atom_intern_static_string
        gtk_clipboard_get <gtk-clipboard> swap set-global
    ] 2bi@ ;

! Timer

SYMBOL: next-fire-time

: set-timeout*-value ( alien value -- )
    swap 0 set-alien-signed-4 ; inline

: timer-prepare ( source timeout* -- ? )
    nip next-fire-time get-global nano-count [-]
    [ 1,000,000 /i set-timeout*-value ] keep 0 = ;

: timer-check ( source -- ? )
    drop next-fire-time get-global nano-count [-] 0 = ;

: timer-dispatch ( source callback user_data -- ? )
    3drop sleep-time [ 1,000,000,000 ] unless* nano-count +
    next-fire-time set-global
    yield t ;

: <timer-funcs> ( -- timer-funcs )
    GSourceFuncs malloc-struct
        [ timer-prepare ] GSourceFuncsPrepareFunc >>prepare
        [ timer-check ] GSourceFuncsCheckFunc >>check
        [ timer-dispatch ] GSourceFuncsDispatchFunc >>dispatch ;

:: with-timer ( quot -- )
    nano-count next-fire-time set-global
    <timer-funcs> &free
    GSource heap-size g_source_new &g_source_unref :> source
    source f g_source_attach drop
    [ quot call( -- ) ]
    [ source g_source_destroy ] [ ] cleanup ;

! User input

CONSTANT: events-mask
    flags{
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
        { S+ $ GDK_SHIFT_MASK }
        { C+ $ GDK_CONTROL_MASK }
        { A+ $ GDK_MOD1_MASK }
    }

CONSTANT: action-key-codes
    H{
        { $ GDK_KEY_BackSpace "BACKSPACE" }
        { $ GDK_KEY_Tab "TAB" }
        { $ GDK_KEY_Return "RET" }
        { $ GDK_KEY_KP_Enter "ENTER" }
        { $ GDK_KEY_Escape "ESC" }
        { $ GDK_KEY_Delete "DELETE" }
        { $ GDK_KEY_Home "HOME" }
        { $ GDK_KEY_Left "LEFT" }
        { $ GDK_KEY_Up "UP" }
        { $ GDK_KEY_Right "RIGHT" }
        { $ GDK_KEY_Down "DOWN" }
        { $ GDK_KEY_Page_Up "PAGE_UP" }
        { $ GDK_KEY_Page_Down "PAGE_DOWN" }
        { $ GDK_KEY_End "END" }
        { $ GDK_KEY_Begin "BEGIN" }
        { $ GDK_KEY_F1 "F1" }
        { $ GDK_KEY_F2 "F2" }
        { $ GDK_KEY_F3 "F3" }
        { $ GDK_KEY_F4 "F4" }
        { $ GDK_KEY_F5 "F5" }
        { $ GDK_KEY_F6 "F6" }
        { $ GDK_KEY_F7 "F7" }
        { $ GDK_KEY_F8 "F8" }
        { $ GDK_KEY_F9 "F9" }
        { $ GDK_KEY_F10 "F10" }
        { $ GDK_KEY_F11 "F11" }
        { $ GDK_KEY_F12 "F12" }
    }

: event-modifiers ( event -- seq )
    state>> modifiers modifier ;

: event-loc ( event -- loc )
    [ x>> ] [ y>> ] bi [ >fixnum ] bi@ 2array ;

: event-dim ( event -- dim )
    [ width>> ] [ height>> ] bi 2array ;

: scroll-direction ( event -- pair )
    direction>> {
        { $ GDK_SCROLL_UP { 0 -1 } }
        { $ GDK_SCROLL_DOWN { 0 1 } }
        { $ GDK_SCROLL_LEFT { -1 0 } }
        { $ GDK_SCROLL_RIGHT { 1 0 } }
    } at ;

: on-motion ( win event user-data -- ? )
    drop swap
    [ event-loc ] dip window
    move-hand fire-motion t ;

: on-leave ( win event user-data -- ? )
    3drop forget-rollover t ;

:: on-button-press ( win event user-data -- ? )
    win window :> world
    event type>> GDK_BUTTON_PRESS = [
        event button>> {
            { 8 [ ] }
            { 9 [ ] }
            [
                event event-modifiers swap <button-down>
                event event-loc
                world
                send-button-down
            ]
        } case
    ] when t ;

:: on-button-release ( win event user-data -- ? )
    win window :> world
    event type>> GDK_BUTTON_RELEASE = [
        event button>> {
            { 8 [ world left-action send-action ] }
            { 9 [ world right-action send-action ] }
            [
                event event-modifiers swap <button-up>
                event event-loc
                world
                send-button-up
            ]
        } case
    ] when t ;

: on-scroll ( win event user-data -- ? )
    drop swap [
        [ scroll-direction ] [ event-loc ] bi
    ] dip window send-scroll t ;

: key-sym ( event -- sym/f action? )
    keyval>> dup action-key-codes at [ t ]
    [ gdk_keyval_to_unicode [ f ] [ 1string ] if-zero f ] ?if ;

: key-event>gesture ( event -- mods sym/f action? )
    [ event-modifiers ] [ key-sym ] bi ;

: on-key-press ( win event user-data -- ? )
    drop swap [ key-event>gesture <key-down> ] [ window ] bi*
    propagate-key-gesture t ;

: on-key-release ( win event user-data -- ? )
    drop swap [ key-event>gesture <key-up> ] [ window ] bi*
    propagate-key-gesture t ;

: on-focus-in ( win event user-data -- ? )
    2drop window focus-world t ;

: on-focus-out ( win event user-data -- ? )
    2drop window unfocus-world t ;

! This word gets replaced when deploying. See 'Vocabulary icons'
! in the docs and tools.deploy.shaker.gtk-icon
: get-icon-data ( -- byte-array/f )
    [
        "resource:misc/icons/Factor_48x48.png" binary file-contents
    ] [ drop f ] recover ;

: load-icon ( -- )
    get-icon-data [
        [
            data>GInputStream &g_object_unref
            GInputStream>GdkPixbuf gtk_window_set_default_icon
        ] with-destructors
    ] when* ;

:: connect-user-input-signals ( win -- )
    win events-mask gtk_widget_add_events
    win "motion-notify-event" [ on-motion yield ]
    GtkWidget:motion-notify-event connect-signal
    win "leave-notify-event" [ on-leave yield ]
    GtkWidget:leave-notify-event connect-signal
    win "button-press-event" [ on-button-press yield ]
    GtkWidget:button-press-event connect-signal
    win "button-release-event" [ on-button-release yield ]
    GtkWidget:button-release-event connect-signal
    win "scroll-event" [ on-scroll yield ]
    GtkWidget:scroll-event connect-signal
    win "key-press-event" [ on-key-press yield ]
    GtkWidget:key-press-event connect-signal
    win "key-release-event" [ on-key-release yield ]
    GtkWidget:key-release-event connect-signal
    win "focus-in-event" [ on-focus-in yield ]
    GtkWidget:focus-in-event connect-signal
    win "focus-out-event" [ on-focus-out yield ]
    GtkWidget:focus-out-event connect-signal ;

! Window state events

: on-expose ( win event user-data -- ? )
    2drop window relayout t ;

: on-configure ( win event user-data -- ? )
    drop [ window ] [ GdkEventConfigure memory>struct ] bi*
    [ event-loc >>window-loc ] [ event-dim >>dim ] bi
    relayout-1 f ;

: on-delete ( win event user-data -- ? )
    2drop window ungraft t ;

:: connect-win-state-signals ( win -- )
    win "expose-event" [ on-expose yield ]
    GtkWidget:expose-event connect-signal
    win "configure-event" [ on-configure yield ]
    GtkWidget:configure-event connect-signal
    win "delete-event" [ on-delete yield ]
    GtkWidget:delete-event connect-signal ;

! Input methods

: on-retrieve-surrounding ( im-context win -- ? )
    window world-focus dup support-input-methods? [
        cursor-surrounding [ utf8 string>alien -1 ] dip
        gtk_im_context_set_surrounding t
    ] [ 2drop f ] if ;

: on-delete-surrounding ( im-context offset n win -- ? )
    window world-focus dup support-input-methods?
    [ delete-cursor-surrounding t ] [ 3drop f ] if nip ;

: on-commit ( im-context str win -- )
    [ drop ] [ utf8 alien>string ] [ window ] tri* user-input ;

: gadget-cursor-location ( gadget -- rectangle )
    [ screen-loc ] [ cursor-loc&dim ] bi [ v+ ] dip
    [ first2 [ >fixnum ] bi@ ] bi@
    cairo_rectangle_int_t <struct-boa> ;

: update-cursor-location ( im-context gadget -- )
    gadget-cursor-location gtk_im_context_set_cursor_location ;

! has to be called before the window signal handler
:: im-on-key-event ( win event im-context -- ? )
    win window world-focus :> gadget
    gadget support-input-methods? [
        im-context gadget update-cursor-location
        im-context event gtk_im_context_filter_keypress
    ] [ im-context gtk_im_context_reset f ] if ;

: im-on-focus-in ( win event im-context -- ? )
    2nip
    [ gtk_im_context_focus_in ] [ gtk_im_context_reset ] bi f ;

: im-on-focus-out ( win event im-context -- ? )
    2nip
    [ gtk_im_context_focus_out ] [ gtk_im_context_reset ] bi f ;

: im-on-destroy ( win im-context -- )
    nip [ f gtk_im_context_set_client_window ]
    ! weird GLib-GObject-WARNING message appears after calling this code
    ! [ g_object_unref ] bi ;
    [ drop ] bi ;

:: configure-im ( win im -- )
    im win gtk_widget_get_window gtk_im_context_set_client_window
    im f gtk_im_context_set_use_preedit

    im "commit" [ on-commit yield ]
    GtkIMContext:commit win connect-signal-with-data
    im "retrieve-surrounding" [ on-retrieve-surrounding yield ]
    GtkIMContext:retrieve-surrounding win connect-signal-with-data
    im "delete-surrounding" [ on-delete-surrounding yield ]
    GtkIMContext:delete-surrounding win connect-signal-with-data

    win "key-press-event" [ im-on-key-event yield ]
    GtkWidget:key-press-event im connect-signal-with-data
    win "key-release-event" [ im-on-key-event yield ]
    GtkWidget:key-release-event im connect-signal-with-data
    win "focus-in-event" [ im-on-focus-in yield ]
    GtkWidget:focus-out-event im connect-signal-with-data
    win "focus-out-event" [ im-on-focus-out yield ]
    GtkWidget:focus-out-event im connect-signal-with-data
    win "destroy" [ im-on-destroy yield ]
    GtkObject:destroy im connect-signal-with-data ;

! Window controls

CONSTANT: window-controls>decor-flags
    H{
        { close-button 0 }
        { minimize-button $ GDK_DECOR_MINIMIZE }
        { maximize-button $ GDK_DECOR_MAXIMIZE }
        { resize-handles $ GDK_DECOR_RESIZEH }
        { small-title-bar $ GDK_DECOR_TITLE }
        { normal-title-bar $ GDK_DECOR_TITLE }
        { textured-background 0 }
    }

CONSTANT: window-controls>func-flags
    H{
        { close-button $ GDK_FUNC_CLOSE }
        { minimize-button $ GDK_FUNC_MINIMIZE }
        { maximize-button $ GDK_FUNC_MAXIMIZE }
        { resize-handles $ GDK_FUNC_RESIZE }
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
        GDK_DECOR_BORDER bitor gdk_window_set_decorations
    ] [
        [ gtk_widget_get_window ] dip
        window-controls>func-flags symbols>flags
        GDK_FUNC_MOVE bitor gdk_window_set_functions
    ] 2tri ;

! OpenGL and Pixel formats

PIXEL-FORMAT-ATTRIBUTE-TABLE: gl-config-attribs
    ${ GDK_GL_USE_GL GDK_GL_RGBA }
    H{
        { double-buffered ${ GDK_GL_DOUBLEBUFFER } }
        { stereo ${ GDK_GL_STEREO } }
        ! { offscreen ${ GDK_GL_DRAWABLE_TYPE 2 } }
        ! { fullscreen ${ GDK_GL_DRAWABLE_TYPE 1 } }
        ! { windowed ${ GDK_GL_DRAWABLE_TYPE 1 } }
        { color-bits ${ GDK_GL_BUFFER_SIZE } }
        { red-bits ${ GDK_GL_RED_SIZE } }
        { green-bits ${ GDK_GL_GREEN_SIZE } }
        { blue-bits ${ GDK_GL_BLUE_SIZE } }
        { alpha-bits ${ GDK_GL_ALPHA_SIZE } }
        { accum-red-bits ${ GDK_GL_ACCUM_RED_SIZE } }
        { accum-green-bits ${ GDK_GL_ACCUM_GREEN_SIZE } }
        { accum-blue-bits ${ GDK_GL_ACCUM_BLUE_SIZE } }
        { accum-alpha-bits ${ GDK_GL_ACCUM_ALPHA_SIZE } }
        { depth-bits ${ GDK_GL_DEPTH_SIZE } }
        { stencil-bits ${ GDK_GL_STENCIL_SIZE } }
        { aux-buffers ${ GDK_GL_AUX_BUFFERS } }
        { sample-buffers ${ GDK_GL_SAMPLE_BUFFERS } }
        { samples ${ GDK_GL_SAMPLES } }
    }

M: gtk-ui-backend (make-pixel-format)
    nip >gl-config-attribs-int-array gdk_gl_config_new ;

M: gtk-ui-backend (free-pixel-format)
    handle>> g_object_unref ;

M: gtk-ui-backend (pixel-format-attribute)
    [ handle>> ] [ >gl-config-attribs ] bi*
    { gint } [ gdk_gl_config_get_attrib drop ]
    with-out-parameters ;

M: window-handle select-gl-context ( handle -- )
    window>>
    [ gtk_widget_get_gl_window ] [ gtk_widget_get_gl_context ] bi
    gdk_gl_drawable_make_current drop ;

M: window-handle flush-gl-context ( handle -- )
    window>> gtk_widget_get_gl_window
    gdk_gl_drawable_swap_buffers ;

! Window

: configure-gl ( world -- )
    [
        [ handle>> window>> ] [ handle>> ] bi*
        f t GDK_GL_RGBA_TYPE gtk_widget_set_gl_capability drop
    ] with-world-pixel-format ;

: auto-position ( win loc -- )
    dup { 0 0 } = [
        drop dup window topmost-window =
        GTK_WIN_POS_CENTER GTK_WIN_POS_NONE ?
        gtk_window_set_position
    ] [ first2 gtk_window_move ] if ;

M:: gtk-ui-backend (open-window) ( world -- )
    GTK_WINDOW_TOPLEVEL gtk_window_new :> win
    gtk_im_multicontext_new :> im

    win im <window-handle> world handle<<

    world win register-window

    win world [ window-loc>> auto-position ]
    [ dim>> first2 gtk_window_set_default_size ] 2bi

    win "factor" "Factor" [ utf8 string>alien ] bi@
    gtk_window_set_wmclass

    world configure-gl

    win gtk_widget_realize
    win world window-controls>> configure-window-controls

    win im configure-im
    win connect-user-input-signals
    win connect-win-state-signals

    win gtk_widget_show_all ;

M: gtk-ui-backend (close-window) ( handle -- )
    window>> [ gtk_widget_destroy ] [ unregister-window ] bi
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
    window>>
    [ gtk_grab_add ] [ GDK_BLANK_CURSOR set-cursor ] bi ;

M: gtk-ui-backend (ungrab-input)
    window>>
    [ gtk_grab_remove ] [ GDK_LEFT_PTR set-cursor ] bi ;

! Misc.

M: gtk-ui-backend beep
    gdk_beep ;

M:: gtk-ui-backend system-alert ( caption text -- )
    [
        f GTK_DIALOG_MODAL GTK_MESSAGE_WARNING GTK_BUTTONS_OK
        caption utf8 string>alien f
        gtk_message_dialog_new &gtk_widget_destroy
        [
            text utf8 string>alien f
            gtk_message_dialog_format_secondary_text
        ] [ gtk_dialog_run drop ] bi
    ] with-destructors ;

M: gtk-ui-backend (with-ui)
    [
        0 gint <ref> f void* <ref> gtk_init
        0 gint <ref> f void* <ref> gtk_gl_init
        load-icon
        init-clipboard
        start-ui
        [
            [ [ gtk_main ] with-timer ] with-event-loop
        ] with-destructors
    ] ui-running ;

os unix? os macosx? not and [
    gtk-ui-backend ui-backend set-global
] when

{ "ui.backend.gtk" "io.backend.unix" }
"ui.backend.gtk.io.unix" require-when

{ "ui.backend.gtk" "ui.gadgets.editors" }
"ui.backend.gtk.input-methods.editors" require-when

M: gtk-ui-backend ui-backend-available?
    "DISPLAY" os-env >boolean ;

