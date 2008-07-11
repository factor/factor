! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math models namespaces sequences
strings quotations assocs combinators classes colors
classes.tuple opengl math.vectors
ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.labels ui.gadgets.theme ui.gadgets.wrappers
ui.gadgets.tracks ui.gadgets.packs ui.gadgets.worlds ui.gestures
ui.render ;
IN: ui.gadgets.buttons

TUPLE: button < wrapper pressed? selected? quot ;

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

: new-button ( label quot class -- button )
    new-gadget
        swap >>quot
        [ >r >label r> add-gadget ] keep ; inline

: <button> ( gadget quot -- button )
    button new-button ;

TUPLE: button-paint plain rollover pressed selected ;

C: <button-paint> button-paint

: find-button ( gadget -- button )
    [ [ button? ] is? ] find-parent ;

: button-paint ( button paint -- button paint )
    over find-button {
        { [ dup pressed?>> ] [ drop pressed>> ] }
        { [ dup selected?>> ] [ drop selected>> ] }
        { [ dup button-rollover? ] [ drop rollover>> ] }
        [ drop plain>> ]
    } cond ;

M: button-paint draw-interior
    button-paint draw-interior ;

M: button-paint draw-boundary
    button-paint draw-boundary ;

: roll-button-theme ( button -- button )
    f black <solid> dup f <button-paint> >>boundary ; inline

: <roll-button> ( label quot -- button )
    <button> roll-button-theme ;

: <bevel-button-paint> ( -- paint )
    plain-gradient
    rollover-gradient
    pressed-gradient
    selected-gradient
    <button-paint> ;

: bevel-button-theme ( gadget -- gadget )
    <bevel-button-paint> >>interior
    faint-boundary ; inline

: >bevel-label ( label -- gadget )
    >label 5 <border> ;

: <bevel-button> ( label quot -- button )
    >r >bevel-label r> <button> bevel-button-theme ;

TUPLE: repeat-button < button ;

repeat-button H{
    { T{ drag } [ button-clicked ] }
} set-gestures

: <repeat-button> ( label quot -- button )
    #! Button that calls the quotation every 100ms as long as
    #! the mouse is held down.
    >r >bevel-label r> repeat-button new-button bevel-button-theme ;

TUPLE: checkmark-paint color ;

C: <checkmark-paint> checkmark-paint

M: checkmark-paint draw-interior
    checkmark-paint-color gl-color
    origin get [
        rect-dim
        { 0 0 } over gl-line
        dup { 0 1 } v* swap { 1 0 } v* gl-line
    ] with-translation ;

: checkmark-theme ( gadget -- )
    f
    f
    black <solid>
    black <checkmark-paint>
    <button-paint>
    over set-gadget-interior
    black <solid>
    swap set-gadget-boundary ;

: <checkmark> ( -- gadget )
    <gadget>
    dup checkmark-theme
    { 14 14 } over set-gadget-dim ;

: toggle-model ( model -- )
    [ not ] change-model ;

: checkbox-theme ( gadget -- gadget )
    f >>interior
    { 5 5 } >>gap
    1/2 >>align ; inline

TUPLE: checkbox < button ;

: <checkbox> ( model label -- checkbox )
    <checkmark> label-on-right checkbox-theme
    [ model>> toggle-model ]
    checkbox new-button
        swap >>model ;

M: checkbox model-changed
    swap model-value over set-button-selected? relayout-1 ;

TUPLE: radio-paint color ;

C: <radio-paint> radio-paint

M: radio-paint draw-interior
    radio-paint-color gl-color
    origin get { 4 4 } v+ swap rect-dim { 8 8 } v- 12 gl-fill-circle ;

M: radio-paint draw-boundary
    radio-paint-color gl-color
    origin get { 1 1 } v+ swap rect-dim { 2 2 } v- 12 gl-circle ;

: radio-knob-theme ( gadget -- )
    f
    f
    black <radio-paint>
    black <radio-paint>
    <button-paint>
    over set-gadget-interior
    black <radio-paint>
    swap set-gadget-boundary ;

: <radio-knob> ( -- gadget )
    <gadget>
    dup radio-knob-theme
    { 16 16 } over set-gadget-dim ;

TUPLE: radio-control < button value ;

: <radio-control> ( value model label -- control )
    [ [ value>> ] keep set-control-value ]
    radio-control new-button
        swap >>model
        swap >>value ; inline

M: radio-control model-changed
    swap model-value
    over radio-control-value =
    over set-button-selected?
    relayout-1 ;

: <radio-controls> ( model assoc quot -- )
    #! quot has stack effect ( value model label -- )
    swapd [ swapd call gadget, ] 2curry assoc-each ; inline

: radio-button-theme ( gadget -- gadget )
    { 5 5 } >>gap
    1/2 >>align ; inline

: <radio-button> ( value model label -- gadget )
    <radio-knob> label-on-right radio-button-theme <radio-control> ;

: radio-buttons-theme ( gadget -- )
    { 5 5 } >>gap drop ;

: <radio-buttons> ( model assoc -- gadget )
    [ [ <radio-button> ] <radio-controls> ] make-filled-pile
    dup radio-buttons-theme ;

: <toggle-button> ( value model label -- gadget )
    >bevel-label <radio-control> bevel-button-theme ;

: <toggle-buttons> ( model assoc -- gadget )
    [ [ <toggle-button> ] <radio-controls> ] make-shelf ;

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
