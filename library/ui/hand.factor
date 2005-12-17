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

: (button-gesture) ( buttons gesture -- )
    swap hand get hand-clicked 3dup >r append r> handle-gesture
    [ 3drop ] [ nip handle-gesture drop ] if ;

: button-gesture ( button gesture -- )
    #! Send a gesture like [ button-down 2 ]; if nobody
    #! handles it, send [ button-down ].
    >r unit r> (button-gesture) ;

: drag-gesture ( -- )
    #! Send a gesture like [ drag 2 ]; if nobody handles it,
    #! send [ drag ].
    hand get hand-buttons [ drag ] (button-gesture) ;

: fire-motion ( hand -- )
    #! Fire a motion gesture to the gadget underneath the hand,
    #! and if a mouse button is down, fire a drag gesture to the
    #! gadget that was clicked.
    [ motion ] over hand-gadget handle-gesture drop
    hand-buttons empty? [ drag-gesture ] unless ;

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
