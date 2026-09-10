! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings arrays
assocs cairo.ffi classes.struct combinators concurrency.promises
continuations destructors environment gdk4.ffi gio.ffi glib.backend
glib.ffi gobject gobject.ffi gtk4.ffi io.encodings.string
io.encodings.utf8 kernel literals locals math math.bitwise math.vectors memoize namespaces
opengl sequences strings system threads ui ui.backend
ui.backend.gtk4.input-methods ui.backend.x11.keys ui.clipboards
ui.event-loop ui.gadgets ui.gadgets.private ui.gadgets.worlds
ui.gestures ui.pixel-formats ui.private ui.render ui.text.pango
vocabs.loader ;
IN: ui.backend.gtk4

SINGLETON: gtk4-ui-backend

TUPLE: window-handle window drawable im-context ;
C: <window-handle> window-handle

! GTK owns the display's clipboards. Reading text is asynchronous; suspend
! the Factor caller while the GLib loop continues servicing the request.
TUPLE: gtk4-clipboard handle ;
C: <gtk4-clipboard> gtk4-clipboard

SYMBOL: clipboard-requests
SYMBOL: next-clipboard-request
clipboard-requests [ H{ } clone ] initialize
next-clipboard-request [ 1 ] initialize

:: on-clipboard-text ( clipboard result request -- )
    request alien-address clipboard-requests get-global delete-at* drop :> promise
    clipboard result f gdk_clipboard_read_text_finish
    [ [ &g_free utf8 alien>string ] with-destructors ] [ f ] if*
    promise fulfill ;

:: read-clipboard ( clipboard -- promise )
    <promise> :> promise
    next-clipboard-request counter :> id
    promise id clipboard-requests get-global set-at
    clipboard f [ on-clipboard-text ] GAsyncReadyCallback
    id <alien> gdk_clipboard_read_text_async
    promise ;

M: gtk4-clipboard clipboard-contents
    handle>> read-clipboard ?promise ;

M: gtk4-clipboard set-clipboard-contents
    [ [ 0 = ] trim-tail utf8 string>alien ] [ handle>> ] bi*
    swap gdk_clipboard_set_text ;

: init-clipboard ( -- )
    gdk_display_get_default
    [ gdk_display_get_clipboard <gtk4-clipboard> clipboard set-global ]
    [ gdk_display_get_primary_clipboard <gtk4-clipboard> selection set-global ] bi ;

: update-scale-factor ( widget -- )
    gtk_widget_get_scale_factor >float dup 1.0 > [ drop f ] unless
    dup gl-scale-factor get-global = [ drop ] [
        gl-scale-factor set-global
        \ (cache-font-description) reset-memoized
        \ missing-font-metrics reset-memoized
        cached-layouts get-global clear-assoc
    ] if ;

: controller-world ( controller -- world )
    gtk_event_controller_get_widget gtk_widget_get_root window ;

! GDK4's Super mask differs from X11's Mod4 mask.
CONSTANT: gtk4-modifiers
    {
        ${ S+ GDK_SHIFT_MASK }
        ${ C+ GDK_CONTROL_MASK }
        ${ A+ GDK_ALT_MASK }
        ${ M+ GDK_SUPER_MASK }
    }

: controller-modifiers ( controller -- modifiers )
    gtk_event_controller_get_current_event_state gtk4-modifiers modifier ;

: key-sym ( keyval -- string/f action? )
    code>sym [ dup integer? [ gdk_keyval_to_unicode 1string ] when ] dip ;

: on-motion ( controller x y data -- )
    drop 2array swap controller-world move-hand fire-motion ;

: on-leave ( controller data -- )
    2drop forget-rollover ;

:: on-pressed ( gesture count x y data -- )
    gesture gtk_event_controller_get_widget gtk_widget_grab_focus drop
    gesture gtk_gesture_single_get_current_button :> button
    button { 8 9 } member? [
        gesture controller-modifiers button <button-down>
        x y 2array gesture controller-world send-button-down
    ] unless ;

:: on-released ( gesture count x y data -- )
    gesture controller-world :> world
    gesture gtk_gesture_single_get_current_button {
        { 8 [ world left-action send-action ] }
        { 9 [ world right-action send-action ] }
        [ gesture controller-modifiers swap <button-up>
          x y 2array world send-button-up ]
    } case ;

: on-scroll ( controller dx dy data -- ? )
    drop 2array swap controller-world
    [ hand-loc get ] dip send-scroll t ;

! Input methods receive the current key event before Factor shortcuts.
: gadget-cursor-location ( gadget -- rectangle )
    [ screen-loc ] [ cursor-loc&dim ] bi [ v+ ] dip
    [ first2 [ >fixnum ] bi@ ] bi@ cairo_rectangle_int_t boa ;

:: filter-key ( controller -- ? )
    controller controller-world :> world
    world handle>> im-context>> :> im
    world world-focus :> gadget
    gadget support-input-methods? [
        im gadget gadget-cursor-location gtk_im_context_set_cursor_location
        im controller gtk_event_controller_get_current_event
        gtk_im_context_filter_keypress
    ] [ im gtk_im_context_reset f ] if ;

:: on-key-pressed ( controller keyval keycode state data -- ? )
    controller filter-key [
        state gtk4-modifiers modifier keyval key-sym <key-down>
        controller controller-world propagate-key-gesture
    ] unless t ;

:: on-key-released ( controller keyval keycode state data -- )
    controller filter-key [
        state gtk4-modifiers modifier keyval key-sym <key-up>
        controller controller-world propagate-key-gesture
    ] unless ;

: on-focus-in ( controller data -- )
    drop controller-world
    [ handle>> im-context>> gtk_im_context_focus_in ] [ focus-world ] bi ;

: on-focus-out ( controller data -- )
    drop controller-world
    [ handle>> im-context>> [ gtk_im_context_focus_out ]
      [ gtk_im_context_reset ] bi ] [ unfocus-world ] bi ;

:: connect-user-input ( drawable -- )
    gtk_event_controller_motion_new :> motion
    motion "motion" [ on-motion yield ] GtkEventControllerMotion:motion connect-signal
    motion "leave" [ on-leave yield ] GtkEventControllerMotion:leave connect-signal
    drawable motion gtk_widget_add_controller

    gtk_gesture_click_new :> click
    click 0 gtk_gesture_single_set_button
    click "pressed" [ on-pressed yield ] GtkGestureClick:pressed connect-signal
    click "released" [ on-released yield ] GtkGestureClick:released connect-signal
    drawable click gtk_widget_add_controller

    GTK_EVENT_CONTROLLER_SCROLL_BOTH_AXES gtk_event_controller_scroll_new :> scroll
    scroll "scroll" [ on-scroll yield ] GtkEventControllerScroll:scroll connect-signal
    drawable scroll gtk_widget_add_controller

    gtk_event_controller_key_new :> key
    key "key-pressed" [ on-key-pressed yield ] GtkEventControllerKey:key-pressed connect-signal
    key "key-released" [ on-key-released yield ] GtkEventControllerKey:key-released connect-signal
    drawable key gtk_widget_add_controller

    gtk_event_controller_focus_new :> focus
    focus "enter" [ on-focus-in yield ] GtkEventControllerFocus:enter connect-signal
    focus "leave" [ on-focus-out yield ] GtkEventControllerFocus:leave connect-signal
    drawable focus gtk_widget_add_controller ;

: on-commit ( im text win -- )
    [ drop ] [ utf8 alien>string ] [ window ] tri* user-input ;

: cursor>byte-offset ( text cursor -- offset )
    head utf8 encode length ;

:: on-retrieve-surrounding ( im win -- ? )
    win window world-focus :> gadget
    gadget support-input-methods? [
        gadget cursor-surrounding :> ( text cursor )
        ! GTK expects a UTF-8 byte offset, while editors use character offsets.
        im text utf8 string>alien -1
        text cursor cursor>byte-offset gtk_im_context_set_surrounding t
    ] [ f ] if ;

: on-delete-surrounding ( im offset count win -- ? )
    window world-focus dup support-input-methods?
    [ delete-cursor-surrounding t ] [ 3drop f ] if nip ;

:: configure-im ( win drawable im -- )
    im drawable gtk_im_context_set_client_widget
    im f gtk_im_context_set_use_preedit
    im "commit" [ on-commit yield ] GtkIMContext:commit win connect-signal-with-data
    im "retrieve-surrounding" [ on-retrieve-surrounding yield ]
    GtkIMContext:retrieve-surrounding win connect-signal-with-data
    im "delete-surrounding" [ on-delete-surrounding yield ]
    GtkIMContext:delete-surrounding win connect-signal-with-data ;

! GtkGLArea owns the presentation framebuffer and may replace it between
! frames. Paint inside render as well as servicing Factor's redraw requests.
: on-render ( area context data -- ? )
    2drop dup update-scale-factor gtk_widget_get_root window
    dup gl-render-state>> [
        dup draw-world? [
            [ dup set-gl-context draw-world* gl-error ] [ nip ui-error ] recover
        ] [ drop ] if
    ] [ drop ] if t ;

: on-resize ( area width height data -- )
    3drop dup [ gtk_widget_get_width ] [ gtk_widget_get_height ] bi 2array
    dup [ 0 > ] all? [
        swap gtk_widget_get_root window t >>active? swap >>dim relayout
    ] [ 2drop ] if ;

: on-map ( win data -- )
    drop window relayout ;

: on-close ( win data -- ? )
    drop window ungraft t ;

:: configure-window-controls ( win controls -- )
    win resize-handles controls member-eq? gtk_window_set_resizable
    win close-button controls member-eq? gtk_window_set_deletable
    win { normal-title-bar small-title-bar }
    [ controls member-eq? ] any? gtk_window_set_decorated
    win dialog-window controls member-eq? gtk_window_set_modal ;

M: gtk4-ui-backend (make-pixel-format) 2drop f ;
M: gtk4-ui-backend (free-pixel-format) drop ;

M: gtk4-ui-backend current-gl-context gdk_gl_context_get_current ;

M: window-handle select-gl-context
    drawable>>
    [ gtk_gl_area_make_current ]
    [ gtk_gl_area_get_error [ message>> utf8 alien>string throw ] when* ]
    [
        ! The area has no framebuffer until GTK gives it a positive size.
        ! Attaching at initial realization otherwise leaves GL_INVALID_OPERATION.
        dup [ gtk_widget_get_width ] [ gtk_widget_get_height ] bi
        [ 0 > ] bi@ and [ gtk_gl_area_attach_buffers ] [ drop ] if
    ] tri ;

M: window-handle flush-gl-context
    drawable>> gtk_gl_area_queue_render ;

M:: gtk4-ui-backend (open-window) ( world -- )
    gtk_window_new :> win
    gtk_gl_area_new :> drawable
    drawable f gtk_gl_area_set_use_es
    drawable 3 3 gtk_gl_area_set_required_version
    drawable f gtk_gl_area_set_auto_render
    drawable t gtk_widget_set_hexpand
    drawable t gtk_widget_set_vexpand
    drawable t gtk_widget_set_focusable
    win drawable gtk_window_set_child
    gtk_im_multicontext_new :> im
    win drawable im <window-handle> world handle<<
    world win register-window
    win world dim>> first2 [ >fixnum ] bi@ gtk_window_set_default_size
    win world window-controls>> configure-window-controls
    win "factor" utf8 string>alien gtk_window_set_icon_name
    win drawable im configure-im
    drawable connect-user-input
    win "close-request" [ on-close yield ] GtkWindow:close-request connect-signal
    win "map" [ on-map yield ] GtkWidget:map connect-signal
    drawable "render" [ on-render ] GtkGLArea:render connect-signal
    drawable "resize" [ on-resize ] GtkGLArea:resize connect-signal
    win gtk_widget_realize
    drawable gtk_widget_realize
    drawable update-scale-factor
    win gtk_window_present
    drawable gtk_widget_grab_focus drop ;

SYMBOL: main-loop

:: on-clipboard-stored ( clipboard result loop -- )
    clipboard result f gdk_clipboard_store_finish drop
    loop [ g_main_loop_quit ] [ g_main_loop_unref ] bi ;

: store-clipboard-and-quit ( loop -- )
    [ clipboard get-global handle>> 0 f
      [ on-clipboard-stored ] GAsyncReadyCallback ] dip
    g_main_loop_ref gdk_clipboard_store_async ;

M: gtk4-ui-backend stop-event-loop
    main-loop get-global [ store-clipboard-and-quit ] when* ;

M: gtk4-ui-backend (close-window)
    [ im-context>> f gtk_im_context_set_client_widget ]
    [ window>> [ gtk_window_destroy ] [ unregister-window ] bi ]
    [ im-context>> g_object_unref ] tri
    event-loop? [ stop-event-loop ] unless ;

M: gtk4-ui-backend resize-window
    [ handle>> window>> ] [ first2 [ >fixnum ] bi@ ] bi*
    gtk_window_set_default_size ;

M: gtk4-ui-backend set-title
    swap [ handle>> window>> ] [ utf8 string>alien ] bi* gtk_window_set_title ;

M: gtk4-ui-backend (set-fullscreen)
    [ handle>> window>> ] dip
    [ gtk_window_fullscreen ] [ gtk_window_unfullscreen ] if ;

M: gtk4-ui-backend (fullscreen?)
    handle>> window>> gtk_window_is_fullscreen ;

M: gtk4-ui-backend raise-window*
    handle>> window>> gtk_window_present ;

! GTK4 has no backend-neutral seat grab. Focus and hide the cursor for
! Factor's captured-input mode; pointer confinement is compositor-specific.
M: gtk4-ui-backend (grab-input)
    drawable>> [ gtk_widget_grab_focus drop ]
    [ "none" utf8 string>alien gtk_widget_set_cursor_from_name ] bi ;

M: gtk4-ui-backend (ungrab-input)
    drawable>> f gtk_widget_set_cursor ;

M: gtk4-ui-backend beep
    gdk_display_get_default gdk_display_beep ;

M:: gtk4-ui-backend system-alert ( caption text -- )
    f GTK_DIALOG_MODAL GTK_MESSAGE_WARNING GTK_BUTTONS_OK
    "%s" utf8 string>alien caption utf8 string>alien gtk_message_dialog_new :> dialog
    dialog "%s" utf8 string>alien text utf8 string>alien gtk_message_dialog_format_secondary_text
    dialog "response" [ 2drop gtk_window_destroy ] GtkDialog:response connect-signal
    dialog gtk_window_present ;

M: gtk4-ui-backend (with-ui)
    ! Factor's GLSL shaders require desktop GL. GDK's shared context must
    ! use the same API (not its default GLES choice on some drivers).
    "GDK_DEBUG" os-env dup empty?
    [ drop "gl-prefer-gl" ] [ ",gl-prefer-gl" append ] if
    "GDK_DEBUG" set-os-env
    gtk_init_check [ "Unable to initialize GTK4" throw ] unless
    setup-gl3-hooks init-clipboard
    f f g_main_loop_new main-loop set-global
    [
        start-ui
        [ [ [ main-loop get-global g_main_loop_run ] with-timer ] with-io ] with-destructors
    ] [
        main-loop get-global g_main_loop_unref
        f main-loop set-global
    ] finally ;

M: gtk4-ui-backend ui-backend-available?
    "WAYLAND_DISPLAY" os-env empty?
    "DISPLAY" os-env empty? and not ;

os { linux freebsd } member? [
    gtk4-ui-backend ui-backend set-global
] when

{ "ui.backend.gtk4" "ui.gadgets.editors" }
"ui.backend.gtk4.input-methods.editors" require-when
