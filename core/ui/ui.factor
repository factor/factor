! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors gadgets gadgets-buttons
gadgets-labels gadgets-panes gadgets-presentations
gadgets-scrolling gadgets-theme gadgets-viewports gadgets-lists
generic assocs io kernel math models namespaces prettyprint
queues sequences test threads sequences words timers ;

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
        init-ui ui-hook get-global call
    ] if ;

: draw-world? ( world -- ? )
    #! We don't draw deactivated worlds, or those with 0 size.
    #! On Windows, the latter case results in GL errors.
    dup world-active?
    over world-handle
    rot rect-dim [ zero? not ] all? and and ;

TUPLE: world-error world ;

C: world-error ( error world -- error )
    [ set-world-error-world ] keep
    [ set-delegate ] keep ;

M: world-error error.
    "An error occurred while drawing the world " write
    dup world-error-world pprint-short "." print
    "This world has been deactivated to prevent cascading errors." print
    delegate error. ;

: draw-world ( rect world -- )
    dup draw-world? [
        [
            dup world set [
                (draw-world)
            ] [
                over <world-error> debugger-window
                f swap set-world-active?
                drop
            ] recover
        ] with-scope
    ] [
        2drop
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

IN: shells

DEFER: ui
