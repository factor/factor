! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic kernel lists math namespaces sdl sdl-event
sdl-video ;

! The world gadget is the top level gadget that all (visible)
! gadgets are contained in. The current world is stored in the
! world variable.
TUPLE: world running? hand delegate redraw? ;

M: hand handle-gesture* ( gesture hand -- ? )
    2dup swap hand-gesture
    world get pick-up handle-gesture* ;

: <world-box> ( -- box )
    0 0 0 0 <rectangle> <everywhere> <gadget>
    dup blue 3list color set-paint-property
    dup t filled set-paint-property
    <box> ;

C: world ( -- world )
    <world-box> over set-world-delegate
    t over set-world-running?
    t over set-world-redraw?
    <hand> over set-world-hand ;

GENERIC: world-gesture ( world gesture -- )

M: alien world-gesture ( world gesture -- ) 2drop ;

M: quit-event world-gesture ( world gesture -- )
    drop f swap set-world-running? ;

M: resize-event world-gesture ( world gesture -- ? )
    dup resize-event-w swap resize-event-h
    [ rot resize-gadget ] 2keep
    0 SDL_HWSURFACE SDL_RESIZABLE bitor init-screen
    world get redraw ;

M: redraw-gesture world-gesture ( world gesture -- )

    drop t swap set-world-redraw? ;

M: world handle-gesture* ( gesture world -- ? )
    swap world-gesture f ;

: my-hand ( -- hand ) world get world-hand ;

: draw-world ( -- )
    world get dup world-redraw? [
        [
            f over set-world-redraw?
            dup draw
            world-hand draw
        ] with-surface
    ] [
        drop
    ] ifte ;

: run-world ( -- )
    world get world-running? [
        <event> dup SDL_WaitEvent 1 = [
            my-hand handle-gesture draw-world run-world
        ] [
            drop
        ] ifte
    ] when ;

: init-world ( w h -- )
    t world get set-world-running?
    t world get set-world-redraw?
    world get resize-gadget ;

: world-flags SDL_HWSURFACE SDL_RESIZABLE bitor ;

: start-world ( w h -- )
    #! Start the Factor graphics subsystem with the given screen
    #! dimensions.
    2dup init-world 0 world-flags
    default-paint [ [ run-world ] with-screen ] bind ;

global [ <world> world set ] bind
