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
    0 0 0 0 <rectangle> <everywhere> <stamp>
    dup blue 3list color set-paint-property
    dup t filled set-paint-property
    <box> ;

C: world ( -- world )
    <world-box> over set-world-delegate
    t over set-world-running?
    dup <hand> over set-world-hand ;

: my-hand ( -- hand ) world get world-hand ;

: draw-world ( -- )
    world get dup gadget-redraw? [
        [
            f over set-gadget-redraw?
            dup draw
            world-hand draw
        ] with-surface
    ] [
        drop
    ] ifte ;

DEFER: handle-event

: layout-world world get layout ;

: run-world ( -- )
    world get world-running? [
        <event> dup SDL_WaitEvent 1 = [
            handle-event draw-world layout-world run-world
        ] [
            drop
        ] ifte
    ] when ;

: init-world ( w h -- )
    t world get set-world-running?
    world get resize-gadget ;

: world-flags SDL_HWSURFACE SDL_RESIZABLE bitor ;

: start-world ( w h -- )
    #! Start the Factor graphics subsystem with the given screen
    #! dimensions.
    2dup init-world 0 world-flags
    default-paint [ [ run-world ] with-screen ] bind ;

global [ <world> world set ] bind
