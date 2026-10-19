! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Run on macOS with -run=ui.backend.cocoa.smoke-test [--legacy].
USING: accessors calendar cocoa cocoa.messages command-line continuations
debugger io kernel locals math namespaces sequences system threads ui ui.backend.cocoa
ui.gadgets ui.gadgets.packs ui.gadgets.worlds ui.pixel-formats ui.render ;
IN: ui.backend.cocoa.smoke-test

: smoke-error ( error -- ) print-error nl flush 1 exit ;

TUPLE: tracked-gadget < gadget grafted? { paints initial: 0 } { premature-paints initial: 0 } ;
M: tracked-gadget pref-dim* drop { 80 50 } ;
M: tracked-gadget graft* t >>grafted? drop ;
M: tracked-gadget draw-gadget*
    dup grafted?>> [ [ 1 + ] change-premature-paints ] unless
    [ 1 + ] change-paints drop ;

:: wait-for-paint ( gadget -- )
    nano-count 10,000,000,000 + :> deadline
    [ gadget paints>> zero? nano-count deadline < and ] [
        20 milliseconds sleep
    ] while
    gadget paints>> 0 > t assert= ;

:: exercise-window ( w pile child -- )
    child wait-for-paint
    100 milliseconds sleep
    tracked-gadget new { 80 50 } >>dim :> pending
    pile pending add-gadget drop
    ! Invoke native paint before the UI thread can drain the graft queue.
    w handle>> view>> dup -> bounds -> drawRect:
    pending wait-for-paint
    pending grafted?>> t assert=
    pending premature-paints>> 0 assert=
    "Cocoa smoke test passed" print flush
    close-all-windows ;

:: cocoa-smoke-test ( -- )
    [ smoke-error ] ui-error-hook set-global
    [
        tracked-gadget new :> child
        <pile> child add-gadget :> pile
        <world-attributes> "Cocoa paint ordering" >>title { 320 240 } >>pref-dim
        "--legacy" command-line get member? [
            { windowed double-buffered legacy-context } >>pixel-format-attributes
        ] when :> attributes
        pile attributes open-window* :> w
        [ w pile child [ exercise-window ] [ smoke-error ] recover ]
        "Cocoa paint ordering test" spawn drop
    ] with-ui ;

MAIN: cocoa-smoke-test
