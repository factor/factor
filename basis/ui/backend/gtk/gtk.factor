! Copyright (C) 2010 Anton Gorenko, Philipp Brüschweiler.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types alien.data
alien.strings alien.syntax arrays assocs classes.struct
command-line destructors gdk.ffi gdk.gl.ffi glib.ffi
gobject.ffi gtk.ffi gtk.gl.ffi io.backend
io.backend.unix.multiplexers io.encodings.utf8 io.thread kernel
libc literals locals math math.bitwise math.order math.vectors
namespaces sequences strings system threads ui ui.backend
ui.clipboards ui.commands ui.event-loop ui.gadgets
ui.gadgets.menus ui.gadgets.private ui.gadgets.worlds
ui.gestures ui.pixel-formats ui.pixel-formats.private
ui.private ;
RENAME: windows ui.private => ui:windows
EXCLUDE: ui.gadgets.editors => change-caret ;
RENAME: change-caret ui.gadgets.editors => editors:change-caret
IN: ui.backend.gtk

SINGLETON: gtk-ui-backend

TUPLE: handle ;
TUPLE: window-handle < handle window fullscreen? im-context im-menu ;

: <window-handle> ( window im-context -- window-handle )
    window-handle new
        swap >>im-context
        swap >>window ;

TUPLE: gtk-clipboard handle ;

C: <gtk-clipboard> gtk-clipboard

PIXEL-FORMAT-ATTRIBUTE-TABLE: gl-config-attribs ${ GDK_GL_USE_GL GDK_GL_RGBA } H{
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
    { int } [ gdk_gl_config_get_attrib drop ]
    with-out-parameters ;

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
        { $ GDK_BackSpace "BACKSPACE" }
        { $ GDK_Tab "TAB" }
        { $ GDK_Return "RET" }
        { $ GDK_KP_Enter "ENTER" }
        { $ GDK_Escape "ESC" }
        { $ GDK_Delete "DELETE" }
        { $ GDK_Home "HOME" }
        { $ GDK_Left "LEFT" }
        { $ GDK_Up "UP" }
        { $ GDK_Right "RIGHT" }
        { $ GDK_Down "DOWN" }
        { $ GDK_Page_Up "PAGE_UP" }
        { $ GDK_Page_Down "PAGE_DOWN" }
        { $ GDK_End "END" }
        { $ GDK_Begin "BEGIN" }
        { $ GDK_F1 "F1" }
        { $ GDK_F2 "F2" }
        { $ GDK_F3 "F3" }
        { $ GDK_F4 "F4" }
        { $ GDK_F5 "F5" }
        { $ GDK_F6 "F6" }
        { $ GDK_F7 "F7" }
        { $ GDK_F8 "F8" }
        { $ GDK_F9 "F9" }
        { $ GDK_F10 "F10" }
        { $ GDK_F11 "F11" }
        { $ GDK_F12 "F12" }
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

: key-sym ( event -- sym/f action? )
    keyval>> dup action-key-codes at [ t ]
    [ gdk_keyval_to_unicode [ f ] [ 1string ] if-zero f ] ?if ;

: key-event>gesture ( event -- mods sym/f action? )
    GdkEventKey memory>struct
    [ event-modifiers ] [ key-sym ] bi ;
  
: on-key-press ( sender event user-data -- result )
    drop swap [ key-event>gesture <key-down> ] [ window ] bi*
    propagate-key-gesture t ;

: on-key-release ( sender event user-data -- result )
    drop swap [ key-event>gesture <key-up> ] [ window ] bi*
    propagate-key-gesture t ;

: on-focus-in ( sender event user-data -- result )
    2drop window focus-world t ;

: on-focus-out ( sender event user-data -- result )
    2drop window unfocus-world t ;

: on-expose ( sender event user-data -- result )
    2drop window relayout t ;

: on-configure ( sender event user-data -- result )
    drop [ window ] dip GdkEventConfigure memory>struct
    [ event-loc >>window-loc ] [ event-dim >>dim  ] bi
    relayout-1 f ;

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

CONSTANT: poll-fd-events
    flags{
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
        poll-fd-events >>events ;

: init-io-event-source ( -- )
    GSourceFuncs malloc-struct &free
        [ io-source-prepare ] GSourceFuncsPrepareFunc >>prepare
        [ io-source-check ] GSourceFuncsCheckFunc >>check
        [ io-source-dispatch ] GSourceFuncsDispatchFunc >>dispatch
    GSource heap-size g_source_new &g_source_unref
    [ create-poll-fd g_source_add_poll ]
    [ f g_source_attach drop ] bi ;

SYMBOL: next-timeout

: set-timeout*-value ( alien value -- )
    swap 0 set-alien-signed-4 ; inline

: timeout-prepare ( source timeout* -- result )
    nip next-timeout get-global nano-count [-]
    [ 1,000,000 /i set-timeout*-value ] keep 0 = ;

: timeout-check ( source -- result )
    drop next-timeout get-global nano-count [-] 0 = ;

: timeout-dispatch ( source callback user_data -- result )
    3drop sleep-time [ 1,000,000,000 ] unless* nano-count +
    next-timeout set-global
    yield t ;

: init-timeout ( -- )
    GSourceFuncs malloc-struct &free
        [ timeout-prepare ] GSourceFuncsPrepareFunc >>prepare
        [ timeout-check ] GSourceFuncsCheckFunc >>check
        [ timeout-dispatch ] GSourceFuncsDispatchFunc >>dispatch
    GSource heap-size g_source_new &g_source_unref
    f g_source_attach drop
    nano-count next-timeout set-global ;

: load-icon ( -- )
    ! This file is not in a resource.txt because it can be
    ! overwritten when deploying. See 'Vocabulary icons'
    ! in the docs.
    "vocab:ui/backend/gtk/icon.png"
    normalize-path utf8 string>alien
    { { pointer: GError initial: f } }
    [ gtk_window_set_default_icon_from_file ] with-out-parameters
    handle-GError drop ;

M: gtk-ui-backend (with-ui)
    [
        f f gtk_init
        f f gtk_gl_init
        load-icon
        init-clipboard
        start-ui
        stop-io-thread
        [
            init-io-event-source
            init-timeout
            gtk_main
        ] with-destructors
    ] ui-running ;

: connect-signal-with-data ( object signal-name callback data -- )
    [ utf8 string>alien ] 2dip g_signal_connect drop ;

: connect-signal ( object signal-name callback -- )
    f connect-signal-with-data ;

:: connect-signals ( win -- )
    win events-mask gtk_widget_add_events
    
    win "expose-event" [ on-expose yield ]
    GtkWidget:expose-event connect-signal
    win "configure-event" [ on-configure yield ]
    GtkWidget:configure-event connect-signal
    win "motion-notify-event" [ on-motion yield ]
    GtkWidget:motion-notify-event connect-signal
    win "leave-notify-event" [ on-leave yield ]
    GtkWidget:leave-notify-event connect-signal
    win "enter-notify-event" [ on-enter yield ]
    GtkWidget:enter-notify-event connect-signal
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
    GtkWidget:focus-out-event connect-signal
    win "delete-event" [ on-delete yield ]
    GtkWidget:delete-event connect-signal ;

! ----------------------

GENERIC: support-input-methods? ( gadget -- ? )
GENERIC: get-cursor-surrounding ( gadget -- text cursor-pos )
GENERIC: delete-cursor-surrounding ( offset count gadget -- )
GENERIC: set-preedit-string ( str cursor-pos gadget -- )
GENERIC: get-cursor-loc&dim ( gadget -- loc dim )

M: gadget support-input-methods? drop f ;

M: editor support-input-methods? drop t ;

M: editor get-cursor-surrounding
    dup editor-caret first2 [ swap editor-line ] dip ;

M: editor delete-cursor-surrounding
    3drop ;

M: editor set-preedit-string
    nip dup [ editor-caret ] keep
    [ user-input* drop ] 2dip
    set-caret ;

M: editor get-cursor-loc&dim
    [ caret-loc ] [ caret-dim ] bi ;

! ----------------------

: on-retrieve-surrounding ( im-context win -- ? )
    window world-focus dup support-input-methods? [
        get-cursor-surrounding [ utf8 string>alien -1 ] dip
        gtk_im_context_set_surrounding t
    ] [ 2drop f ] if ;

: on-delete-surrounding ( im-context offset n win -- ? )
    window world-focus dup support-input-methods?
    [ delete-cursor-surrounding t ] [ 3drop f ] if nip ;

: get-preedit-string ( im-context -- str cursor-pos )
    { void* int } [ f swap gtk_im_context_get_preedit_string ]
    with-out-parameters 
    [ [ utf8 alien>string ] [ g_free ] bi ] dip ;
            
: on-preedit-changed ( im-context user-data -- )
    window world-focus dup support-input-methods? [
        [ get-preedit-string ] dip set-preedit-string
    ] [ 2drop ] if ;

: on-commit ( sender str user_data -- )
    [ drop ] [ utf8 alien>string ] [ window ] tri* user-input ;

: gadget-location ( gadget -- loc )
    [ loc>> ] [ parent>> [ gadget-location v+ ] when* ] bi ;

: gadget-cursor-location ( gadget -- rectangle )
    [ gadget-location ] [ get-cursor-loc&dim ] bi [ v+ ] dip
    [ first2 ] bi@ GdkRectangle <struct-boa> ;

: update-cursor-location ( im-context gadget -- )
    gadget-cursor-location gtk_im_context_set_cursor_location ;

! has to be called before the window signal handler
:: im-on-key-event ( sender event im-context -- result )
    sender window world-focus :> gadget
    gadget support-input-methods? [
        im-context gadget update-cursor-location
        im-context event gtk_im_context_filter_keypress
    ] [ im-context gtk_im_context_reset f ] if ;

: im-on-focus-in ( sender event user-data -- result )
    2drop window handle>> im-context>>
    [ gtk_im_context_focus_in ] [ gtk_im_context_reset ] bi f ;

: im-on-focus-out ( sender event user-data -- result )
    2drop window handle>> im-context>>
    [ gtk_im_context_focus_out ] [ gtk_im_context_reset ] bi f ;

: im-on-destroy ( sender user-data -- )
    nip [ f gtk_im_context_set_client_window ]
    [ g_object_unref ] bi ;

! for testing only

: com-input-method ( world -- )
    find-world handle>> im-menu>> f f f f 0
    gtk_get_current_event_time gtk_menu_popup ;

: im-menu ( world -- )
    { com-input-method } show-commands-menu ;

editor "input-method" f  {
    { T{ button-down f { S+ C+ } 3 } im-menu }
} define-command-map

! --------

:: configure-im ( win im -- )
    im win gtk_widget_get_window gtk_im_context_set_client_window
    im f gtk_im_context_set_use_preedit

    gtk_menu_new :> menu
    im menu gtk_im_multicontext_append_menuitems
    menu win window handle>> im-menu<<
    
    im "commit" [ on-commit yield ]
    GtkIMContext:commit win connect-signal-with-data
    im "retrieve-surrounding" [ on-retrieve-surrounding yield ]
    GtkIMContext:retrieve-surrounding win connect-signal-with-data
    im "delete-surrounding" [ on-delete-surrounding yield ]
    GtkIMContext:delete-surrounding win connect-signal-with-data
    im "preedit-changed" [ on-preedit-changed yield ]
    GtkIMContext:preedit-changed win connect-signal-with-data

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

: setup-gl ( world -- ? )
    [
        [ handle>> window>> ] [ handle>> ] bi*
        f t GDK_GL_RGBA_TYPE gtk_widget_set_gl_capability
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
    
    world setup-gl drop

    win gtk_widget_realize
    win world window-controls>> configure-window-controls
    
    win im configure-im
    win connect-signals

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
    [
        handle>> gtk_clipboard_wait_for_text
        [ &g_free utf8 alien>string ] [ f ] if*
    ] with-destructors ;

M: gtk-clipboard set-clipboard-contents
    swap [ handle>> ] [ utf8 string>alien ] bi*
    -1 gtk_clipboard_set_text ;

gtk-ui-backend ui-backend set-global

[ "ui.tools" ] main-vocab-hook set-global
