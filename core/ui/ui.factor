! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors gadgets gadgets-buttons
gadgets-labels gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-theme gadgets-viewports gadgets-lists
generic hashtables io kernel math models namespaces prettyprint
queues sequences test threads sequences words timers ;

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
                over <world-error> debugger-window
                f over set-world-active?
            ] recover
        ] with-scope
    ] when drop ;

IN: shells

DEFER: ui
