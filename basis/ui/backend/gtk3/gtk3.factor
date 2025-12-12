! Copyright (C) 2010, 2011 Anton Gorenko, Philipp Bruschweiler.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types alien.strings
arrays assocs classes.struct combinators continuations
destructors environment gdk3.ffi gdk-pixbuf.ffi
glib glib.ffi gobject gobject.ffi gtk3.ffi io.encodings.binary
io.encodings.utf8 io.files io.pathnames kernel libc literals
locals math math.order math.bitwise math.functions math.parser
math.vectors namespaces opengl sequences strings system threads
ui ui.backend
ui.backend.x11.keys ui.clipboards ui.event-loop ui.gadgets
ui.gadgets.private ui.gadgets.worlds ui.gestures
ui.pixel-formats ui.private vocabs.loader ;
IN: ui.backend.gtk3

SINGLETON: gtk3-ui-backend

TUPLE: window-handle window drawable im-context fullscreen? ;

: <window-handle> ( window drawable im-context -- window-handle )
    f window-handle boa ;

! Clipboards

TUPLE: gtk3-clipboard handle ;

C: <gtk3-clipboard> gtk3-clipboard

M: gtk3-clipboard clipboard-contents
    [
        handle>> gtk_clipboard_wait_for_text
        [ &g_free utf8 alien>string ] [ f ] if*
    ] with-destructors ;

: save-global-clipboard ( -- )
    clipboard get-global handle>> gtk_clipboard_store ;

M: gtk3-clipboard set-clipboard-contents
    swap [ handle>> ] [ [ 0 = ] trim-tail utf8 string>alien ] bi*
    -1 gtk_clipboard_set_text
    save-global-clipboard ;

: init-clipboard ( -- )
    selection "PRIMARY"
    clipboard "CLIPBOARD"
    [
        utf8 string>alien gdk_atom_intern_static_string
        gtk_clipboard_get <gtk3-clipboard> swap set-global
    ] 2bi@ ;

: detect-scale-factor ( -- n )
    "GDK_SCALE" os-env [
        gdk_screen_get_default gdk_screen_get_resolution 96.0 / round
    ] [
        string>number
    ] if-empty 1.0 max ;

: init-scale-factor ( -- )
    detect-scale-factor
    [ 1.0 > ] keep f ? gl-scale-factor set-global ;

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

: event-loc ( event -- loc )
    [ x>> ] [ y>> ] bi [ gl-unscale ] bi@ 2array ;

: event-dim ( event -- dim )
    [ width>> ] [ height>> ] bi [ gl-unscale ] bi@ 2array ;

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

: on-button-press ( win event user-data -- ? )
    3drop t ;

: on-button-release ( win event user-data -- ? )
    3drop t ;

: on-scroll ( win event user-data -- ? )
    drop swap [
        [ scroll-direction ] [ event-loc ] bi
    ] dip window send-scroll t ;

: on-key-press/release ( win event user-data -- ? )
    3drop t ;

: on-focus-in ( win event user-data -- ? )
    2drop window focus-world f ;

: on-focus-out ( win event user-data -- ? )
    2drop window unfocus-world f ;

CONSTANT: default-icon-path "resource:misc/icons/icon_128x128.png"

: default-icon-data ( -- byte-array/f )
    [
        default-icon-path binary file-contents
    ] [ drop f ] recover ;

SYMBOL: icon-data

icon-data [ default-icon-data ] initialize

: vocab-icon-data ( vocab-name -- byte-array )
    dup vocab-dir { "icon.png" "icon.ico" } [
        append-path vocab-append-path
    ] 2with map default-icon-path suffix
    [ file-exists? ] find nip binary file-contents ;

: load-icon ( -- )
    icon-data get [
        [
            data>GInputStream &g_object_unref
            GInputStream>GdkPixbuf gtk_window_set_default_icon
        ] with-destructors
    ] when* ;

:: connect-user-input-signals ( win -- )
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
    win "key-press-event" [ on-key-press/release yield ]
    GtkWidget:key-press-event connect-signal
    win "key-release-event" [ on-key-press/release yield ]
    GtkWidget:key-release-event connect-signal
    win "focus-in-event" [ on-focus-in yield ]
    GtkWidget:focus-in-event connect-signal
    win "focus-out-event" [ on-focus-out yield ]
    GtkWidget:focus-out-event connect-signal ;

! Window state events

: on-configure ( window event user-data -- ? )
    drop swap dup gtk_widget_get_toplevel [ = ] keep window dup active?>> [
        swap [ swap ] dip
        [ event-loc >>window-loc drop ]
        [ event-dim >>dim relayout-1 ] if
    ] [ 3drop ] if f ;

: on-map ( win event user-data -- ? )
    2drop window t >>active? drop t ;

: on-delete ( win event user-data -- ? )
    2drop window ungraft t ;

: connect-configure-signal ( winhandle -- )
    [ window>> ] [ drawable>> ] bi "configure-event"
    [ on-configure yield ] GtkWidget:configure-event
    [ connect-signal ] 2curry bi@ ;

:: connect-win-state-signals ( win -- )
    win "delete-event" [ on-delete yield ]
    GtkWidget:delete-event connect-signal
    win "map-event" [ on-map yield ]
    GtkWidget:map-event connect-signal ;

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
        { dialog-window 0 }
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
        { dialog-window 0 }
    }

: set-window-hint ( win controls -- )
    {
        { [ dialog-window over member-eq? ] [ drop GDK_WINDOW_TYPE_HINT_DIALOG ] }
        { [ small-title-bar over member-eq? ] [ drop GDK_WINDOW_TYPE_HINT_UTILITY ] }
        [ drop GDK_WINDOW_TYPE_HINT_NORMAL ]
    } cond gtk_window_set_type_hint ;

: configure-window-controls ( win controls -- )
    [
        set-window-hint
    ] [
        [ gtk_widget_get_window ] dip
        window-controls>decor-flags symbols>flags
        GDK_DECOR_BORDER bitor gdk_window_set_decorations
    ] [
        [ gtk_widget_get_window ] dip
        window-controls>func-flags symbols>flags
        GDK_FUNC_MOVE bitor gdk_window_set_functions
    ] 2tri ;

M: window-handle select-gl-context
    drop ;

M: window-handle flush-gl-context
    drop ;

! Window

: auto-position ( win loc -- )
    dup { 0 0 } = [
        drop dup window topmost-window =
        GTK_WIN_POS_CENTER GTK_WIN_POS_NONE ?
        gtk_window_set_position
    ] [ first2 gtk_window_move ] if ;

M:: gtk3-ui-backend (open-window) ( world -- )
    gl-scale-factor get-global [ init-scale-factor ] unless

    GTK_WINDOW_TOPLEVEL gtk_window_new :> win
    gtk_gl_area_new :> drawable
    win drawable gtk_container_add
    gtk_im_multicontext_new :> im

    win drawable im <window-handle> world handle<<

    world win register-window

    win world [ window-loc>> auto-position ]
    [ dim>> first2 [ gl-scale >fixnum ] bi@ gtk_window_set_default_size ] 2bi

    win "factor" "Factor" [ utf8 string>alien ] bi@
    gtk_window_set_wmclass

    ! This must be done before realize due to #776.
    win events-mask gtk_widget_add_events

    win gtk_widget_realize

    ! And this must be done after and in this order due to #1307
    win connect-user-input-signals
    win connect-win-state-signals
    world handle>> connect-configure-signal

    win world window-controls>> configure-window-controls
    win gtk_widget_show_all ;

M: gtk3-ui-backend (close-window)
    window>> [ gtk_widget_destroy ] [ unregister-window ] bi
    event-loop? [ gtk_main_quit ] unless ;

M: gtk3-ui-backend resize-window
    [ handle>> window>> ] [ first2 [ gl-scale >fixnum ] bi@ ] bi* gtk_window_resize ;

M: gtk3-ui-backend set-title
    swap [ handle>> window>> ] [ utf8 string>alien ] bi*
    gtk_window_set_title ;

M: gtk3-ui-backend (set-fullscreen)
    [ handle>> ] dip [ >>fullscreen? ] keep
    [ window>> ] dip
    [ gtk_window_fullscreen ]
    [ gtk_window_unfullscreen ] if ;

M: gtk3-ui-backend (fullscreen?)
    handle>> fullscreen?>> ;

M: gtk3-ui-backend raise-window*
    handle>> window>> gtk_window_present ;

: set-cursor ( win cursor -- )
    [
        [ gtk_widget_get_window ] dip
        gdk_cursor_new &gdk_cursor_unref
        gdk_window_set_cursor
    ] with-destructors ;

M: gtk3-ui-backend (grab-input)
    window>>
    [ gtk_grab_add ] [ GDK_BLANK_CURSOR set-cursor ] bi ;

M: gtk3-ui-backend (ungrab-input)
    window>>
    [ gtk_grab_remove ] [ GDK_LEFT_PTR set-cursor ] bi ;

! Misc.

M: gtk3-ui-backend beep
    gdk_beep ;

M:: gtk3-ui-backend system-alert ( caption text -- )
    [
        f GTK_DIALOG_MODAL GTK_MESSAGE_WARNING GTK_BUTTONS_OK
        caption utf8 string>alien f
        gtk_message_dialog_new &gtk_widget_destroy
        [
            text utf8 string>alien f
            gtk_message_dialog_format_secondary_text
        ] [ gtk_dialog_run drop ] bi
    ] with-destructors ;

M: gtk3-ui-backend (with-ui)
    f f gtk_init_check [ "Unable to initialize GTK" throw ] unless
    load-icon
    init-clipboard
    init-scale-factor
    start-ui
    [
        [ [ gtk_main ] with-timer ] with-io
    ] with-destructors ;

M: gtk3-ui-backend stop-event-loop
    gtk_main_quit ;

os { linux freebsd } member? [
    gtk3-ui-backend ui-backend set-global
] when

M: gtk3-ui-backend ui-backend-available?
    "DISPLAY" os-env empty? not ;
