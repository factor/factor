! Copyright (C) 2010, 2011 Anton Gorenko, Philipp Bruschweiler.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types alien.strings
arrays assocs cairo.ffi classes.struct combinators continuations
destructors environment gdk-pixbuf.ffi gdk3.ffi glib.backend
glib.ffi gobject gobject.ffi gtk3.ffi io io.encodings.binary
io.encodings.utf8 io.files io.pathnames kernel libc literals
locals math math.bitwise math.functions math.order math.parser
math.vectors memoize namespaces opengl opengl.gl opengl.textures
prettyprint sequences strings system threads ui ui.backend
ui.backend.gtk3.input-methods ui.backend.x11.keys ui.clipboards
ui.event-loop ui.gadgets ui.gadgets.private ui.gadgets.worlds
ui.gestures ui.pixel-formats ui.private ui.render
ui.text.pango vocabs.loader ;
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

: update-scale-factor ( widget -- )
    gtk_widget_get_window gdk_window_get_scale_factor >float
    [ 1.0 > ] keep f ? gl-scale-factor set-global
    \ (cache-font-description) reset-memoized
    \ missing-font-metrics reset-memoized
    cached-layouts get-global clear-assoc
    ;

! User input

CONSTANT: events-mask
    flags{
        GDK_POINTER_MOTION_MASK
        GDK_ENTER_NOTIFY_MASK
        GDK_LEAVE_NOTIFY_MASK
        GDK_BUTTON_PRESS_MASK
        GDK_BUTTON_RELEASE_MASK
        GDK_KEY_PRESS_MASK
        GDK_KEY_RELEASE_MASK
        GDK_FOCUS_CHANGE_MASK
        GDK_SCROLL_MASK
        GDK_SMOOTH_SCROLL_MASK
    }

! hack for some window managers that have scale-factor set to
! 1x but the window still reports logical dimensions scaled
! vs. device pixel dimensions
SYMBOL: ui-scale-factor

: event-loc ( event -- loc )
    [ x>> ] [ y>> ] bi ui-scale-factor get-global [ [ * ] curry bi@ ] when* 2array ;

: event-dim ( event -- dim )
    [ width>> ] [ height>> ] bi ui-scale-factor get-global [ [ * ] curry bi@ ] when* 2array ;

: scroll-direction ( event -- pair )
    dup direction>> {
        { $ GDK_SCROLL_UP { 0 -1 } }
        { $ GDK_SCROLL_DOWN { 0 1 } }
        { $ GDK_SCROLL_LEFT { -1 0 } }
        { $ GDK_SCROLL_RIGHT { 1 0 } }
        { $ GDK_SCROLL_SMOOTH f }
    } at [ nip ] [ [ delta_x>> ] [ delta_y>> ] bi 2array ] if* ;

: on-motion ( drawable event user-data -- ? )
    drop swap
    [ event-loc ] dip gtk_widget_get_toplevel window
    move-hand fire-motion t ;

: on-leave ( drawable event user-data -- ? )
    3drop forget-rollover t ;

:: on-button-press ( drawable event user-data -- ? )
    drawable gtk_widget_get_toplevel window :> world
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

:: on-button-release ( drawable event user-data -- ? )
    drawable gtk_widget_get_toplevel window :> world
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

: on-scroll ( drawable event user-data -- ? )
    drop swap [
        [ scroll-direction ] [ event-loc ] bi
    ] dip gtk_widget_get_toplevel window send-scroll t ;

: key-sym ( keyval -- string/f action? )
    code>sym [ dup integer? [ gdk_keyval_to_unicode 1string ] when ] dip ;

: key-event>gesture ( event -- key-gesture )
    [ event-modifiers ] [ keyval>> key-sym ] [
        type>> GDK_KEY_PRESS = [ <key-down> ] [ <key-up> ] if
    ] tri ;

: on-key-press/release ( drawable event user-data -- ? )
    drop swap [ key-event>gesture ] [ gtk_widget_get_toplevel window ] bi* propagate-key-gesture f ;

: on-focus-in ( drawable event user-data -- ? )
    2drop gtk_widget_get_toplevel window focus-world f ;

: on-focus-out ( drawable event user-data -- ? )
    2drop gtk_widget_get_toplevel window unfocus-world f ;

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

! Render callback for GtkGLArea

: calc-ui-scale-factor ( glarea world -- )
    dim>> first
    [ gtk_widget_get_allocated_width ] dip /
    dup 1 number= [ drop f ] when ui-scale-factor set-global ;

: on-render ( glarea context user-data -- ? )
    2drop dup gtk_widget_get_toplevel window
    2dup calc-ui-scale-factor
    nip dup draw-world? [
        draw-world
    ] [ drop ] if
    f ;

: connect-render-signal ( drawable -- )
    "render" [ on-render yield ]
    GtkGLArea:render connect-signal ;

: on-resize ( glarea width height user-data -- )
    drop [ gl-unscale ] bi@ 2array swap gtk_widget_get_toplevel window
    dup active?>> [
        swap >>dim relayout
    ] [ 2drop ] if ;

: connect-resize-signal ( drawable -- )
    "resize" [ on-resize yield ]
    GtkGLArea:resize connect-signal ;

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

! Input methods

: on-retrieve-surrounding ( im-context win -- ? )
    window [ world-focus dup support-input-methods? ] [ f f ] if* [
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
    cairo_rectangle_int_t boa ;

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
    GtkWidget:focus-in-event im connect-signal-with-data
    win "focus-out-event" [ im-on-focus-out yield ]
    GtkWidget:focus-out-event im connect-signal-with-data
    win "destroy" [ im-on-destroy yield ]
    GtkWidget:destroy im connect-signal-with-data ;

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

M: gtk3-ui-backend (make-pixel-format) 2drop f ;

M: gtk3-ui-backend (free-pixel-format) drop ;

M: window-handle select-gl-context
    drawable>>
    [ gtk_gl_area_make_current ]
    [ gtk_gl_area_get_error f assert= ]
    [ gtk_gl_area_attach_buffers ] tri ;

M: window-handle flush-gl-context
    drawable>> gtk_gl_area_queue_render ;

! Window

: auto-position ( win loc -- )
    dup { 0 0 } = [
        drop dup window topmost-window =
        GTK_WIN_POS_CENTER GTK_WIN_POS_NONE ?
        gtk_window_set_position
    ] [ first2 gtk_window_move ] if ;

M:: gtk3-ui-backend (open-window) ( world -- )
    GTK_WINDOW_TOPLEVEL gtk_window_new :> win
    gtk_gl_area_new :> drawable
    drawable f gtk_gl_area_set_auto_render
    drawable 1 gtk_widget_set_hexpand
    drawable 1 gtk_widget_set_vexpand
    drawable GTK_ALIGN_FILL gtk_widget_set_halign
    drawable GTK_ALIGN_FILL gtk_widget_set_valign
    win drawable gtk_container_add
    gtk_im_multicontext_new :> im

    win drawable im <window-handle> world handle<<

    world win register-window

    world dim>> first2 [ >fixnum ] bi@ :> ( w h )
    win w h gtk_window_set_default_size
    win world window-loc>> auto-position

    win "factor" "Factor" [ utf8 string>alien ] bi@
    gtk_window_set_wmclass

    ! This must be done before realize due to #776.
    ! Add events to drawable (GtkGLArea), not window, so coordinates are correct
    drawable events-mask gtk_widget_add_events
    drawable 1 gtk_widget_set_can_focus

    win gtk_widget_realize

    ! Update scale factor from actual widget after realize
    win update-scale-factor

    ! And this must be done after and in this order due to #1307
    ! Connect mouse/input events to drawable so coordinates are drawable-relative
    drawable connect-user-input-signals
    win connect-win-state-signals
    win im configure-im
    world handle>> connect-configure-signal
    drawable connect-render-signal
    drawable connect-resize-signal

    win world window-controls>> configure-window-controls
    win gtk_widget_show_all ;

M: gtk3-ui-backend (close-window)
    window>> [ gtk_widget_destroy ] [ unregister-window ] bi
    event-loop? [ gtk_main_quit ] unless ;

M: gtk3-ui-backend resize-window
    [ handle>> window>> ] [ first2 [ >fixnum ] bi@ ] bi* gtk_window_resize ;

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
    setup-gl3-hooks
    load-icon
    init-clipboard
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

{ "ui.backend.gtk3" "ui.gadgets.editors" }
"ui.backend.gtk3.input-methods.editors" require-when
