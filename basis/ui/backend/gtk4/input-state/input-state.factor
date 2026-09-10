! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Raw input snapshots shared by the UI and the optional game-input backend.
USING: accessors arrays assocs kernel locals math math.vectors
namespaces sequences ;
IN: ui.backend.gtk4.input-state

TUPLE: input-state keycodes buttons position motion scroll ;

: <input-state> ( -- state )
    H{ } clone 5 f <array> f { 0 0 } { 0 0 } input-state boa ;

SYMBOL: current-input-state
current-input-state [ <input-state> ] initialize

: clear-input-state ( -- )
    <input-state> current-input-state set-global ;

: record-key ( keycode pressed? -- )
    [ t swap current-input-state get-global keycodes>> set-at ]
    [ current-input-state get-global keycodes>> delete-at ] if ;

:: record-button ( button pressed? -- )
    button { 1 2 3 8 9 } index [
        pressed? swap current-input-state get-global buttons>> set-nth
    ] when* ;

:: record-motion ( position -- )
    current-input-state get-global :> state
    state position>> [ position swap v- ] [ { 0 0 } ] if* :> delta
    state position >>position [ delta v+ ] change-motion drop ;

: record-scroll ( direction -- )
    current-input-state get-global swap '[ _ v+ ] change-scroll drop ;

: reset-pointer-deltas ( -- )
    current-input-state get-global { 0 0 } >>motion { 0 0 } >>scroll drop ;
