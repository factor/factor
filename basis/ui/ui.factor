! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs io kernel math models namespaces make
dlists deques sequences threads sequences words ui.gadgets
ui.gadgets.worlds ui.gadgets.tracks ui.gestures ui.backend
ui.render continuations init combinators hashtables
concurrency.flags sets accessors calendar call ;
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
    windows global [ [ first = not ] with filter ] change-at ;

: raised-window ( world -- )
    windows get-global
    [ [ second eq? ] with find drop ] keep
    [ nth ] [ delete-nth ] [ nip ] 2tri push ;

: focus-gestures ( new old -- )
    drop-prefix <reversed>
    T{ lose-focus } swap each-gesture
    T{ gain-focus } swap each-gesture ;

: focus-world ( world -- )
    t >>focused?
    dup raised-window
    focus-path f focus-gestures ;

: unfocus-world ( world -- )
    f >>focused?
    focus-path f swap focus-gestures ;

M: world graft*
    [ (open-window) ]
    [ [ title>> ] keep set-title ]
    [ request-focus ] tri ;

: reset-world ( world -- )
    #! This is used when a window is being closed, but also
    #! when restoring saved worlds on image startup.
    [ fonts>> clear-assoc ]
    [ unfocus-world ]
    [ f >>handle drop ] tri ;

: (ungraft-world) ( world -- )
    [ free-fonts ]
    [ hand-clicked close-global ]
    [ hand-gadget close-global ] tri ;

M: world ungraft*
    [ (ungraft-world) ]
    [ handle>> (close-window) ]
    [ reset-world ] tri ;

: find-window ( quot -- world )
    windows get values
    [ gadget-child swap call ] with find-last nip ; inline

SYMBOL: ui-hook

: init-ui ( -- )
    <dlist> \ graft-queue set-global
    <dlist> \ layout-queue set-global
    <dlist> \ gesture-queue set-global
    V{ } clone windows set-global ;

: restore-gadget-later ( gadget -- )
    dup graft-state>> {
        { { f f } [ ] }
        { { f t } [ ] }
        { { t t } [ { f f } >>graft-state ] }
        { { t f } [ dup unqueue-graft { f f } >>graft-state ] }
    } case graft-later ;

: restore-gadget ( gadget -- )
    dup restore-gadget-later
    children>> [ restore-gadget ] each ;

: restore-world ( world -- )
    dup reset-world restore-gadget ;

: restore-windows ( -- )
    windows get [ values ] keep delete-all
    [ restore-world ] each
    forget-rollover ;

: restore-windows? ( -- ? )
    windows get empty? not ;

: update-hand ( world -- )
    dup hand-world get-global eq?
    [ hand-loc get-global swap move-hand ] [ drop ] if ;

: layout-queued ( -- seq )
    [
        in-layout? on
        layout-queue [
            dup layout find-world [ , ] when*
        ] slurp-deque
    ] { } make prune ;

: redraw-worlds ( seq -- )
    [ dup update-hand draw-world ] each ;

: notify ( gadget -- )
    dup graft-state>>
    [ first { f f } { t t } ? >>graft-state ] keep
    {
        { { f t } [ dup activate-control graft* ] }
        { { t f } [ dup deactivate-control ungraft* ] }
    } case ;

: notify-queued ( -- )
    graft-queue [ notify ] slurp-deque ;

: send-queued-gestures ( -- )
    gesture-queue [ send-queued-gesture notify-queued ] slurp-deque ;

: update-ui ( -- )
    [
        [
            notify-queued
            layout-queued
            redraw-worlds
            send-queued-gestures
        ] call( -- )
    ] [ ui-error ] recover ;

SYMBOL: ui-thread

: ui-running ( quot -- )
    t \ ui-running set-global
    [ f \ ui-running set-global ] [ ] cleanup ; inline

: ui-running? ( -- ? )
    \ ui-running get-global ;

: update-ui-loop ( -- )
    [ ui-running? ui-thread get-global self eq? and ]
    [ ui-notify-flag get lower-flag update-ui ]
    while ;

: start-ui-thread ( -- )
    [ self ui-thread set-global update-ui-loop ]
    "UI update" spawn drop ;

: open-world-window ( world -- )
    dup pref-dim >>dim dup relayout graft ;

: open-window ( gadget title -- )
    f <world> open-world-window ;

: set-fullscreen? ( ? gadget -- )
    find-world set-fullscreen* ;

: fullscreen? ( gadget -- ? )
    find-world fullscreen* ;

: raise-window ( gadget -- )
    find-world raise-window* ;

HOOK: close-window ui-backend ( gadget -- )

M: object close-window
    find-world [ ungraft ] when* ;

: start-ui ( -- )
    restore-windows? [
        restore-windows
    ] [
        init-ui ui-hook get call
    ] if
    notify-ui-thread start-ui-thread ;

[
    f \ ui-running set-global
    <flag> ui-notify-flag set-global
] "ui" add-init-hook

HOOK: ui ui-backend ( -- )

MAIN: ui

: with-ui ( quot -- )
    ui-running? [
        call
    ] [
        f windows set-global
        [
            ui-hook set
            ui
        ] with-scope
    ] if ;
