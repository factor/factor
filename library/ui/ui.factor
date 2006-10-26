! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors gadgets gadgets-buttons
gadgets-labels gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-theme gadgets-viewports generic
hashtables io kernel math models namespaces prettyprint queues
sequences test threads help sequences words ;

! Assoc mapping aliens to gadgets
SYMBOL: windows

: window ( handle -- world ) windows get-global assoc ;

: window-focus ( handle -- gadget ) window world-focus ;

: register-window ( world handle -- )
    swap 2array windows get-global push ;

: unregister-window ( handle -- )
    windows get-global
    [ first = not ] subset-with
    windows set-global  ;

: raised-window ( world -- )
    windows get-global [ second eq? ] find-with drop
    windows get-global [ length 1- ] keep exchange ;

: update-hand ( gadget -- )
    find-world [
        dup hand-world get-global eq?
        [ hand-loc get-global swap move-hand ] [ drop ] if
    ] when* ;

: post-layout ( gadget -- )
    find-world [ dup world-handle set ] when* ;

: layout-queued ( -- )
    invalid dup queue-empty? [
        drop
    ] [
        deque dup layout post-layout layout-queued
    ] if ;

: init-ui ( -- )
    <queue> \ invalid set-global
    V{ } clone windows set-global ;

: ui-step ( -- )
    [
        do-timers
        [ layout-queued ] make-hash hash-values [
            dup update-hand
            dup world-handle [ dup draw-world ] when
            drop
        ] each
        10 sleep
    ] assert-depth ;

TUPLE: titled-gadget title child ;

M: titled-gadget gadget-title titled-gadget-title ;

M: titled-gadget focusable-child* titled-gadget-child ;

C: titled-gadget ( gadget title -- )
    [ set-titled-gadget-title ] keep
    { { f set-titled-gadget-child f @center } } make-frame* ;

: open-window ( world -- )
    dup pref-dim over set-gadget-dim
    dup open-window* draw-world ;

: open-titled-window ( gadget title -- )
    <model> <titled-gadget> <world> open-window ;

: find-window ( quot -- world )
    windows get 1 <column>
    [ world-gadget swap call ] find-last-with nip ; inline

: start-world ( world -- )
    dup graft
    dup relayout
    world-gadget request-focus ;

: close-global ( world global -- )
    dup get-global find-world rot eq?
    [ f swap set-global ] [ drop ] if ;

: focus-world ( world -- )
    #! Sent when native window receives focus
    t over set-world-focused?
    dup raised-window
    focused-ancestors f focus-gestures ;

: unfocus-world ( world -- )
    #! Sent when native window loses focus.
    f over set-world-focused?
    focused-ancestors f swap focus-gestures ;

: reset-world ( world -- )
    dup unfocus-world
    dup ungraft
    f over set-world-focus
    f over set-world-handle
    world-fonts clear-hash ;

: close-world ( world -- )
    dup hand-clicked close-global
    dup hand-gadget close-global
    dup free-fonts
    reset-world ;

: restore-windows ( -- )
    windows get [ 1 <column> >array ] keep delete-all
    [ dup reset-world open-window* ] each
    forget-rollover ;

: restore-windows? ( -- ? )
    windows get [ empty? not ] [ f ] if* ;

: <toolbar> ( target classes -- toolbar )
    [ commands "toolbar" swap hash ] map concat
    [ <command-button> ] map-with
    make-shelf ;

: command-description ( command -- element )
    dup command-name swap command-gesture gesture>string
    2array ;

: commands. ( commands -- )
    [ command-gesture key-down? ] subset
    [ command-description ] map
    { { $strong "Command" } { $strong "Shortcut" } } add*
    $table ;

: $commands ( elt -- )
    first2 swap commands hash commands. ;

TUPLE: labelled-gadget content ;

C: labelled-gadget ( gadget title -- gadget )
    {
        { [ <label> dup reverse-video-theme ] f f @top }
        { f set-labelled-gadget-content f @center }
    } make-frame* ;

M: labelled-gadget focusable-child* labelled-gadget-content ;

: <labelled-pane> ( model quot title -- gadget )
    >r <pane-control> <scroller> r> <labelled-gadget> ;

: pane-window ( quot title -- )
    >r make-pane <scroller> r> open-titled-window ;

: error-window ( error -- )
    [ print-error ] "Error" pane-window ;

: ui-try ( quot -- )
    [ error-window ] recover ;

TUPLE: world-error world ;

C: world-error ( error world -- error )
    [ set-world-error-world ] keep
    [ set-delegate ] keep ;

M: world-error error.
    "An error occurred while drawing the world " write
    dup world-error-world pprint-short "." print
    "This world has been deactivated to prevent cascading errors." print
    delegate error. ;

: draw-world? ( world -- ? )
    #! We don't draw deactivated worlds, or those with 0 size.
    #! On Windows, the latter case results in GL errors.
    dup world-active? swap rect-dim [ zero? not ] all? and ;

: draw-world ( world -- )
    dup draw-world? [
        [
            dup world set [
                dup (draw-world)
            ] [
                over <world-error> error-window
                f over set-world-active?
            ] recover
        ] with-scope
    ] when drop ;

IN: shells

DEFER: ui
