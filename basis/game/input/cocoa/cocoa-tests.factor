USING: accessors arrays assocs combinators game.input game.input.cocoa
 game.input.scancodes kernel locals namespaces sequences tools.test
ui.backend.input-state ;
IN: game.input.cocoa.tests

! Unknown keycodes must not set key-undefined or index past the map.
{ t t t f } [
    H{ { 13 t } { 123 t } { 60 t } { -1 t } { 999 t } }
    cocoa-keycodes>hid {
        [ key-w swap nth ] [ key-left-arrow swap nth ]
        [ key-right-shift swap nth ] [ key-undefined swap nth ]
    } cleave
] unit-test

: mouse-deltas ( mouse -- deltas )
    { [ dx>> ] [ dy>> ] [ scroll-dx>> ] [ scroll-dy>> ] } cleave 4array ;

:: mouse-snapshots ( -- old-deltas new-deltas new-button old-button )
    clear-input-state
    current-input-state get-global
        { 12 -5 } >>motion { 1 -2 } >>scroll drop
    1 t record-button
    cocoa-mouse :> old
    reset-pointer-deltas
    1 f record-button
    cocoa-mouse :> new
    old mouse-deltas new mouse-deltas
    new buttons>> first old buttons>> first ;

! Snapshots remain independent of later events and pointer resets.
{ { 12 -5 1 -2 } { 0 0 0 0 } f t } [ mouse-snapshots ] unit-test
