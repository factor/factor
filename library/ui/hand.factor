! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic io kernel lists math matrices namespaces
prettyprint sdl sequences vectors ;

: (pick-up) ( point gadget -- gadget )
    gadget-children reverse-slice [ inside? ] find-with nip ;

: pick-up ( point gadget -- gadget )
    #! The logic is thus. If the point is definately outside the
    #! box, return f. Otherwise, see if the point is contained
    #! in any subgadget. If not, see if it is contained in the
    #! box delegate.
    dup gadget-visible? >r 2dup inside? r> drop [
        [ rectangle-loc v- ] keep 2dup
        (pick-up) [ pick-up ] [ nip ] ?ifte
    ] [
        2drop f
    ] ifte ;

! The hand is a special gadget that holds mouse position and
! mouse button click state. The hand's parent is the world, but
! it is special in that the world does not list it as part of
! its contents. Some comments on the slots:
! - hand-gadget is the gadget under the mouse position
! - hand-clicked is the most recently clicked gadget
! - hand-focus is the gadget holding keyboard focus
TUPLE: hand click-loc click-rel clicked buttons gadget focus ;

C: hand ( world -- hand )
    <gadget> over set-delegate
    [ set-gadget-parent ] 2keep
    [ set-hand-gadget ] keep ;

: hand world get world-hand ;

: button/ ( n hand -- )
    dup hand-gadget over set-hand-clicked
    dup screen-loc over set-hand-click-loc
    dup hand-gadget over relative over set-hand-click-rel
    [ hand-buttons unique ] keep set-hand-buttons ;

: button\ ( n hand -- )
    [ hand-buttons remove ] keep set-hand-buttons ;

: fire-leave ( hand gadget -- )
    [ swap rectangle-loc swap screen-loc v- ] keep mouse-leave ;

: fire-enter ( oldpos hand -- )
    hand-gadget [ screen-loc v- ] keep mouse-enter ;

: update-hand-gadget ( hand -- )
    [ rectangle-loc world get pick-up ] keep set-hand-gadget ;

: motion-gesture ( hand gadget gesture -- )
    #! Send a gesture like [ drag 2 ].
    rot hand-buttons car add swap handle-gesture drop ;

: fire-motion ( hand -- )
    #! Fire a motion gesture to the gadget underneath the hand,
    #! and if a mouse button is down, fire a drag gesture to the
    #! gadget that was clicked.
    [ motion ] over hand-gadget handle-gesture drop
    dup hand-buttons
    [ dup hand-clicked [ drag ] motion-gesture ] [ drop ] ifte ;

: move-hand ( loc hand -- )
    dup rectangle-loc >r
    [ set-rectangle-loc ] keep
    dup hand-gadget >r
    dup update-hand-gadget
    dup r> fire-leave
    dup fire-motion
    r> swap fire-enter ;

: update-hand ( hand -- )
    #! Called when a gadget is removed or added.
    dup rectangle-loc swap move-hand ;

: request-focus ( gadget -- )
    focusable-child
    hand hand-focus
    2dup lose-focus
    swap dup hand set-hand-focus
    gain-focus ;
