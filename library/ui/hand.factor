! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien generic kernel lists math namespaces sdl sdl-event
sdl-video ;

! The hand is a special gadget that holds mouse position and
! mouse button click state. The hand's parent is the world, but
! it is special in that the world does not list it as part of
! its contents.
TUPLE: hand click-pos clicked buttons delegate ;

C: hand ( -- hand )
    0 <gadget> <ghost> <box>
    over set-hand-delegate ;

GENERIC: hand-gesture ( hand gesture -- )

M: object hand-gesture ( hand gesture -- ) 2drop ;

: button/ ( n hand -- )
    [ hand-buttons unique ] keep set-hand-buttons ;

: button\ ( n hand -- )
    [ hand-buttons remove ] keep set-hand-buttons ;

M: button-down-event hand-gesture ( hand gesture -- )
    2dup
    dup button-event-x swap button-event-y rect>
    swap set-hand-click-pos
    button-event-button swap button/ ;

M: button-up-event hand-gesture ( hand gesture -- )
    button-event-button swap button\ ;

M: motion-event hand-gesture ( hand gesture -- )
    dup motion-event-x swap motion-event-y rot move-gadget ;

M: hand redraw ( hand -- )
    drop world get redraw ;
