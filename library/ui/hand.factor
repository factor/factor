! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic io kernel lists math matrices namespaces
prettyprint sequences vectors ;

! The hand is a special gadget that holds mouse position and
! mouse button click state.

! Some comments on the slots:
! - hand-gadget is the gadget under the mouse position
! - hand-clicked is the most recently clicked gadget
! - hand-focus is the gadget holding keyboard focus
TUPLE: hand click-loc click-rel clicked buttons gadget focus ;

C: hand ( -- hand )
    dup delegate>gadget V{ } clone over set-hand-buttons ;

: button-gesture ( button gesture -- )
    swap add hand get hand-clicked handle-gesture drop ;

: button/ ( n -- )
    update-clicked
    dup hand get hand-buttons push
    [ button-down ] button-gesture ;

: button\ ( n -- )
    dup hand get hand-buttons delete
    [ button-up ] button-gesture ;

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

: each-gesture ( gesture seq -- )
    [ handle-gesture* drop ] each-with ;

: hand-gestures ( new old -- )
    drop-prefix reverse-slice
    [ mouse-leave ] swap each-gesture
    hand get fire-motion
    [ mouse-enter ] swap each-gesture ;

: focus-gestures ( new old -- )
    drop-prefix reverse-slice
    [ lose-focus ] swap each-gesture
    [ gain-focus ] swap each-gesture ;

: focused-ancestors ( hand -- seq )
    hand get hand-focus parents reverse-slice ;

: request-focus ( gadget -- )
    focusable-child focused-ancestors >r
    hand get set-hand-focus focused-ancestors
    r> focus-gestures ;

: drag-loc ( gadget -- loc )
    hand get [ relative ] keep hand-click-rel v- ;
