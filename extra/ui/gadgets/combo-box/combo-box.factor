! Copyright (C) 2023 Raghu Ranganathan.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors combinators kernel math math.rectangles
math.vectors models namespaces opengl prettyprint sequences
sorting ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.editors ui.gadgets.glass
ui.gadgets.labels ui.gadgets.packs ui.gadgets.worlds
ui.gadgets.wrappers ui.gestures ui.operations ui.pens
ui.pens.solid ui.theme ;
IN: ui.gadgets.combo-box

! Design: An editor and button.
! If either is clicked, the editor will be focused and a menu will display underneath.
! Each option should come with a quot. Or maybe I can simply take buttons for each option,
! to keep it flexible.
! A comparison quote may be taken to filter the options in the menu.


TUPLE: combo-button < button ;
TUPLE: combo-editor < editor menu ;

<PRIVATE

: align-left ( combo-button -- combo-button )
    { 0 1/2 } >>align ; inline
    
MEMO: combo-button-pen-boundary ( -- pen )
    f f roll-button-rollover-border <solid> dup dup <button-pen> ;

MEMO: combo-button-pen-interior ( -- pen )
    f f roll-button-selected-background <solid> f over <button-pen> ;

: combo-button-theme ( combo-button -- combo-button )
    combo-button-pen-boundary >>boundary
    combo-button-pen-interior >>interior
    align-left ; inline

: <combo-button> ( label quot -- combo-button )
    combo-button new-button combo-button-theme ; inline

PRIVATE>

GENERIC: <combo-item>  ( display-model name -- combo-item )

M:: object <combo-item> ( display-model name -- combo-item )
    name <label> [
        name display-model set-model 
        hide-glass
    ] <combo-button> ;

: <combo-items> ( items -- gadget )
    <filled-pile> swap add-gadgets ;


:: <combo-box> ( items -- combo-box )
    <editor> :> txt
    "Choose an item" txt set-editor-string
    "v" <label> [ . ] <button> :> btn
    ! items txt [ display swap <combo-item> ] curry map <combo-items> :> menu
    <shelf> { txt btn } add-gadgets { 5 12 } >>gap
    ;
