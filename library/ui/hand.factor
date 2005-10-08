! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic io kernel lists math matrices namespaces
prettyprint sdl sequences vectors ;

! The hand is a special gadget that holds mouse position and
! mouse button click state.

! Some comments on the slots:
! - hand-gadget is the gadget under the mouse position
! - hand-clicked is the most recently clicked gadget
! - hand-focus is the gadget holding keyboard focus
TUPLE: hand click-loc click-rel clicked buttons gadget focus ;

C: hand ( -- hand )
    dup gadget-delegate { } clone over set-hand-buttons ;

: button/ ( n hand -- )
    dup hand-gadget over set-hand-clicked
    dup screen-loc over set-hand-click-loc
    dup hand-gadget over relative over set-hand-click-rel
    hand-buttons push ;

: button\ ( n hand -- )
    hand-buttons delete ;

: drag-gesture ( hand gadget gesture -- )
    #! Send a gesture like [ drag 2 ].
    rot hand-buttons first add swap handle-gesture drop ;

: fire-motion ( hand -- )
    #! Fire a motion gesture to the gadget underneath the hand,
    #! and if a mouse button is down, fire a drag gesture to the
    #! gadget that was clicked.
    [ motion ] over hand-gadget handle-gesture drop
    dup hand-buttons empty?
    [ dup dup hand-clicked [ drag ] drag-gesture ] unless drop ;

: drop-prefix ( l1 l2 -- l1 l2 )
    2dup and [ 2dup 2car eq? [ 2cdr drop-prefix ] when ] when ;

: each-gesture ( gesture seq -- )
    [ handle-gesture* drop ] each-with ;

: hand-gestures ( hand new old -- )
    drop-prefix
    reverse [ mouse-leave ] swap each-gesture
    swap fire-motion
    [ mouse-enter ] swap each-gesture ;

: focus-gestures ( new old -- )
    drop-prefix
    reverse [ lose-focus ] swap each-gesture
    [ gain-focus ] swap each-gesture ;

: request-focus ( gadget -- )
    focusable-child
    hand get dup hand-focus parents-down >r
    dupd set-hand-focus parents-down r> focus-gestures ;

: drag-loc ( gadget -- loc )
    hand get [ relative ] keep hand-click-rel v- ;
