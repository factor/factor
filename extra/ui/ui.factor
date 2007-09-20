! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs io kernel math models namespaces
prettyprint queues sequences threads sequences words timers
debugger ui.gadgets ui.gadgets.worlds ui.gadgets.tracks
ui.gestures ui.backend ui.render continuations init ;
IN: ui

! Assoc mapping aliens to gadgets
SYMBOL: windows

: window ( handle -- world ) windows get-global at ;

: window-focus ( handle -- gadget ) window world-focus ;

: register-window ( world handle -- )
    #! Add the new window just below the topmost window. Why?
    #! So that if the new window doesn't actually receive focus
    #! (eg, we're using focus follows mouse and the mouse is not
    #! in the new window when it appears) Factor doesn't get
    #! confused and send workspace operations to the new window,
    #! etc.
    swap 2array windows get-global push
    windows get-global dup length 1 >
    [ [ length 1- dup 1- ] keep exchange ] [ drop ] if ;

: unregister-window ( handle -- )
    windows global [ [ first = not ] curry* subset ] change-at ;

: raised-window ( world -- )
    windows get-global [ second eq? ] curry* find drop
    windows get-global [ length 1- ] keep exchange ;

: focus-world ( world -- )
    t over set-world-focused?
    dup raised-window
    focus-path f focus-gestures ;

: unfocus-world ( world -- )
    f over set-world-focused?
    focus-path f swap focus-gestures ;

: reset-world ( world -- )
    dup world-fonts clear-assoc
    dup unfocus-world
    f swap set-world-handle ;

: stop-world ( world -- )
    dup ungraft
    dup hand-clicked close-global
    dup hand-gadget close-global
    dup free-fonts
    reset-world ;

: open-world-window ( world -- )
    dup pref-dim over set-gadget-dim
    dup (open-world-window)
    dup draw-world ;

: open-window ( gadget title -- )
    >r [ 1 track, ] { 0 1 } make-track r>
    f <world> open-world-window ;

: find-window ( quot -- world )
    windows get 1 <column>
    [ gadget-child swap call ] curry* find-last nip ; inline

: restore-windows ( -- )
    windows get [ 1 <column> >array ] keep delete-all
    [ dup reset-world (open-world-window) ] each
    forget-rollover ;

: restore-windows? ( -- ? )
    windows get [ empty? not ] [ f ] if* ;

: update-hand ( world -- )
    dup hand-world get-global eq?
    [ hand-loc get-global swap move-hand ] [ drop ] if ;

: post-layout ( hash gadget -- )
    dup find-world dup [
        rot [
            >r screen-rect r> [ rect-union ] when*
        ] change-at
    ] [
        3drop
    ] if ;

: layout-queued ( -- hash )
    H{ } clone invalid [
        dup layout dupd post-layout
    ] queue-each ;

SYMBOL: ui-hook

: init-ui ( -- )
    <queue> \ invalid set-global
    V{ } clone windows set-global ;

: start-ui ( -- )
    init-timers
    restore-windows? [
        restore-windows
    ] [
        init-ui ui-hook get call
    ] if ;

: redraw-worlds ( hash -- )
    [
        swap dup update-hand
        dup world-handle [ draw-world ] [ 2drop ] if
    ] assoc-each ;

: ui-step ( -- )
    [
        do-timers layout-queued redraw-worlds 10 sleep
    ] assert-depth ;

: ui-running ( quot -- )
    t \ ui-running set-global
    [ f \ ui-running set-global ] [ ] cleanup ; inline

: ui-running? ( -- ? )
    \ ui-running get-global ;

[ f \ ui-running set-global ] "ui" add-init-hook

HOOK: ui ui-backend ( -- )

MAIN: ui

: with-ui ( quot -- )
    ui-running? [
        call
    ] [
        f windows set-global
        ui-hook [ ui ] with-variable
    ] if ;

: ui-try ( quot -- ) [ ui-error ] recover ;
