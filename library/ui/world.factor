! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic kernel lists math namespaces sdl sdl-event ;

! The hand is a special gadget that holds mouse position and
! mouse button click state.
TUPLE: hand clicked buttons delegate ;

C: hand ( -- hand ) 0 <gadget> over set-hand-delegate ;

GENERIC: hand-gesture ( hand gesture -- )

M: alien hand-gesture ( hand gesture -- ) 2drop ;

: button/ ( n hand -- )
    [ hand-buttons unique ] keep set-hand-buttons ;

: button\ ( n hand -- )
    [ hand-buttons remove ] keep set-hand-buttons ;

M: button-down-event hand-gesture ( hand gesture -- )
    2dup
    dup button-event-x swap button-event-y rect>
    swap set-hand-clicked
    button-event-button swap button/ ;

M: button-up-event hand-gesture ( hand gesture -- )
    button-event-button swap button\ ;

! The world gadget is the top level gadget that all (visible)
! gadgets are contained in. The current world is stored in the
! world variable.
TUPLE: world running? hand delegate ;

M: hand handle-gesture* ( gesture hand -- ? )
    2dup swap hand-gesture
    world get pick-up handle-gesture* ;

: <world-box> ( -- box )
    0 0 1000 1000 <rect> <gadget> <box> ;

C: world ( -- world )
    <world-box> over set-world-delegate
    t over set-world-running?
    <hand> over set-world-hand ;

GENERIC: world-gesture ( world gesture -- )

M: alien world-gesture ( world gesture -- ) 2drop ;

M: quit-event world-gesture ( world gesture -- )
    drop f swap set-world-running? ;

M: world handle-gesture* ( gesture world -- ? )
    swap world-gesture f ;

: my-hand ( -- hand ) world get world-hand ;

: run-world ( -- )
    world get world-running? [
        <event> dup SDL_WaitEvent 1 = [
            my-hand handle-gesture run-world
        ] [
            drop
        ] ifte
    ] when ;

global [ <world> world set ] bind
