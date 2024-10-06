! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs colors combinators
combinators.short-circuit combinators.smart fry kernel literals
locals math math.vectors memoize models namespaces sequences
ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.labels
ui.gadgets.packs ui.gadgets.worlds ui.gestures ui.pens
ui.pens.polygon ui.pens.solid ui.theme ;
FROM: models => change-model ;
IN: ui.gadgets.buttons

TUPLE: button < border pressed? selected? quot tooltip ;

<PRIVATE

: find-button ( gadget -- button )
    [ button? ] find-parent ;

: buttons-down? ( -- ? )
    hand-buttons get-global empty? not ;

: button-rollover? ( button -- ? )
    hand-gadget get-global child? ;

: mouse-clicked? ( gadget -- ? )
    hand-clicked get-global child? ;

: button-pressed? ( button -- ? )
    { [ mouse-clicked? ] [ button-rollover? ] } 1&&
    buttons-down? and ;

PRIVATE>

: button-update ( button -- )
    dup button-pressed? >>pressed? relayout-1 ;

: button-enter ( button -- )
    dup tooltip>> [ over show-status ] when* button-update ;

: button-leave ( button -- )
    [ hide-status ] [ button-update ] bi ;

: button-invoke ( button -- )
    dup quot>> call( button -- ) ;

: button-clicked ( button -- )
    [ ]
    [ button-update ]
    [ button-rollover? ] tri
    [ button-invoke ] [ drop ] if ;

button H{
    { T{ button-up } [ button-clicked ] }
    { T{ button-down } [ button-update ] }
    { mouse-leave [ button-leave ] }
    { mouse-enter [ button-enter ] }
} set-gestures

: new-button ( label quot class -- button )
    [ swap >label ] dip new-border swap >>quot ; inline

: <button> ( label quot: ( button -- ) -- button )
    button new-button ;

TUPLE: button-pen
    plain rollover
    pressed selected pressed-selected ;

C: <button-pen> button-pen

: lookup-button-pen ( button pen -- button pen )
    over find-button {
        { [ dup { [ pressed?>> ] [ selected?>> ] } 1&& ] [
            drop pressed-selected>>
        ] }
        { [ dup pressed?>> ] [ drop pressed>> ] }
        { [ dup selected?>> ] [ drop selected>> ] }
        { [ dup button-rollover? ] [ drop rollover>> ] }
        [ drop plain>> ]
    } cond ;

M: button-pen draw-interior
    lookup-button-pen [ draw-interior ] [ drop ] if* ;

M: button-pen draw-boundary
    lookup-button-pen [ draw-boundary ] [ drop ] if* ;

M: button-pen pen-pref-dim
    [
        {
            [ plain>> pen-pref-dim ]
            [ rollover>> pen-pref-dim ]
            [ pressed>> pen-pref-dim ]
            [ selected>> pen-pref-dim ]
        } 2cleave
    ] [ vmax ] reduce-outputs ;

M: button-pen pen-background
    lookup-button-pen pen-background ;

M: button-pen pen-foreground
    lookup-button-pen pen-foreground ;

<PRIVATE

: align-left ( button -- button )
    { 0 1/2 } >>align ; inline

MEMO: button-pen-boundary ( -- button-pen )
    f roll-button-rollover-border <solid> dup f f <button-pen> ;

MEMO: button-pen-interior ( -- button-pen )
    f f roll-button-selected-background <solid> f f <button-pen> ;

: roll-button-theme ( button -- button )
    button-pen-boundary >>boundary
    button-pen-interior >>interior
    align-left ; inline

PRIVATE>

: <roll-button> ( label quot: ( button -- ) -- button )
    <button> roll-button-theme ;

<PRIVATE

: <border-button-pen> ( -- pen )
    content-background <solid>
    toolbar-background <solid>
    selection-color <solid>
    roll-button-rollover-border <solid>
    toolbar-button-pressed-background <solid>
    <button-pen>
    ;

: border-button-label-theme ( gadget -- )
    dup label? [ [ clone t >>bold? ] change-font ] when drop ;

: border-button-theme ( gadget -- gadget )
    dup gadget-child border-button-label-theme
    horizontal >>orientation
    <border-button-pen> >>interior
    { 10 2 } >>size ; inline

PRIVATE>

: <border-button> ( label quot: ( button -- ) -- button )
    <button> border-button-theme
    field-border-color <solid> >>boundary ;

TUPLE: repeat-button < button ;

repeat-button H{
    { T{ button-down } [ button-clicked ] }
    { T{ drag } [ button-clicked ] }
    { T{ button-up } [ button-update ] }
} set-gestures

: <repeat-button> ( label quot: ( button -- ) -- button )
    ! Button that calls the quotation every 100ms as long as
    ! the mouse is held down.
    repeat-button new-button border-button-theme ;

<PRIVATE

CONSTANT: checkmark-dim 12
CONSTANT: checkmark-square { { 0 0 } { 0 $ checkmark-dim } { $ checkmark-dim $ checkmark-dim } { $ checkmark-dim 0 } } 
: <checkmark-pen> ( -- pen )
    roll-button-rollover-border checkmark-square <polygon>
    roll-button-rollover-border checkmark-square <polygon>
    dim-color checkmark-square <polygon>
    errors-color checkmark-square <polygon>
    toolbar-button-pressed-background checkmark-square <polygon>
    <button-pen> ;

: <checkmark> ( -- gadget )
    <gadget>
    <checkmark-pen> >>interior
    dup dup interior>> pen-pref-dim >>dim ;

: toggle-model ( model -- )
    [ not ] change-model ;

PRIVATE>

TUPLE: checkbox < button ;

: <checkbox> ( model label -- checkbox )
    <checkmark> label-on-right
    [ model>> toggle-model ]
    checkbox new-button
        swap >>model
        align-left ;

M: checkbox model-changed
    swap value>> >>selected? relayout-1 ;
<PRIVATE

CONSTANT: circle-points 12
CONSTANT: checkmark-dim/2 $[ $ checkmark-dim 2 / ]
CONSTANT: checkmark-rhombus { { 0 $ checkmark-dim/2 } { $ checkmark-dim/2 $ checkmark-dim } { $ checkmark-dim $ checkmark-dim/2 } { $ checkmark-dim/2 0 } } 
CONSTANT: checkmark-circle $[ $ circle-points $ checkmark-dim polygon-circle ]
: <radio-pen> ( -- pen )
    roll-button-rollover-border checkmark-circle <polygon>
    roll-button-rollover-border checkmark-circle <polygon>
    dim-color checkmark-circle <polygon>
    errors-color checkmark-circle <polygon>
    toolbar-button-pressed-background checkmark-circle <polygon>
    <button-pen>
    ;

: <radio-knob> ( -- gadget )
    <gadget>
    <radio-pen> >>interior checkmark-circle max-dims >>dim
    dup dup interior>> pen-pref-dim >>dim ;

TUPLE: radio-control < button value ;

: <radio-control> ( value model label -- control )
    [ [ value>> ] keep set-control-value ]
    radio-control new-button
        swap >>model
        swap >>value
        align-left ; inline

M: radio-control model-changed
    2dup [ value>> ] same? >>selected? relayout-1 drop ;

:: <radio-controls> ( model assoc parent quot: ( value model label -- gadget ) -- parent )
    parent assoc [ model swap quot call add-gadget ] assoc-each ; inline

PRIVATE>

: <radio-button> ( value model label -- gadget )
    <radio-knob> label-on-right <radio-control> ;

: <radio-buttons> ( model assoc -- gadget )
    <filled-pile>
        [ <radio-button> ] <radio-controls>
        { 5 5 } >>gap ;

: command-button-quot ( target command -- quot )
    '[ _ _ invoke-command ] ;

: gesture>tooltip ( gesture -- str/f )
    gesture>string dup [ "Shortcut: " prepend ] when ;

:: <command-button> ( target gesture command -- button )
    command command-name
    target command command-button-quot
    '[ drop @ ] <border-button>
    gesture gesture>tooltip >>tooltip ; inline
