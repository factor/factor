! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic kernel lists math namespaces sdl sdl-event
sdl-video ;

! The world gadget is the top level gadget that all (visible)
! gadgets are contained in. The current world is stored in the
! world variable.
TUPLE: world running? hand delegate ;

: <world-box> ( -- box )
    0 0 0 0 <plain-rect> <gadget> ;

C: world ( -- world )
    <world-box> over set-world-delegate
    t over set-world-running?
    dup <hand> over set-world-hand ;

M: world inside? ( point world -- ? ) 2drop t ;

: my-hand ( -- hand ) world get world-hand ;

: draw-world ( -- )
    world get dup gadget-redraw? [
        dup world-hand update-hand [
            f over set-gadget-redraw?
            dup draw-gadget
            dup gadget-paint [ world-hand draw-gadget ] bind
        ] with-surface
    ] [
        drop
    ] ifte ;

DEFER: handle-event

: layout-world world get dup layout world-hand update-hand ;

: eat-events ( event -- )
    #! Keep polling for events until there are no more events in
    #! the queue; then block for the next event.
    dup SDL_PollEvent [
        dup handle-event eat-events
    ] [
        SDL_WaitEvent
    ] ifte ;

: run-world ( -- )
    world get world-running? [
        layout-world draw-world
        <event> dup eat-events [
            handle-event run-world
        ] [
            drop
        ] ifte
    ] when ;

: start-world ( -- )
    #! Start the Factor graphics subsystem with the given screen
    #! dimensions.
    t world get set-world-running?
    world get shape-w world get shape-h 0 SDL_RESIZABLE
    [
        0 x set
        0 y set
        [ run-world ] with-screen
    ] with-scope ;

global [
    <world> world set
    1024 768 world get resize-gadget
    {{
        [[ background [ 255 255 255 ] ]]
        [[ foreground [ 0 0 102 ] ]]
        [[ bevel-1    [ 224 224 255 ] ]]
        [[ bevel-2    [ 192 192 216 ] ]]
        [[ bevel-up?  t ]]
        [[ font       [[ "Sans Serif" 14 ]] ]]
    }} world get set-gadget-paint
] bind
