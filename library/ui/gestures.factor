! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays generic hashtables kernel math models namespaces
queues sequences words ;

: gestures ( gadget -- seq )
    delegates [ class "gestures" word-prop ] map [ ] subset ;

: set-gestures ( class hash -- ) "gestures" set-word-prop ;

: handle-gesture* ( gesture gadget -- )
    tuck gestures hash-stack [ call f ] [ drop t ] if* ;

: handle-gesture ( gesture gadget -- ? )
    #! If a gadget's handle-gesture* generic returns t, the
    #! event was not consumed and is passed on to the gadget's
    #! parent. This word returns t if no gadget handled the
    #! gesture, otherwise returns f.
    [ dupd handle-gesture* ] each-parent nip ;

: user-input ( str gadget -- )
    [ dupd user-input* ] each-parent 2drop ;

! Gesture objects
TUPLE: motion ;
TUPLE: drag # ;
TUPLE: button-up mods # ;
TUPLE: button-down mods # ;
TUPLE: mouse-scroll ;
TUPLE: mouse-enter ;
TUPLE: mouse-leave ;
TUPLE: lose-focus ;
TUPLE: gain-focus ;

! Higher-level actions
TUPLE: cut-action ;
TUPLE: copy-action ;
TUPLE: paste-action ;
TUPLE: delete-action ;
TUPLE: select-all-action ;

: handle-action ( gadget constructor -- )
    execute swap handle-gesture drop ; inline

: generalize-gesture ( gesture -- gesture )
    #! Strip button number from drag/button-up/button-down.
    tuple>array 1 head* >tuple ;

! Modifiers
SYMBOL: C+
SYMBOL: A+
SYMBOL: M+
SYMBOL: S+

TUPLE: key-down mods sym ;
TUPLE: key-up mods sym ;

! Hand state

! Note that these are only really useful inside an event
! handler, and that the locations hand-loc and hand-click-loc
! are in the co-ordinate system of the world which contains
! the gadget in question.
SYMBOL: hand-gadget
SYMBOL: hand-world
SYMBOL: hand-loc
{ 0 0 } hand-loc set-global

SYMBOL: hand-clicked
SYMBOL: hand-click-loc
SYMBOL: hand-click#
SYMBOL: hand-last-button
SYMBOL: hand-last-time
0 hand-last-button set-global
0 hand-last-time set-global

SYMBOL: hand-buttons
V{ } clone hand-buttons set-global

SYMBOL: scroll-direction
{ 0 0 } scroll-direction set-global

SYMBOL: double-click-timeout
100 double-click-timeout set-global

: button-gesture ( gesture -- )
    hand-clicked get-global 2dup handle-gesture [
        >r generalize-gesture r> handle-gesture drop
    ] [
        2drop
    ] if ;

: drag-gesture ( -- )
    hand-buttons get-global first <drag> button-gesture ;

: fire-motion ( -- )
    #! Fire a motion gesture to the gadget underneath the hand,
    #! and if a mouse button is down, fire a drag gesture to the
    #! gadget that was clicked.
    hand-buttons get-global empty? [
        T{ motion } hand-gadget get-global handle-gesture drop
    ] [
        drag-gesture
    ] if ;

: each-gesture ( gesture seq -- )
    [ handle-gesture* drop ] each-with ;

: hand-gestures ( new old -- )
    drop-prefix <reversed>
    T{ mouse-leave } swap each-gesture
    T{ mouse-enter } swap each-gesture ;

: forget-rollover ( -- )
    #! After we restore the UI, send mouse leave events to all
    #! gadgets that were under the mouse at the time of the
    #! save, since the mouse is in a different location now.
    f hand-world set-global
    hand-gadget get-global >r
    f hand-gadget set-global
    f r> parents hand-gestures ;

: focus-gestures ( new old -- )
    drop-prefix <reversed>
    T{ lose-focus } swap each-gesture
    T{ gain-focus } swap each-gesture ;

: focus-receiver ( world -- seq )
    #! If the world is not focused, we want focus-gestures to
    #! only send focus-lost and not focus-gained.
    dup world-focused? [ focused-ancestors ] [ drop f ] if ;

: request-focus* ( gadget world -- )
    dup focused-ancestors >r
    [ set-world-focus ] keep
    focus-receiver r> focus-gestures ;

: request-focus ( gadget -- )
    dup focusable-child swap find-world
    [ request-focus* ] [ drop ] if* ;

: modifier ( mod modifiers -- seq )
    [ second swap bitand 0 > ] subset-with
    [ first ] map prune f like ;

: drag-loc ( -- loc )
    hand-loc get-global hand-click-loc get-global v- ;

: hand-rel ( gadget -- loc )
    hand-loc get-global relative-loc ;

: hand-click-rel ( gadget -- loc )
    hand-click-loc get-global relative-loc ;

: multi-click? ( button -- ? )
    millis hand-last-time get - double-click-timeout get <=
    swap hand-last-button get = and ;

: update-click# ( button -- )
    global [
        multi-click? [
            hand-click# inc
        ] [
            1 hand-click# set
        ] if
    ] bind ;

: update-clicked ( button -- )
    hand-last-button set-global
    hand-gadget get-global hand-clicked set-global
    hand-loc get-global hand-click-loc set-global
    millis hand-last-time set-global ;
 
: under-hand ( -- seq )
    #! A sequence whose first element is the world and last is
    #! the current gadget, with all parents in between.
    hand-gadget get-global parents <reversed> ;

: move-hand ( loc world -- )
    dup hand-world set-global
    under-hand >r over hand-loc set-global
    pick-up hand-gadget set-global
    menu-mode? get-global [ update-clicked ] when
    under-hand r> hand-gestures ;

: send-button-down ( gesture loc world -- )
    move-hand
    dup button-down-#
    dup update-click#
    dup update-clicked
    hand-buttons get-global push
    button-gesture ;

: send-button-up ( gesture loc world -- )
    move-hand
    dup button-up-# hand-buttons get-global delete
    button-gesture ;

: send-wheel ( direction loc world -- )
    move-hand
    scroll-direction set-global
    T{ mouse-scroll } hand-gadget get-global handle-gesture
    drop ;

: send-action ( world gesture -- )
    swap world-focus handle-gesture drop ;

: resend-button-down ( gesture world -- )
    hand-loc get-global swap send-button-down ;

: resend-button-up  ( gesture world -- )
    hand-loc get-global swap send-button-up ;

world H{
    { T{ key-down f { C+ } "x" } [ T{ cut-action } send-action ] }
    { T{ key-down f { C+ } "c" } [ T{ copy-action } send-action ] }
    { T{ key-down f { C+ } "v" } [ T{ paste-action } send-action ] }
    { T{ key-down f { C+ } "a" } [ T{ select-all-action } send-action ] }
    { T{ button-down f { C+ } 1 } [ T{ button-down f f 3 } swap resend-button-down ] }
    { T{ button-down f { A+ } 1 } [ T{ button-down f f 2 } swap resend-button-down ] }
    { T{ button-up f { C+ } 1 } [ T{ button-up f f 3 } swap resend-button-up ] }
    { T{ button-up f { A+ } 1 } [ T{ button-up f f 2 } swap resend-button-up ] }
} set-gestures
