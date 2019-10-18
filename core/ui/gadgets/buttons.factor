! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-buttons
USING: gadgets gadgets-borders gadgets-labels
gadgets-theme generic io kernel math models namespaces sequences
strings styles threads words hashtables quotations assocs ;

TUPLE: button pressed? selected? quot ;

: buttons-down? ( -- ? )
    hand-buttons get-global empty? not ;

: button-rollover? ( button -- ? )
    hand-gadget get-global child? ;

: mouse-clicked? ( gadget -- ? )
    hand-clicked get-global child? ;

: button-update ( button -- )
    dup mouse-clicked?
    over button-rollover? and
    buttons-down? and
    over set-button-pressed?
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
M: f >label drop <gadget> ;

C: button ( gadget quot -- button )
    [ set-button-quot ] keep
    [ set-gadget-delegate ] keep ;

: <roll-button> ( label quot -- button )
    >r >label r>
    <button> dup roll-button-theme ;

: <bevel-button> ( label quot -- button )
    >r >label 5 <border> r>
    <button> dup bevel-button-theme ;

TUPLE: repeat-button ;

repeat-button H{
    { T{ drag } [ button-clicked ] }
} set-gestures

C: repeat-button ( label quot -- button )
    #! Button that calls the quotation every 100ms as long as
    #! the mouse is held down.
    [ >r <bevel-button> r> set-gadget-delegate ] keep ;

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

: <radio-control> ( model value label -- gadget )
    over [ swap set-control-value ] curry <bevel-button>
    swap [ swap >r = r> set-button-selected? ] curry <control> ;

: <radio-box> ( model assoc -- gadget )
    [
        [ <radio-control> gadget, ] assoc-each-with
    ] make-shelf ;

: command-button-quot ( target command -- quot )
    [ invoke-command drop ] curry curry ;

: <command-button> ( target gesture command -- button )
    [ command-string ] keep
    swapd
    command-button-quot
    <bevel-button> ;

: <toolbar> ( target -- toolbar )
    [
        "toolbar" over class command-map
        [ <command-button> gadget, ] assoc-each-with
    ] make-shelf ;

: <menu-item> ( hook target command -- button )
    dup command-name -rot command-button-quot
    swapd
    [ hand-clicked get find-world hide-glass ]
    3append <roll-button> ;

: <commands-menu> ( hook target commands -- gadget )
    [
        [ >r 2dup r> <menu-item> gadget, ] each 2drop
    ] make-filled-pile 5 <border> dup menu-theme ;
