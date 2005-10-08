! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien arrays errors gadgets-layouts generic io kernel
lists math memory namespaces prettyprint sdl sequences sequences
strings styles threads ;

! The world gadget is the top level gadget that all (visible)
! gadgets are contained in. The current world is stored in the
! world variable. The invalid slot is a list of gadgets that
! need to be layout.
TUPLE: world running? glass invalid ;

: add-layer ( gadget -- )
    world get add-gadget ;

C: world ( -- world )
    <stack> over set-delegate
    t over set-gadget-root? ;

: add-invalid ( gadget -- )
    world get [ world-invalid cons ] keep set-world-invalid ;

: pop-invalid ( -- list )
    world get [ world-invalid f ] keep set-world-invalid ;

: layout-world ( -- )
    world get world-invalid
    [ pop-invalid [ layout ] each layout-world ] when ;

: hide-glass ( -- )
    f world get dup world-glass unparent set-world-glass ;

: show-glass ( gadget -- )
    hide-glass
    <gadget> dup add-layer dup world get set-world-glass
    dupd add-gadget prefer ;

: world-clip ( -- rect )
    @{ 0 0 0 }@ width get height get 0 3array <rect> ;

: draw-world ( world -- )
    [ world-clip clip set draw-gadget ] with-surface ;

: move-hand ( loc hand -- )
    dup hand-gadget parents-down >r
    2dup set-rect-loc
    [ >r world get pick-up r> set-hand-gadget ] keep
    dup hand-gadget parents-down r> hand-gestures ;

M: motion-event handle-event ( event -- )
    motion-event-loc hand get move-hand ;

: update-hand ( hand -- )
    #! Called when a gadget is removed or added.
    dup rect-loc swap move-hand ;

: stop-world ( -- )
    f world get set-world-running? ;

: ui-title
    [ "Factor " % version % " - " % image % ] "" make ;

: start-world ( -- )
    ui-title dup SDL_WM_SetCaption
    world get dup relayout t swap set-world-running? ;

: world-step ( -- )
    world get dup world-invalid >r layout-world r>
    [ dup hand get update-hand dup draw-world ] when drop ;

: next-event ( -- event ? ) <event> dup SDL_PollEvent ;

: world-loop ( -- )
    #! Keep polling for events until there are no more events in
    #! the queue; then block for the next event.
    next-event [
        handle-event world-loop
    ] [
        drop world-step do-timers
        world get world-running? [ 10 sleep world-loop ] when
    ] if ;

: run-world ( -- )
    [ start-world world-loop ] [ stop-world ] cleanup ;

M: quit-event handle-event ( event -- )
    drop stop-world ;

M: resize-event handle-event ( event -- )
    dup resize-event-w swap resize-event-h
    [ 0 3array world get set-gadget-dim ] 2keep
    0 SDL_HWSURFACE SDL_RESIZABLE bitor init-surface
    world get relayout ;
