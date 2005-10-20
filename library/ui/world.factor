! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien arrays errors freetype gadgets-layouts generic io
kernel lists math memory namespaces opengl prettyprint sdl
sequences sequences strings styles threads ;

! The world gadget is the top level gadget that all (visible)
! gadgets are contained in. The current world is stored in the
! world variable. The invalid slot is a list of gadgets that
! need to be layout.
TUPLE: world running? glass status content invalid ;

: add-layer ( gadget -- )
    world get add-gadget ;

C: world ( -- world )
    <stack> over set-delegate
    <frame> over 2dup set-world-content add-gadget
    t over set-gadget-root? ;

: set-application ( gadget -- )
    world get world-content @center frame-add ;

: set-status ( gadget -- )
    world get 2dup set-world-status
    world-content @bottom frame-add ;

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

: draw-world ( -- )
    world get [ world-clip clip set draw-gadget ] with-gl-surface ;

! Status bar protocol
GENERIC: set-message ( string/f status -- )

M: f set-message 2drop ;

: show-message ( string/f -- )
    #! Show a message in the status bar.
    world get world-status set-message ;

: update-help ( -- )
    #! Update mouse-over help message.
    hand get hand-gadget
    parents [ gadget-help ] map [ ] find nip
    show-message ;

: under-hand ( -- seq )
    #! A sequence whose first element is the world and last is
    #! the current gadget, with all parents in between.
    hand get hand-gadget parents reverse-slice ;

: hand-grab ( -- gadget )
    hand get rect-loc world get pick-up ;

: move-hand ( loc -- )
    under-hand >r hand get set-rect-loc
    hand-grab hand get set-hand-gadget
    under-hand r> hand-gestures update-help ;

M: motion-event handle-event ( event -- )
    motion-event-loc move-hand ;

: update-hand ( -- )
    #! Called when a gadget is removed or added.
    hand get rect-loc move-hand ;

: stop-world ( -- )
    f world get set-world-running? ;

: ui-title
    [ "Factor " % version % " - " % image % ] "" make ;

: start-world ( -- )
    ui-title dup SDL_WM_SetCaption
    world get dup relayout t swap set-world-running? ;

: world-step ( -- )
    world get world-invalid >r layout-world r>
    [ update-hand draw-world ] when ;

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
    flush-fonts
    gl-resize
    width get height get 0 3array world get set-gadget-dim ;
