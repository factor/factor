! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien errors generic kernel lists math
memory namespaces prettyprint sdl sequences io strings
threads sequences ;

! The world gadget is the top level gadget that all (visible)
! gadgets are contained in. The current world is stored in the
! world variable. The invalid slot is a list of gadgets that
! need to be layout.
TUPLE: world running? hand glass invalid ;

C: world ( -- world )
    f <stack> over set-delegate
    t over set-world-running?
    t over set-gadget-root?
    dup <hand> over set-world-hand ;

: add-invalid ( gadget world -- )
    [ world-invalid cons ] keep set-world-invalid ;

: pop-invalid ( world -- list )
    [ world-invalid f ] keep set-world-invalid ;

: layout-world ( world -- )
    dup world-invalid [
        dup pop-invalid [ layout ] each layout-world
    ] [
        drop
    ] ifte ;

: add-layer ( gadget -- )
    world get add-gadget ;

: show-glass ( gadget -- )
    <empty-gadget> dup
    world get 2dup add-gadget set-world-glass
    add-gadget ;

: hide-glass ( -- )
    world get world-glass unparent f
    world get set-world-glass ;

M: world inside? ( point world -- ? ) 2drop t ;

: hand world get world-hand ;

: draw-world ( world -- )
    dup gadget-redraw? [
        [
            dup 0 0 width get height get <rectangle> clip set-paint-prop
            draw-gadget
        ] with-surface
    ] [
        drop
    ] ifte ;

DEFER: handle-event

: world-step ( world -- ? )
    world get dup world-running? [
        dup layout-world draw-world  t
    ] [
        drop f
    ] ifte ;

: next-event ( -- event ? )
    <event> dup SDL_PollEvent ;

: run-world ( -- )
    #! Keep polling for events until there are no more events in
    #! the queue; then block for the next event.
    next-event [
        handle-event run-world
    ] [
        drop world-step [ yield run-world ] when
    ] ifte ;

: ensure-ui ( -- )
    #! Raise an error if the UI is not running.
    world get dup [ world-running? ] when [
        "UI not running." throw
    ] unless ;

: start-world ( -- )
    world get t over set-world-running? relayout ;
