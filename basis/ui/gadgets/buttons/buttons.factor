! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math models namespaces sequences
       strings quotations assocs combinators classes colors
       classes.tuple opengl math.vectors
       ui.commands ui.gadgets ui.gadgets.borders
       ui.gadgets.labels ui.gadgets.theme
       ui.gadgets.tracks ui.gadgets.packs ui.gadgets.worlds ui.gestures
       ui.render math.geometry.rect ;

IN: ui.gadgets.buttons

TUPLE: button < border pressed? selected? quot ;

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
    over (>>pressed?)
    relayout-1 ;

: if-clicked ( button quot -- )
    >r dup button-update dup button-rollover? r> [ drop ] if ;

: button-clicked ( button -- ) dup quot>> if-clicked ;

button H{
    { T{ button-up } [ button-clicked ] }
    { T{ button-down } [ button-update ] }
    { T{ mouse-leave } [ button-update ] }
    { T{ mouse-enter } [ button-update ] }
} set-gestures

: new-button ( label quot class -- button )
    [ swap >label ] dip new-border swap >>quot ; inline

: <button> ( label quot -- button )
    button new-button ;

TUPLE: button-paint plain rollover pressed selected ;

C: <button-paint> button-paint

: find-button ( gadget -- button )
    [ button? ] find-parent ;

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

: align-left ( button -- button )
    { 0 1/2 } >>align ; inline

: roll-button-theme ( button -- button )
    f black <solid> dup f <button-paint> >>boundary
    align-left ; inline

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
    { 5 5 } >>size
    faint-boundary ; inline

: <bevel-button> ( label quot -- button )
    <button> bevel-button-theme ;

TUPLE: repeat-button < button ;

repeat-button H{
    { T{ drag } [ button-clicked ] }
} set-gestures

: <repeat-button> ( label quot -- button )
    #! Button that calls the quotation every 100ms as long as
    #! the mouse is held down.
    repeat-button new-button bevel-button-theme ;

TUPLE: checkmark-paint color ;

C: <checkmark-paint> checkmark-paint

M: checkmark-paint draw-interior
    color>> set-color
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
    over (>>interior)
    black <solid>
    swap (>>boundary) ;

: <checkmark> ( -- gadget )
    <gadget>
    dup checkmark-theme
    { 14 14 } over (>>dim) ;

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
        swap >>model
        align-left ;

M: checkbox model-changed
    swap model-value over (>>selected?) relayout-1 ;

TUPLE: radio-paint color ;

C: <radio-paint> radio-paint

M: radio-paint draw-interior
    color>> set-color
    origin get { 4 4 } v+ swap rect-dim { 8 8 } v- 12 gl-fill-circle ;

M: radio-paint draw-boundary
    color>> set-color
    origin get { 1 1 } v+ swap rect-dim { 2 2 } v- 12 gl-circle ;

: radio-knob-theme ( gadget -- )
    f
    f
    black <radio-paint>
    black <radio-paint>
    <button-paint>
    over (>>interior)
    black <radio-paint>
    swap (>>boundary) ;

: <radio-knob> ( -- gadget )
    <gadget>
    dup radio-knob-theme
    { 16 16 } over (>>dim) ;

TUPLE: radio-control < button value ;

: <radio-control> ( value model label -- control )
    [ [ value>> ] keep set-control-value ]
    radio-control new-button
        swap >>model
        swap >>value
        align-left ; inline

M: radio-control model-changed
    swap model-value
    over value>> =
    over (>>selected?)
    relayout-1 ;

: <radio-controls> ( parent model assoc quot -- parent )
  #! quot has stack effect ( value model label -- )
  swapd [ swapd call add-gadget ] 2curry assoc-each ; inline

: radio-button-theme ( gadget -- gadget )
    { 5 5 } >>gap
    1/2 >>align ; inline

: <radio-button> ( value model label -- gadget )
    <radio-knob> label-on-right radio-button-theme <radio-control> ;

: <radio-buttons> ( model assoc -- gadget )
  <filled-pile>
    -rot
    [ <radio-button> ] <radio-controls>
  { 5 5 } >>gap ;

: <toggle-button> ( value model label -- gadget )
    <radio-control> bevel-button-theme ;

: <toggle-buttons> ( model assoc -- gadget )
  <shelf>
    -rot
    [ <toggle-button> ] <radio-controls> ;

: command-button-quot ( target command -- quot )
    [ invoke-command drop ] 2curry ;

: <command-button> ( target gesture command -- button )
    [ command-string ] keep
    swapd
    command-button-quot
    <bevel-button> ;

: <toolbar> ( target -- toolbar )
  <shelf>
    swap
    "toolbar" over class command-map commands>> swap
    [ -rot <command-button> add-gadget ] curry assoc-each ;
