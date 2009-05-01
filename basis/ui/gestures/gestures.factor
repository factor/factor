! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel math math.order models
namespaces make sequences words strings system hashtables math.parser
math.vectors classes.tuple classes boxes calendar alarms combinators
sets columns fry deques ui.gadgets ui.gadgets.private unicode.case
unicode.categories combinators.short-circuit ;
IN: ui.gestures

GENERIC: handle-gesture ( gesture gadget -- ? )

M: object handle-gesture
    [ nip ]
    [ class superclasses [ "gestures" word-prop ] map assoc-stack ] 2bi
    dup [ call( gadget -- ) f ] [ 2drop t ] if ;

: set-gestures ( class hash -- ) "gestures" set-word-prop ;

: gesture-queue ( -- deque ) \ gesture-queue get ;

GENERIC: send-queued-gesture ( request -- )

TUPLE: send-gesture gesture gadget ;

M: send-gesture send-queued-gesture
    [ gesture>> ] [ gadget>> ] bi handle-gesture drop ;

: queue-gesture ( ... class -- )
    boa gesture-queue push-front notify-ui-thread ; inline

: send-gesture ( gesture gadget -- )
    \ send-gesture queue-gesture ;

: each-gesture ( gesture seq -- ) [ send-gesture ] with each ;

TUPLE: propagate-gesture gesture gadget ;

: resend-gesture ( gesture gadget -- ? )
    [ handle-gesture ] with each-parent ;

M: propagate-gesture send-queued-gesture
    [ gesture>> ] [ gadget>> ] bi resend-gesture drop ;

: propagate-gesture ( gesture gadget -- )
    \ propagate-gesture queue-gesture ;

TUPLE: propagate-key-gesture gesture world ;

: world-focus ( world -- gadget )
    dup focus>> [ world-focus ] [ ] ?if ;

M: propagate-key-gesture send-queued-gesture
    [ gesture>> ] [ world>> world-focus ] bi
    [ handle-gesture ] with each-parent drop ;

: propagate-key-gesture ( gesture world -- )
    \ propagate-key-gesture queue-gesture ;

TUPLE: user-input string world ;

M: user-input send-queued-gesture
    [ string>> ] [ world>> world-focus ] bi
    [ user-input* ] with each-parent drop ;

: user-input ( string world -- )
    '[ _ \ user-input queue-gesture ] unless-empty ;

! Gesture objects
TUPLE: drag # ;             C: <drag> drag
TUPLE: button-up mods # ;   C: <button-up> button-up
TUPLE: button-down mods # ; C: <button-down> button-down

SINGLETONS:
motion
mouse-scroll
mouse-enter mouse-leave
lose-focus gain-focus ;

! Higher-level actions
SINGLETONS:
undo-action redo-action
cut-action copy-action paste-action
delete-action select-all-action
left-action right-action up-action down-action
zoom-in-action zoom-out-action ;

UNION: action
undo-action redo-action
cut-action copy-action paste-action
delete-action select-all-action
left-action right-action up-action down-action
zoom-in-action zoom-out-action ;

CONSTANT: action-gestures
    {
        { "z" undo-action }
        { "Z" redo-action }
        { "x" cut-action }
        { "c" copy-action }
        { "v" paste-action }
        { "a" select-all-action }
    }

! Modifiers
SYMBOLS: C+ A+ M+ S+ ;

TUPLE: key-gesture mods sym ;

TUPLE: key-down < key-gesture ;

: new-key-gesture ( mods sym action? class -- mods' sym' )
    [ [ [ S+ swap remove f like ] dip ] unless ] dip boa ; inline

: <key-down> ( mods sym action? -- key-down )
    key-down new-key-gesture ;

TUPLE: key-up < key-gesture ;

: <key-up> ( mods sym action? -- key-up )
    key-up new-key-gesture ;

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
<zero> hand-last-time set-global

SYMBOL: hand-buttons
V{ } clone hand-buttons set-global

SYMBOL: scroll-direction
{ 0 0 } scroll-direction set-global

SYMBOL: double-click-timeout
300 milliseconds double-click-timeout set-global

: hand-moved? ( -- ? )
    hand-loc get hand-click-loc get = not ;

: button-gesture ( gesture -- )
    hand-clicked get-global propagate-gesture ;

: drag-gesture ( -- )
    hand-buttons get-global
    [ first <drag> button-gesture ] unless-empty ;

SYMBOL: drag-timer

<box> drag-timer set-global

: start-drag-timer ( -- )
    hand-buttons get-global empty? [
        [ drag-gesture ]
        300 milliseconds hence
        100 milliseconds
        add-alarm drag-timer get-global >box
    ] when ;

: stop-drag-timer ( -- )
    hand-buttons get-global empty? [
        drag-timer get-global ?box
        [ cancel-alarm ] [ drop ] if
    ] when ;

: fire-motion ( -- )
    hand-buttons get-global empty? [
        motion hand-gadget get-global propagate-gesture
    ] [
        drag-gesture
    ] if ;

: hand-gestures ( new old -- )
    drop-prefix <reversed>
    mouse-leave swap each-gesture
    mouse-enter swap each-gesture ;

: forget-rollover ( -- )
    f hand-world set-global
    hand-gadget get-global
    [ f hand-gadget set-global f ] dip
    parents hand-gestures ;

: send-lose-focus ( gadget -- )
    lose-focus swap send-gesture ;

: send-gain-focus ( gadget -- )
    gain-focus swap send-gesture ;

: focus-child ( child gadget ? -- )
    [
        dup focus>> [
            dup send-lose-focus
            f swap t focus-child
        ] when*
        dupd (>>focus) [
            send-gain-focus
        ] when*
    ] [
        (>>focus)
    ] if ;

: modifier ( mod modifiers -- seq )
    [ second swap bitand 0 > ] with filter
    0 <column> prune [ f ] [ >array ] if-empty ;

: drag-loc ( -- loc )
    hand-loc get-global hand-click-loc get-global v- ;

: hand-rel ( gadget -- loc )
    hand-loc get-global swap screen-loc v- ;

: hand-click-rel ( gadget -- loc )
    hand-click-loc get-global swap screen-loc v- ;

: multi-click-timeout? ( -- ? )
    now hand-last-time get time- double-click-timeout get before=? ;

: multi-click-button? ( button -- button ? )
    dup hand-last-button get = ;

: multi-click-position? ( -- ? )
    hand-loc get hand-click-loc get distance 10 <= ;

: multi-click? ( button -- ? )
    {
        [ multi-click-timeout? ]
        [ multi-click-button? ]
        [ multi-click-position? ]
    } 0&& nip ;

: update-click# ( button -- )
    global [
        dup multi-click? [
            hand-click# inc
        ] [
            1 hand-click# set
        ] if
        hand-last-button set
        now hand-last-time set
    ] bind ;

: update-clicked ( -- )
    hand-gadget get-global hand-clicked set-global
    hand-loc get-global hand-click-loc set-global ;

: under-hand ( -- seq )
    hand-gadget get-global parents <reversed> ;

: move-hand ( loc world -- )
    dup hand-world set-global
    under-hand [
        over hand-loc set-global
        pick-up hand-gadget set-global
        under-hand
    ] dip hand-gestures ;

: send-button-down ( gesture loc world -- )
    move-hand
    start-drag-timer
    dup #>>
    dup update-click# hand-buttons get-global push
    update-clicked
    button-gesture ;

: send-button-up ( gesture loc world -- )
    move-hand
    dup #>> hand-buttons get-global delete
    stop-drag-timer
    button-gesture ;

: send-wheel ( direction loc world -- )
    move-hand
    scroll-direction set-global
    mouse-scroll hand-gadget get-global propagate-gesture ;

: send-action ( world gesture -- )
    swap world-focus propagate-gesture ;

GENERIC: gesture>string ( gesture -- string/f )

HOOK: modifiers>string os ( modifiers -- string )

M: macosx modifiers>string
    [
        {
            { A+ [ "\u{place-of-interest-sign}" ] }
            { M+ [ "\u{option-key}" ] }
            { S+ [ "\u{upwards-white-arrow}" ] }
            { C+ [ "\u{up-arrowhead}" ] }
        } case
    ] map "" join ;

M: object modifiers>string
    [ name>> ] map "" join ;

HOOK: keysym>string os ( keysym -- string )

M: macosx keysym>string >upper ;

M: object keysym>string dup length 1 = [ >lower ] when ;

M: key-down gesture>string
    [ mods>> ] [ sym>> ] bi
    {
        { [ dup { [ length 1 = ] [ first LETTER? ] } 1&& ] [ [ S+ prefix ] dip ] }
        { [ dup " " = ] [ drop "SPACE" ] }
        [ ]
    } cond
    [ modifiers>string ] [ keysym>string ] bi* append ;

M: button-up gesture>string
    [
        dup mods>> modifiers>string %
        "Click Button" %
        #>> [ " " % # ] when*
    ] "" make ;

M: button-down gesture>string
    [
        dup mods>> modifiers>string %
        "Press Button" %
        #>> [ " " % # ] when*
    ] "" make ;

M: left-action gesture>string drop "Swipe left" ;

M: right-action gesture>string drop "Swipe right" ;

M: up-action gesture>string drop "Swipe up" ;

M: down-action gesture>string drop "Swipe down" ;

M: zoom-in-action gesture>string drop "Zoom in" ;

M: zoom-out-action gesture>string drop "Zoom out (pinch)" ;

HOOK: action-modifier os ( -- mod )

M: object action-modifier C+ ;
M: macosx action-modifier A+ ;

M: action gesture>string
    action-gestures value-at
    action-modifier 1array
    swap f <key-down> gesture>string ;

M: object gesture>string drop f ;
