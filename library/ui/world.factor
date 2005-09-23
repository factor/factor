! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien arrays errors gadgets-layouts generic io kernel
lists math memory namespaces prettyprint sdl sequences sequences
strings threads ;

! The world gadget is the top level gadget that all (visible)
! gadgets are contained in. The current world is stored in the
! world variable. The invalid slot is a list of gadgets that
! need to be layout.
TUPLE: world running? hand glass invalid ;

DEFER: <hand>
DEFER: update-hand

: add-layer ( gadget -- )
    world get add-gadget ;

C: world ( -- world )
    <stack> over set-delegate
    t over set-gadget-root?
    dup <hand> over set-world-hand ;

: add-invalid ( gadget -- )
    world get [ world-invalid cons ] keep set-world-invalid ;

: pop-invalid ( -- list )
    world get [ world-invalid f ] keep set-world-invalid ;

: layout-world ( -- )
    world get world-invalid
    [ pop-invalid [ layout ] each layout-world ] when ;

: hide-glass ( -- )
    world get world-glass unparent f
    world get set-world-glass ;

: show-glass ( gadget -- )
    hide-glass
    <gadget> dup add-layer dup world get set-world-glass
    dupd add-gadget prefer ;

: world-clip ( -- rect )
    @{ 0 0 0 }@ width get height get 0 3array <rect> ;

: draw-world ( world -- )
    [ world-clip clip set draw-gadget ] with-surface ;

DEFER: handle-event

: world-step ( -- ? )
    world get dup world-invalid >r layout-world r>
    [ dup world-hand update-hand draw-world ] [ drop ] ifte ;

: next-event ( -- event ? ) <event> dup SDL_PollEvent ;

: run-world ( -- )
    #! Keep polling for events until there are no more events in
    #! the queue; then block for the next event.
    next-event [
        handle-event run-world
    ] [
        drop world-step do-timers
        world get world-running? [ 10 sleep run-world ] when
    ] ifte ;

: start-world ( -- )
    world get t over set-world-running? relayout ;
