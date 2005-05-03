! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien errors generic kernel lists math memory namespaces
prettyprint sdl sequences stdio strings threads ;

! The world gadget is the top level gadget that all (visible)
! gadgets are contained in. The current world is stored in the
! world variable. The menu slot ensures that only one menu is
! open at any one time.
TUPLE: world running? hand menu ;

: <world-box> ( -- box )
    0 0 0 0 <plain-rect> <gadget> ;

C: world ( -- world )
    <world-box> over set-delegate
    t over set-world-running?
    dup <hand> over set-world-hand ;

M: world inside? ( point world -- ? ) 2drop t ;

: hand world get world-hand ;

: draw-world ( world -- )
    dup gadget-redraw? [
        [ draw-gadget ] with-surface
    ] [
        drop
    ] ifte ;

DEFER: handle-event

: layout-world ( world -- )
    dup
    0 0 width get height get <rectangle> clip set-paint-prop
    layout ;

: world-step ( world -- ? )
    dup world-running? [
        dup layout-world draw-world  t
    ] [
        drop f
    ] ifte ;

: run-world ( -- )
    #! Keep polling for events until there are no more events in
    #! the queue; then block for the next event.
    <event> dup SDL_PollEvent [
        [ handle-event ] in-thread drop run-world
    ] [
        drop world get world-step [ yield run-world ] when
    ] ifte ;

: ensure-ui ( -- )
    #! Raise an error if the UI is not running.
    world get dup [ world-running? ] when [
        "UI not running." throw
    ] unless ;
