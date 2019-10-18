! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.controls ui.gadgets.labels ui.gadgets.theme
ui.gadgets.tracks ui.gadgets.packs ui.gadgets.worlds ui.gestures
ui.render kernel math models namespaces sequences strings
quotations assocs combinators classes colors ;
IN: ui.gadgets.buttons

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
M: array >label <label> ;
M: object >label ;
M: f >label drop <gadget> ;

: <button> ( gadget quot -- button )
    button construct-empty
    [ set-button-quot ] keep
    [ set-gadget-delegate ] keep ;

TUPLE: button-paint plain rollover pressed selected ;

C: <button-paint> button-paint

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

: roll-button-theme ( button -- )
    f black <solid> dup f <button-paint>
    swap set-gadget-boundary ;

: <roll-button> ( label quot -- button )
    >r >label r>
    <button> dup roll-button-theme ;

: bevel-button-theme ( gadget -- )
    plain-gradient
    rollover-gradient
    pressed-gradient
    selected-gradient
    <button-paint> over set-gadget-interior
    faint-boundary ;

: <bevel-button> ( label quot -- button )
    >r >label 5 <border> r>
    <button> dup bevel-button-theme ;

TUPLE: repeat-button ;

repeat-button H{
    { T{ drag } [ button-clicked ] }
} set-gestures

: <repeat-button> ( label quot -- button )
    #! Button that calls the quotation every 100ms as long as
    #! the mouse is held down.
    repeat-button construct-empty
    [ >r <bevel-button> r> set-gadget-delegate ] keep ;

: <radio-control> ( model value label -- gadget )
    over [ swap set-control-value ] curry <bevel-button>
    swap [ swap >r = r> set-button-selected? ] curry <control> ;

: <radio-box> ( model assoc -- gadget )
    [
        swap [ -rot <radio-control> gadget, ] curry assoc-each
    ] make-shelf ;

: command-button-quot ( target command -- quot )
    [ invoke-command drop ] 2curry ;

: <command-button> ( target gesture command -- button )
    [ command-string ] keep
    swapd
    command-button-quot
    <bevel-button> ;

: <toolbar> ( target -- toolbar )
    [
        "toolbar" over class command-map swap
        [ -rot <command-button> gadget, ] curry assoc-each
    ] make-shelf ;

: toolbar, ( -- ) g <toolbar> f track, ;
