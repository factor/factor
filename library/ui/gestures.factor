! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: gadgets-labels gadgets-layouts hashtables kernel math
namespaces queues sequences threads ;

: action ( gadget gesture -- quot )
    swap gadget-gestures ?hash ;

: init-gestures ( gadget -- gestures )
    dup gadget-gestures
    [ ] [ H{ } clone dup rot set-gadget-gestures ] ?if ;

: set-action ( gadget quot gesture -- )
    rot init-gestures set-hash ;

: add-actions ( gadget hash -- )
    dup [ >r init-gestures r> hash-update ] [ 2drop ] if ;

: handle-gesture* ( gesture gadget -- ? )
    tuck gadget-gestures ?hash dup [ call f ] [ 2drop t ] if ;

: handle-gesture ( gesture gadget -- ? )
    #! If a gadget's handle-gesture* generic returns t, the
    #! event was not consumed and is passed on to the gadget's
    #! parent. This word returns t if no gadget handled the
    #! gesture, otherwise returns f.
    [ dupd handle-gesture* ] each-parent nip ;

: user-input ( str gadget -- )
    [ dupd user-input* ] each-parent 2drop ;

! Mouse gestures are arrays where the first element is one of:
SYMBOL: motion
SYMBOL: drag
SYMBOL: button-up
SYMBOL: button-down
SYMBOL: wheel-up
SYMBOL: wheel-down
SYMBOL: mouse-enter
SYMBOL: mouse-leave

SYMBOL: lose-focus
SYMBOL: gain-focus

! Hand state

! Note that these are only really useful inside an event
! handler, and that the locations hand-loc and hand-click-loc
! are in the co-ordinate system of the world which contains
! the gadget in question.
SYMBOL: hand-gadget
SYMBOL: hand-loc
{ 0 0 0 } hand-loc set-global

SYMBOL: hand-clicked
SYMBOL: hand-click-loc

SYMBOL: hand-buttons
V{ } clone hand-buttons set-global

: button-gesture ( button gesture -- )
    #! Send a gesture like [ button-down 2 ]; if nobody
    #! handles it, send [ button-down ].
    swap hand-clicked get-global 3dup >r add r> handle-gesture
    [ nip handle-gesture drop ] [ 3drop ] if ;

: drag-gesture ( -- )
    #! Send a gesture like [ drag 2 ]; if nobody handles it,
    #! send [ drag ].
    hand-buttons get-global first [ drag ] button-gesture ;

: fire-motion ( -- )
    #! Fire a motion gesture to the gadget underneath the hand,
    #! and if a mouse button is down, fire a drag gesture to the
    #! gadget that was clicked.
    [ motion ] hand-gadget get-global handle-gesture drop
    hand-buttons get-global empty? [ drag-gesture ] unless ;

: each-gesture ( gesture seq -- )
    [ handle-gesture* drop ] each-with ;

: hand-gestures ( new old -- )
    drop-prefix <reversed>
    [ mouse-leave ] swap each-gesture
    fire-motion
    [ mouse-enter ] swap each-gesture ;

: focus-gestures ( new old -- )
    drop-prefix <reversed>
    [ lose-focus ] swap each-gesture
    [ gain-focus ] swap each-gesture ;

: request-focus* ( gadget world -- )
    dup focused-ancestors >r
    [ set-world-focus ] keep
    focused-ancestors r> focus-gestures ;

: request-focus ( gadget -- )
    dup focusable-child swap find-world request-focus* ;

: modifier ( mod modifiers -- seq )
    [ second swap bitand 0 > ] subset-with
    [ first ] map ;

: drag-loc ( -- loc )
    hand-loc get-global hand-click-loc get-global v- ;

: hand-click-rel ( gadget -- loc )
    hand-click-loc get-global relative-loc ;

: relevant-help ( seq -- help )
    [ gadget-help ] map [ ] find nip ;

: show-message ( string/f -- )
    #! Show a message in the status bar.
    world-status [ set-label-text* ] [ drop ] if* ;

: update-help ( -- )
    #! Update mouse-over help message.
    hand-gadget get-global parents [ relevant-help ] keep
    dup empty? [ 2drop ] [ peek show-message ] if ;

: under-hand ( -- seq )
    #! A sequence whose first element is the world and last is
    #! the current gadget, with all parents in between.
    hand-gadget get-global parents <reversed> ;

: move-hand ( loc world -- )
    under-hand >r over hand-loc set-global
    pick-up hand-gadget set-global
    under-hand r> hand-gestures update-help ;

: update-clicked ( loc world -- )
    move-hand
    hand-gadget get-global hand-clicked set-global
    hand-loc get-global hand-click-loc set-global ;

: send-button-down ( button# loc world -- )
    update-clicked
    dup hand-buttons get-global push
    [ button-down ] button-gesture ;

: send-button-up ( button# loc world -- )
    move-hand
    dup hand-buttons get-global delete
    [ button-up ] button-gesture ;

: send-wheel ( up/down loc world -- )
    move-hand
    [ wheel-up ] [ wheel-down ] ?
    hand-gadget get-global handle-gesture drop ;
