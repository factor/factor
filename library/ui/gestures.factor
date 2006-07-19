! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel math models namespaces queues
sequences words ;

: (gestures) ( gadget -- )
    [
        dup "gestures" word-prop [ , ] when* delegate (gestures)
    ] when* ;

: gestures ( gadget -- seq ) [ (gestures) ] { } make ;

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
TUPLE: button-up # ;
TUPLE: button-down # ;
TUPLE: wheel-up ;
TUPLE: wheel-down ;
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

GENERIC: with-button ( button# tuple -- tuple )

M: drag with-button drop <drag> ;
M: button-up with-button drop <button-up> ;
M: button-down with-button drop <button-down> ;

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
SYMBOL: hand-loc
{ 0 0 } hand-loc set-global

SYMBOL: hand-clicked
SYMBOL: hand-click-loc

SYMBOL: hand-buttons
V{ } clone hand-buttons set-global

: button-gesture ( button gesture -- )
    #! Send a gesture like T{ button-down f 2 }; if nobody
    #! handles it, send T{ button-down }.
    hand-clicked get-global
    3dup >r with-button r> handle-gesture
    [ handle-gesture 2drop ] [ 3drop ] if ;

: drag-gesture ( -- )
    #! Send a gesture like T{ drag f 2 }; if nobody handles it,
    #! send T{ drag }.
    hand-buttons get-global first T{ drag } button-gesture ;

: fire-motion ( -- )
    #! Fire a motion gesture to the gadget underneath the hand,
    #! and if a mouse button is down, fire a drag gesture to the
    #! gadget that was clicked.
    T{ motion } hand-gadget get-global handle-gesture drop
    hand-buttons get-global empty? [ drag-gesture ] unless ;

: each-gesture ( gesture seq -- )
    [ handle-gesture* drop ] each-with ;

: hand-gestures ( new old -- )
    drop-prefix <reversed>
    T{ mouse-leave } swap each-gesture
    fire-motion
    T{ mouse-enter } swap each-gesture ;

: forget-rollover ( -- )
    #! After we restore the UI, send mouse leave events to all
    #! gadgets that were under the mouse at the time of the
    #! save, since the mouse is in a different location now.
    f hand-gadget [ get-global ] 2keep set-global
    parents hand-gestures ;

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
    dup focusable-child swap find-world request-focus* ;

: modifier ( mod modifiers -- seq )
    [ second swap bitand 0 > ] subset-with
    [ first ] map f like ;

: drag-loc ( -- loc )
    hand-loc get-global hand-click-loc get-global v- ;

: hand-rel ( gadget -- loc )
    hand-loc get-global relative-loc ;

: hand-click-rel ( gadget -- loc )
    hand-click-loc get-global relative-loc ;

: relevant-help ( seq -- help )
    [ gadget-help ] map [ ] find nip ;

: show-message ( string/f world -- )
    #! Show a message in the status bar.
    world-status set-model ;

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
    T{ button-down } button-gesture ;

: send-button-up ( button# loc world -- )
    move-hand
    dup hand-buttons get-global delete
    T{ button-up } button-gesture ;

: send-wheel ( up/down loc world -- )
    move-hand
    T{ wheel-up } T{ wheel-down } ?
    hand-gadget get-global handle-gesture drop ;

: send-action ( world gesture -- ? )
    swap world-focus handle-gesture ;

world H{
    { T{ key-down f { C+ } "x" } [ T{ cut-action } send-action ] }
    { T{ key-down f { C+ } "c" } [ T{ copy-action } send-action ] }
    { T{ key-down f { C+ } "v" } [ T{ paste-action } send-action ] }
    { T{ key-down f { C+ } "a" } [ T{ select-all-action } send-action ] }
} set-gestures
