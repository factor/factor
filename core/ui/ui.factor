! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors gadgets gadgets-buttons
gadgets-labels gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-theme gadgets-viewports gadgets-lists
generic hashtables io kernel math models namespaces prettyprint
queues sequences test threads sequences words timers ;

: update-hand ( world -- )
    dup hand-world get-global eq?
    [ hand-loc get-global swap move-hand ] [ drop ] if ;

: post-layout ( gadget -- )
    find-world [ dup world-handle set ] when* ;

: layout-queued ( -- hash )
    [
        invalid [ dup layout post-layout ] queue-each
    ] make-hash ;

SYMBOL: ui-hook

: init-ui ( -- )
    <queue> \ invalid set-global
    V{ } clone windows set-global ;

: start-ui ( -- )
    init-timers
    restore-windows? [
        restore-windows
    ] [
        init-ui ui-hook get-global call
    ] if ;

: ui-step ( -- )
    [
        do-timers
        layout-queued [
            nip
            dup update-hand
            dup world-handle [ dup draw-world ] when
            drop
        ] hash-each
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
