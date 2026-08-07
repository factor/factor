! Copyright (C) 2005, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs boxes calendar classes columns
combinators combinators.short-circuit deques kernel make math
math.order math.parser math.vectors namespaces sequences sets system
timers ui.gadgets ui.gadgets.private words ;
IN: ui.gestures

: get-gesture-handler ( gesture gadget -- quot )
    class-of superclasses-of [ "gestures" word-prop ] map assoc-stack ;

GENERIC: handle-gesture ( gesture gadget -- ? )

M: object handle-gesture
    [ nip ]
    [ get-gesture-handler ] 2bi
    dup [ call( gadget -- ) f ] [ 2drop t ] if ;

GENERIC: handles-gesture? ( gesture gadget -- ? )

M: object handles-gesture?
    get-gesture-handler >boolean ;

: parents-handle-gesture? ( gesture gadget -- ? )
    [ handles-gesture? not ] with each-parent not ;

: set-gestures ( class hash -- ) "gestures" set-word-prop ;

: gesture-queue ( -- deque ) \ gesture-queue get ;

GENERIC: send-queued-gesture ( request -- )

TUPLE: send-gesture-tuple gesture gadget ;

M: send-gesture-tuple send-queued-gesture
    [ gesture>> ] [ gadget>> ] bi handle-gesture drop ;

: queue-gesture ( ... class -- )
    boa gesture-queue push-front notify-ui-thread ; inline

: send-gesture ( gesture gadget -- )
    \ send-gesture-tuple queue-gesture ;

: each-gesture ( gesture seq -- ) [ send-gesture ] with each ;

TUPLE: propagate-gesture-tuple gesture gadget ;

: resend-gesture ( gesture gadget -- ? )
    [ handle-gesture ] with each-parent ;

M: propagate-gesture-tuple send-queued-gesture
    [ gesture>> ] [ gadget>> ] bi resend-gesture drop ;

: propagate-gesture ( gesture gadget -- )
    \ propagate-gesture-tuple queue-gesture ;

TUPLE: propagate-key-gesture-tuple gesture world ;

: world-focus ( world -- gadget )
    [ focus>> ] [ world-focus ] ?when ;

M: propagate-key-gesture-tuple send-queued-gesture
    [ gesture>> ] [ world>> world-focus ] bi
    [ handle-gesture ] with each-parent drop ;

:: propagate-key-gesture ( gesture world -- )
    world world-focus preedit? [
        gesture world \ propagate-key-gesture-tuple queue-gesture
    ] unless ;

TUPLE: user-input-tuple string world ;

M: user-input-tuple send-queued-gesture
    [ string>> ] [ world>> world-focus ] bi
    [ user-input* ] with each-parent drop ;

: user-input ( string world -- )
    '[ _ \ user-input-tuple queue-gesture ] unless-empty ;

! Gesture objects
TUPLE: drag # ;             C: <drag> drag
TUPLE: button-up mods # ;   C: <button-up> button-up
TUPLE: button-down mods # ; C: <button-down> button-down
TUPLE: file-drop mods ;     C: <file-drop> file-drop

SYMBOL: dropped-files

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
    zoom-in-action zoom-out-action
    new-action open-action save-action save-as-action
    revert-action close-action ;

UNION: action
    undo-action redo-action
    cut-action copy-action paste-action
    delete-action select-all-action
    left-action right-action up-action down-action
    zoom-in-action zoom-out-action
    new-action open-action save-action save-as-action
    revert-action close-action ;

CONSTANT: action-gestures
    {
        { "z" undo-action }
        { "y" redo-action }
        { "x" cut-action }
        { "c" copy-action }
        { "v" paste-action }
        { "a" select-all-action }
        { "n" new-action }
        { "o" open-action }
        { "s" save-action }
        { "S" save-as-action }
        { "w" close-action }
    }

! Modifiers
SYMBOLS: C+ A+ M+ S+ ;

TUPLE: key-gesture mods sym ;

TUPLE: key-down < key-gesture ;

: new-key-gesture ( mods sym action? class -- key-gesture )
    [ [ [ S+ swap remove f like ] dip ] unless ] dip boa ; inline

: <key-down> ( mods sym action? -- key-down )
    key-down new-key-gesture ;

TUPLE: key-up < key-gesture ;

: <key-up> ( mods sym action? -- key-up )
    key-up new-key-gesture ;

! Hand state

! Note that these are only really useful inside an event
! handler, and that the locations hand-loc and hand-click-loc
! are in the coordinate system of the world which contains
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
300 milliseconds double-click-timeout set-global

: hand-moved? ( -- ? )
    hand-loc get-global hand-click-loc get-global = not ;

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
        300 milliseconds
        100 milliseconds
        <timer>
        [ drag-timer get-global >box ]
        [ start-timer ] bi
    ] when ;

: stop-drag-timer ( -- )
    hand-buttons get-global empty? [
        drag-timer get-global ?box
        [ stop-timer ] [ drop ] if
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
        dupd focus<< [
            send-gain-focus
        ] when*
    ] [
        focus<<
    ] if ;

: modifier ( mod modifiers -- seq )
    [ second swap bitand 0 > ] with filter
    0 <column> members [ f ] [ >array ] if-empty ;

: drag-loc ( -- loc )
    hand-loc get-global hand-click-loc get-global v- ;

: hand-rel ( gadget -- loc )
    hand-loc get-global swap screen-loc v- ;

: hand-click-rel ( gadget -- loc )
    hand-click-loc get-global swap screen-loc v- ;

: multi-click-timeout? ( -- ? )
    nano-count hand-last-time get - nanoseconds
    double-click-timeout get before=? ;

: multi-click-button? ( button -- button ? )
    dup hand-last-button get = ;

: multi-click-position? ( -- ? )
    hand-loc get-global hand-click-loc get-global distance 10 <= ;

: multi-click? ( button -- ? )
    {
        [ multi-click-timeout? ]
        [ multi-click-button? ]
        [ multi-click-position? ]
    } 0&& nip ;

: update-click# ( button -- )
    [
        dup multi-click? [
            hand-click# inc
        ] [
            1 hand-click# namespaces:set
        ] if
        hand-last-button namespaces:set
        nano-count hand-last-time namespaces:set
    ] with-global ;

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
    dup #>> hand-buttons get-global remove! drop
    stop-drag-timer
    button-gesture ;

: send-scroll ( direction loc world -- )
    move-hand
    [ 3 * ] map scroll-direction set-global
    mouse-scroll hand-gadget get-global propagate-gesture ;

: send-action ( world gesture -- )
    swap world-focus propagate-gesture ;

GENERIC: gesture>string ( gesture -- string/f )

HOOK: modifiers>string os ( modifiers -- string )

M: macos modifiers>string
    [
        {
            { M+ [ "\u002318" ] }
            { A+ [ "\u002325" ] }
            { S+ [ "\u0021e7" ] }
            { C+ [ "\u002303" ] }
        } case
    ] map "" concat-as ;

M: object modifiers>string
    [ name>> ] map "" concat-as ;

HOOK: keysym>string os ( keysym -- string )

M: macos keysym>string >upper ;

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

M: file-drop gesture>string drop "Drop files" ;

M: left-action gesture>string drop "Swipe left" ;

M: right-action gesture>string drop "Swipe right" ;

M: up-action gesture>string drop "Swipe up" ;

M: down-action gesture>string drop "Swipe down" ;

M: zoom-in-action gesture>string drop "Zoom in" ;

M: zoom-out-action gesture>string drop "Zoom out (pinch)" ;

HOOK: action-modifier os ( -- mod )

M: object action-modifier C+ ;
M: macos action-modifier M+ ;

M: action gesture>string
    action-gestures value-at
    action-modifier 1array
    swap f <key-down> gesture>string ;

M: object gesture>string drop f ;
