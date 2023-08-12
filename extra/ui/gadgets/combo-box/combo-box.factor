! Copyright (C) 2023 Raghu Ranganathan.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays colors combinators kernel math math.rectangles
math.vectors models namespaces opengl prettyprint sequences
sorting ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.editors ui.gadgets.glass
ui.gadgets.labels ui.gadgets.packs ui.gadgets.worlds
ui.gestures ui.operations ui.pens ui.gadgets.line-support
ui.pens.solid ui.theme ui.gadgets.panes fonts ;
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

:: <combo-button> ( label editor -- combo-button )
    label [
        label gadget-text editor set-editor-string
        hide-glass
    ] combo-button
    new-button combo-button-theme ; inline

PRIVATE>

<PRIVATE

:: (show-menu) ( owner menu -- )
    owner find-world menu 
    owner screen-loc 0 owner dim>> second 2array v+ point>rect
    show-glass ;
    
PRIVATE>

: show-menu ( owner menu -- )
    [ (show-menu) ] keep request-focus ;
    
    
GENERIC: <combo-item>  ( editor name -- combo-item )

M: object <combo-item> ( editor name -- combo-item )
    <label> swap <combo-button> ;

: <combo-items> ( items -- gadget )
    <filled-pile> swap add-gadgets dup
    default-font-background-color get-global <solid> swap interior<< ;

:: <combo-box> ( items -- combo-box )
    <editor> 16 >>line-height :> txt
    14 txt min-cols<<
    items [ txt <combo-button> ] map <combo-items> :> cmenu
    "Choose an item" txt set-editor-string
    "v" <label> [ drop txt cmenu show-menu ] <button> :> btn
    ! items txt [ display swap <combo-item> ] curry map <combo-items> :> menu
    <shelf> { txt btn } [
        dup default-font-foreground-color get-global
        <solid> swap boundary<<
    ] map add-gadgets
    { 5 12 } >>gap ;
    
: test-code ( -- )
  { "Hello" "World" } [ <label> ] map <combo-box> gadget. ;
