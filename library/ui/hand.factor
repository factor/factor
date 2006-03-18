! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: gadgets-labels gadgets-layouts kernel math namespaces
queues sequences ;

! The hand is a special gadget that holds mouse position and
! mouse button click state.

! Some comments on the slots:
! - hand-gadget is the gadget under the mouse position
! - hand-clicked is the most recently clicked gadget
! - hand-focus is the gadget holding keyboard focus
TUPLE: hand click-loc click-rel clicked buttons gadget focus ;

C: hand ( -- hand )
    dup delegate>gadget V{ } clone over set-hand-buttons ;

<hand> hand set-global

: button-gesture ( buttons gesture -- )
    #! Send a gesture like [ button-down 2 ]; if nobody
    #! handles it, send [ button-down ].
    swap hand get hand-clicked 3dup >r add r> handle-gesture
    [ nip handle-gesture drop ] [ 3drop ] if ;

: update-clicked ( -- )
    hand get
    dup hand-gadget over set-hand-clicked
    dup screen-loc over set-hand-click-loc
    dup hand-gadget over relative swap set-hand-click-rel ;

: send-button-down ( event -- )
    update-clicked
    dup hand get hand-buttons push
    [ button-down ] button-gesture ;

: send-button-up ( event -- )
    dup hand get hand-buttons delete
    [ button-up ] button-gesture ;

: send-scroll-wheel ( up/down -- )
    [ wheel-up ] [ wheel-down ] ?
    hand get hand-gadget handle-gesture drop ;

: drag-gesture ( -- )
    #! Send a gesture like [ drag 2 ]; if nobody handles it,
    #! send [ drag ].
    hand get hand-buttons first [ drag ] button-gesture ;

: fire-motion ( hand -- )
    #! Fire a motion gesture to the gadget underneath the hand,
    #! and if a mouse button is down, fire a drag gesture to the
    #! gadget that was clicked.
    [ motion ] over hand-gadget handle-gesture drop
    hand-buttons empty? [ drag-gesture ] unless ;

: send-user-input ( string -- )
    dup empty?
    [ hand get hand-focus user-input ] unless drop ;

: each-gesture ( gesture seq -- )
    [ handle-gesture* drop ] each-with ;

: hand-gestures ( new old -- )
    drop-prefix reverse-slice
    [ mouse-leave ] swap each-gesture
    hand get fire-motion
    [ mouse-enter ] swap each-gesture ;

: focus-gestures ( new old -- )
    drop-prefix reverse-slice
    [ lose-focus ] swap each-gesture
    [ gain-focus ] swap each-gesture ;

: focused-ancestors ( hand -- seq )
    hand get hand-focus parents reverse-slice ;

: request-focus ( gadget -- )
    focusable-child focused-ancestors >r
    hand get set-hand-focus focused-ancestors
    r> focus-gestures ;

: drag-loc ( gadget -- loc )
    hand get [ relative ] keep hand-click-rel v- ;

: relevant-help ( seq -- help )
    [ gadget-help ] map [ ] find nip ;

: show-message ( string/f -- )
    #! Show a message in the status bar.
    world-status set-label-text* ;

: update-help ( -- string )
    #! Update mouse-over help message.
    hand get hand-gadget parents [ relevant-help ] keep
    dup empty? [ 2drop ] [ peek show-message ] if ;

: under-hand ( -- seq )
    #! A sequence whose first element is the world and last is
    #! the current gadget, with all parents in between.
    hand get hand-gadget parents reverse-slice ;

: hand-grab ( world -- gadget )
    hand get rect-loc swap pick-up ;

: update-hand-gadget ( world -- )
    hand-grab hand get set-hand-gadget ;

: move-hand ( loc world -- )
    swap under-hand >r hand get set-rect-loc
    update-hand-gadget
    under-hand r> hand-gestures update-help ;

: update-hand ( world -- )
    #! Called when a gadget is removed or added.
    hand get rect-loc swap move-hand ;

: layout-done ( gadget -- )
    find-world [
        dup update-hand world-handle repaint-handle
    ] when* ;

: layout-queued ( -- )
    invalid dup queue-empty?
    [ drop ] [ deque dup layout layout-done layout-queued ] if ;
