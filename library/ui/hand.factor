! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic kernel lists math namespaces prettyprint
sdl sdl-event sdl-video stdio ;

DEFER: pick-up

: pick-up-list ( point list -- gadget )
    dup [
        2dup car pick-up dup [
            2nip
        ] [
            drop cdr pick-up-list
        ] ifte
    ] [
        2drop f
    ] ifte ;

: pick-up* ( point gadget -- gadget/t )
    #! The logic is thus. If the point is definately outside the
    #! box, return f. Otherwise, see if the point is contained
    #! in any subgadget. If not, see if it is contained in the
    #! box delegate.
    2dup inside? [
        2dup [ translate ] keep
        gadget-children reverse pick-up-list dup [
            2nip
        ] [
            3drop t
        ] ifte
    ] [
        2drop f
    ] ifte ;

: pick-up ( point gadget -- gadget )
    #! pick-up* returns t to mean 'this gadget', avoiding the
    #! exposed facade issue.
    tuck pick-up* dup t = [ drop ] [ nip ] ifte ;

! The hand is a special gadget that holds mouse position and
! mouse button click state. The hand's parent is the world, but
! it is special in that the world does not list it as part of
! its contents. Some comments on the slots:
! - hand-gadget is the gadget under the mouse position
! - hand-clicked is the most recently clicked gadget
! - hand-focus is the gadget holding keyboard focus
TUPLE: hand
    world
    click-pos clicked buttons
    gadget focus delegate ;

: grab ( gadget hand -- )
    #! Grab hold of a gadget; the gadget will move with the
    #! hand.
    2dup set-hand-clicked
    [ swap screen-pos swap screen-pos - >rect ] 2keep
    >r [ move-gadget ] keep r> add-gadget ;

: release* ( gadget world -- )
    >r dup screen-pos >r dup unparent
    r> >rect pick move-gadget
    r> add-gadget ;

: release ( hand -- )
    #! Release the gadget we are holding.
    dup gadget-children car swap hand-world release* ;

: hand-actions ( hand -- )
    #! A nice trick is that the hand is only consulted for
    #! gestures when one of its children is clicked.
    [ release ] [ button-up 1 ] set-action ;

C: hand ( world -- hand )
    <empty-gadget>
    over set-hand-delegate
    [ set-hand-world ] 2keep
    [ set-gadget-parent ] 2keep
    [ set-hand-gadget ] keep
    [ hand-actions ] keep ;

: button/ ( n hand -- )
    dup hand-gadget over set-hand-clicked
    dup shape-pos over set-hand-click-pos
    [ hand-buttons unique ] keep set-hand-buttons ;

: button\ ( n hand -- )
    [ hand-buttons remove ] keep set-hand-buttons ;

: fire-leave ( hand gadget -- )
    [ swap shape-pos swap screen-pos - ] keep mouse-leave ;

: fire-enter ( oldpos hand -- )
    hand-gadget [ screen-pos - ] keep mouse-enter ;

: find-hand-gadget ( hand -- gadget )
    #! The hand gadget is the gadget under the hand right now.
    dup gadget-children [ dup hand-world pick-up ] unless ;

: update-hand-gadget ( hand -- )
    dup find-hand-gadget swap set-hand-gadget ;

: motion-gesture ( hand gadget gesture -- )
    #! Send a gesture like [ drag 2 ].
    rot hand-buttons car unit append swap handle-gesture drop ;

: fire-motion ( hand -- )
    #! Fire a motion gesture to the gadget underneath the hand,
    #! and if a mouse button is down, fire a drag gesture to the
    #! gadget that was clicked.
    [ motion ] over hand-gadget handle-gesture drop
    dup hand-buttons [
        dup hand-clicked [ drag ] motion-gesture
    ] [
        drop
    ] ifte ;

: move-hand ( x y hand -- )
    dup shape-pos >r
    [ move-gadget ] keep
    dup hand-gadget >r
    dup update-hand-gadget
    dup r> fire-leave
    dup fire-motion
    r> swap fire-enter ;

: update-hand ( hand -- )
    #! Called when a gadget is removed or added.
    [ dup shape-x swap shape-y ] keep move-hand ;

: request-focus ( gadget hand -- )
    dup >r hand-focus
    2dup lose-focus
    swap dup r> set-hand-focus
    gain-focus ;

M: hand shape-clip
    #! The hand's children are not clipped.
    hand-world shape-clip ;
