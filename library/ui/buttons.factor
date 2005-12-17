! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-buttons
USING: gadgets gadgets-borders gadgets-layouts gadgets-theme
generic io kernel lists math namespaces sequences sequences
styles threads ;

TUPLE: button rollover? pressed? ;

: button-down? ( -- ? ) hand get hand-buttons empty? not ;

: mouse-over? ( gadget -- ? ) hand get hand-gadget child? ;

: mouse-clicked? ( gadget -- ? ) hand get hand-clicked child? ;

: button-update ( button -- )
    dup mouse-over? over set-button-rollover?
    dup button-rollover? button-down? and
    over mouse-clicked? and over set-button-pressed?
    relayout-1 ;

: button-clicked ( button -- )
    #! If the mouse is released while still inside the button,
    #! fire an action gesture.
    dup button-update dup button-rollover?
    [ [ action ] swap handle-gesture ] when drop ;

: button-action ( action -- quot )
    [ [ swap handle-gesture drop ] cons ] [ [ drop ] ] if* ;

: button-gestures ( button quot -- )
    dupd [ action ] set-action
    dup [ button-clicked ] [ button-up ] set-action
    dup [ button-update ] [ button-down ] set-action
    dup [ button-update ] [ mouse-leave ] set-action
    [ button-update ] [ mouse-enter ] set-action ;

C: button ( gadget quot -- button )
    rot <border> over set-gadget-delegate
    [ swap button-gestures ] keep ;

: <highlight-button> ( gadget quot -- button )
    <button> { 0 0 0 } over set-border-size ;

: <roll-button> ( gadget quot -- button )
    <highlight-button> dup roll-button-theme ;

: <bevel-button> ( gadget quot -- button )
    <button> dup bevel-button-theme ;

: repeat-button-down ( button -- )
    dup 100 add-timer button-clicked ;

: repeat-button-up ( button -- )
    dup button-update remove-timer ;

: repeat-actions ( button -- )
    dup [ repeat-button-down ] [ button-down ] set-action
    [ repeat-button-up ] [ button-up ] set-action ;

: <repeat-button> ( gadget quot -- button )
    #! Button that calls the quotation every 100ms as long as
    #! the mouse is held down.
    <bevel-button> dup repeat-actions ;

M: button tick ( ms object -- ) nip button-clicked ;

TUPLE: button-paint plain rollover pressed ;

: button-paint ( button paint -- button paint )
    {
        { [ over button-pressed? ] [ button-paint-pressed ] }
        { [ over button-rollover? ] [ button-paint-rollover ] }
        { [ t ] [ button-paint-plain ] }
    } cond ;

M: button-paint draw-interior ( button paint -- )
    button-paint draw-interior ;

M: button-paint draw-boundary ( button paint -- )
    button-paint draw-boundary ;
