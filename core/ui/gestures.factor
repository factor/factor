! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays generic assocs kernel math models namespaces
queues sequences words strings timers ;

: set-gestures ( class hash -- ) "gestures" set-word-prop ;

GENERIC: handle-gesture* ( gadget gesture delegate -- ? )

: default-gesture-handler ( gadget gesture delegate -- ? )
    class "gestures" word-prop at dup
    [ call f ] [ 2drop t ] if ;

M: object handle-gesture* default-gesture-handler ;

: handle-gesture ( gesture gadget -- ? )
    tuck delegates [ >r 2dup r> handle-gesture* ] all? 2nip ;

: send-gesture ( gesture gadget -- ? )
    [ dupd handle-gesture ] each-parent nip ;

: user-input ( str gadget -- )
    over empty?
    [ [ dupd user-input* ] each-parent ] unless
    2drop ;

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

: generalize-gesture ( gesture -- newgesture )
    tuple>array 1 head* >tuple ;

! Modifiers
SYMBOL: C+
SYMBOL: A+
SYMBOL: M+
SYMBOL: S+

TUPLE: key-down mods sym ;

: prepare-key-gesture [ S+ rot remove swap ] unless ;

C: key-down ( mods sym action? -- key-down )
    >r prepare-key-gesture r>
    [ set-key-down-sym ] keep
    [ set-key-down-mods ] keep ;

TUPLE: key-up mods sym ;

C: key-up ( mods sym action? -- key-up )
    >r prepare-key-gesture r>
    [ set-key-up-sym ] keep
    [ set-key-up-mods ] keep ;

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
300 double-click-timeout set-global

: button-gesture ( gesture -- )
    hand-clicked get-global 2dup send-gesture [
        >r generalize-gesture r> send-gesture drop
    ] [
        2drop
    ] if ;

: drag-gesture ( -- )
    hand-buttons get-global first <drag> button-gesture ;

TUPLE: drag-timer ;

M: drag-timer tick drop drag-gesture ;

<drag-timer> drag-timer set-global

: start-drag-timer ( -- )
    hand-buttons get-global empty? [
        drag-timer get-global 100 100 add-timer
    ] when ;

: stop-drag-timer ( -- )
    hand-buttons get-global empty? [
        drag-timer get-global remove-timer
    ] when ;

: fire-motion ( -- )
    hand-buttons get-global empty? [
        T{ motion } hand-gadget get-global send-gesture drop
    ] [
        drag-gesture
    ] if ;

: each-gesture ( gesture seq -- )
    [ handle-gesture drop ] each-with ;

: hand-gestures ( new old -- )
    drop-prefix <reversed>
    T{ mouse-leave } swap each-gesture
    T{ mouse-enter } swap each-gesture ;

: forget-rollover ( -- )
    f hand-world set-global
    hand-gadget get-global >r
    f hand-gadget set-global
    f r> parents hand-gestures ;

: send-lose-focus ( gadget -- )
    T{ lose-focus } swap handle-gesture drop ;

: send-gain-focus ( gadget -- )
    T{ gain-focus } swap handle-gesture drop ;

: focus-child ( child gadget ? -- )
    [
        dup gadget-focus [
            dup send-lose-focus
            f swap t focus-child
        ] when*
        dupd set-gadget-focus [
            send-gain-focus
        ] when*
    ] [
        set-gadget-focus
    ] if ;

: (request-focus) ( child gadget ? -- )
    pick gadget-parent pick eq? [
        >r >r dup gadget-parent dup r> r>
        [ (request-focus) ] keep
    ] unless focus-child ;

: request-focus ( gadget -- )
    dup focusable-child swap find-world {
        { [ dup not ] [ 2drop ] }
        { [ 2dup eq? ] [ 2drop ] }
        { [ t ] [ dup world-focused? (request-focus) ] }
    } cond ;

: modifier ( mod modifiers -- seq )
    [ second swap bitand 0 > ] subset-with
    0 <column> prune dup empty? [ drop f ] [ >array ] if ;

: drag-loc ( -- loc )
    hand-loc get-global hand-click-loc get-global v- ;

: hand-rel ( gadget -- loc )
    hand-loc get-global swap screen-loc v- ;

: hand-click-rel ( gadget -- loc )
    hand-click-loc get-global swap screen-loc v- ;

: multi-click? ( button -- ? )
    millis hand-last-time get - double-click-timeout get <=
    swap hand-last-button get = and ;

: update-click# ( button -- )
    global [
        dup multi-click? [
            hand-click# inc
        ] [
            1 hand-click# set
        ] if
        hand-last-button set
        millis hand-last-time set
    ] bind ;

: update-clicked ( -- )
    hand-gadget get-global hand-clicked set-global
    hand-loc get-global hand-click-loc set-global ;

: under-hand ( -- seq )
    hand-gadget get-global parents <reversed> ;

: move-hand ( loc world -- )
    dup hand-world set-global
    under-hand >r over hand-loc set-global
    pick-up hand-gadget set-global
    under-hand r> hand-gestures ;

: send-button-down ( gesture loc world -- )
    move-hand
    start-drag-timer
    dup button-down-#
    dup update-click# hand-buttons get-global push
    update-clicked
    button-gesture ;

: send-button-up ( gesture loc world -- )
    move-hand
    dup button-up-# hand-buttons get-global delete
    stop-drag-timer
    button-gesture ;

: send-wheel ( direction loc world -- )
    move-hand
    scroll-direction set-global
    T{ mouse-scroll } hand-gadget get-global send-gesture
    drop ;

: world-focus ( world -- gadget )
    dup gadget-focus [ world-focus ] [ ] ?if ;

: send-action ( world gesture -- )
    swap world-focus send-gesture drop ;

: resend-button-down ( gesture world -- )
    hand-loc get-global swap send-button-down ;

: resend-button-up  ( gesture world -- )
    hand-loc get-global swap send-button-up ;

GENERIC: gesture>string ( gesture -- string/f )

: modifiers>string ( modifiers -- string )
    [ word-name ] map concat >string ;

M: key-down gesture>string
    dup key-down-mods modifiers>string
    swap key-down-sym append ;

M: button-up gesture>string
    [
        dup button-up-mods modifiers>string %
        "Click Button" %
        button-up-# [ " " % # ] when*
    ] "" make ;

M: button-down gesture>string
    [
        dup button-down-mods modifiers>string %
        "Press Button" %
        button-down-# [ " " % # ] when*
    ] "" make ;

M: object gesture>string drop f ;

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
