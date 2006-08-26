! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-buttons
USING: gadgets gadgets-borders gadgets-controls gadgets-labels
gadgets-theme generic io kernel math models namespaces sequences
strings styles threads words ;

TUPLE: button rollover? pressed? selected? quot ;

: buttons-down? ( -- ? )
    hand-buttons get-global empty? not ;

: mouse-over? ( gadget -- ? )
    hand-gadget get-global child? ;

: mouse-clicked? ( gadget -- ? )
    hand-clicked get-global child? ;

: button-update ( button -- )
    dup mouse-over? over set-button-rollover?
    dup mouse-clicked? buttons-down? and
    over button-rollover? and over set-button-pressed?
    relayout-1 ;

: if-clicked ( button quot -- )
    >r dup button-update dup button-rollover? r> [ drop ] if ;

: button-clicked ( button -- )
    dup button-quot if-clicked ;

button H{
    { T{ button-up } [ button-clicked ] }
    { T{ button-down } [ button-update ] }
    { T{ mouse-leave } [ button-update ] }
    { T{ mouse-enter } [ button-update ] }
} set-gestures

GENERIC: >label ( obj -- gadget )
M: string >label <label> ;
M: object >label ;

C: button ( gadget quot -- button )
    rot >label <default-border> over set-gadget-delegate
    [ set-button-quot ] keep ;

: <highlight-button> ( gadget quot -- button )
    <button> { 0 0 } over set-border-size ;

: <roll-button> ( gadget quot -- button )
    <highlight-button> dup roll-button-theme ;

: <bevel-button> ( gadget quot -- button )
    <button> dup bevel-button-theme ;

: repeat-button-down ( button -- )
    dup 100 add-timer button-clicked ;

: repeat-button-up ( button -- )
    dup button-update remove-timer ;

TUPLE: repeat-button ;

repeat-button H{
    { T{ button-down } [ repeat-button-down ] }
    { T{ button-up } [ repeat-button-up ] }
} set-gestures

C: repeat-button ( gadget quot -- button )
    #! Button that calls the quotation every 100ms as long as
    #! the mouse is held down.
    [ >r <bevel-button> r> set-gadget-delegate ] keep ;

M: repeat-button tick nip button-clicked ;

TUPLE: button-paint plain rollover pressed selected ;

: button-paint ( button paint -- button paint )
    {
        { [ over button-pressed? ] [ button-paint-pressed ] }
        { [ over button-selected? ] [ button-paint-selected ] }
        { [ over button-rollover? ] [ button-paint-rollover ] }
        { [ t ] [ button-paint-plain ] }
    } cond ;

M: button-paint draw-interior
    button-paint draw-interior ;

M: button-paint draw-boundary
    button-paint draw-boundary ;

: <radio-control> ( model value gadget -- gadget )
    over [ swap control-model set-model ] curry <bevel-button>
    swap [ swap >r = r> set-button-selected? ] curry <control> ;

: <radio-box> ( model assoc -- gadget )
    [ first2 <radio-control> ] map-with
    make-shelf dup highlight-theme ;
