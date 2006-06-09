! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays gadgets gadgets-labels gadgets-theme
gadgets-viewports hashtables kernel math namespaces queues
sequences threads ;

! Assoc mapping aliens to gadgets
SYMBOL: windows

: window ( handle -- world ) windows get-global assoc ;

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
        dup hand-gadget get-global find-world eq?
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
    do-timers
    [ layout-queued ] make-hash hash-values [
        dup update-hand
        dup world-handle [ dup draw-world ] when
        drop
    ] each
    10 sleep ;

: <status-bar> ( -- gadget ) "" <label> dup highlight-theme ;

GENERIC: gadget-title ( gadget -- string )

M: gadget gadget-title drop "Factor" ;

M: world gadget-title world-gadget gadget-title ;

TUPLE: titled-gadget title ;

M: titled-gadget gadget-title titled-gadget-title ;

M: titled-gadget pref-dim* viewport-dim ;

M: titled-gadget layout*
    dup rect-dim swap gadget-child set-gadget-dim ;

C: titled-gadget ( gadget title -- )
    dup delegate>gadget
    [ set-titled-gadget-title ] keep
    [ add-gadget ] keep ;

: update-title ( gadget -- )
    dup gadget-parent dup world?
    [ >r gadget-title r> set-title ] [ 2drop ] if ;

: open-window ( gadget -- )
    <status-bar> <world> dup prefer open-window* ;

: open-titled-window ( gadget title -- )
    <titled-gadget> open-window ;

: restore-windows ( -- )
    windows get [ second ] map
    0 windows get set-length
    [ dup reset-world open-window* ] each
    forget-rollover ;

: restore-windows? ( -- ? )
    windows get [ empty? not ] [ f ] if* ;

: (open-tool) ( arg cons setter -- )
    >r call tuck r> call open-window ; inline

: open-tool ( arg pred cons setter -- )
    rot drop (open-tool) ;

: call-tool ( arg gadget pred cons setter -- )
    >r >r find-parent dup [
        r> drop r> call
    ] [
        drop r> r> (open-tool)
    ] if ;

: start-world ( world -- )
    dup add-notify
    dup gadget-title over set-title
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
    f over set-world-focused?
    #! Sent when native window loses focus.
    focused-ancestors f swap focus-gestures ;

: close-world ( world -- )
    dup hand-clicked close-global
    dup hand-gadget close-global
    f over request-focus*
    dup remove-notify
    dup free-fonts
    reset-world ;
