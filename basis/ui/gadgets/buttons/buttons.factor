! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.tuple colors
colors.constants combinators combinators.short-circuit
combinators.smart fry kernel locals math math.rectangles
math.vectors models namespaces opengl opengl.gl quotations
sequences strings ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.labels ui.gadgets.packs ui.gadgets.theme
ui.gadgets.tracks ui.gadgets.worlds ui.gestures ui.pens
ui.pens.image ui.pens.solid ui.pens.tile ;
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

PRIVATE>

: button-update ( button -- )
    dup
    { [ mouse-clicked? ] [ button-rollover? ] } 1&&
    buttons-down? and
    >>pressed?
    relayout-1 ;

: button-enter ( button -- )
    dup dup tooltip>> [ swap show-status ] [ drop ] if* button-update ;

: button-leave ( button -- )
    dup "" swap show-status button-update ;

: button-clicked ( button -- )
    [ ]
    [ button-update ]
    [ button-rollover? ] tri
    [ dup quot>> call( button -- ) ] [ drop ] if ;

button H{
    { T{ button-up } [ button-clicked ] }
    { T{ button-down } [ button-update ] }
    { mouse-leave [ button-leave ] }
    { mouse-enter [ button-enter ] }
} set-gestures

: new-button ( label quot class -- button )
    [ swap >label ] dip new-border swap >>quot ; inline

: <button> ( label quot -- button )
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
    lookup-button-pen dup [ draw-interior ] [ 2drop ] if ;

M: button-pen draw-boundary
    lookup-button-pen dup [ draw-boundary ] [ 2drop ] if ;

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

: roll-button-theme ( button -- button )
    f COLOR: black <solid> dup f f <button-pen> >>boundary
    f f COLOR: dark-gray <solid> f f <button-pen> >>interior
    align-left ; inline

PRIVATE>

: <roll-button> ( label quot -- button )
    <button> roll-button-theme ;

<PRIVATE

: <border-button-state-pen> ( prefix background foreground -- pen )
    [
        "-left" "-middle" "-right"
        [ append theme-image ] tri-curry@ tri
    ] 2dip <tile-pen> ;

CONSTANT: button-background COLOR: FactorTan
CONSTANT: button-clicked-background COLOR: FactorDarkSlateBlue

: <border-button-pen> ( -- pen )
    "button" button-background button-clicked-background
    <border-button-state-pen> dup
    "button-clicked" button-clicked-background COLOR: white
    <border-button-state-pen> dup dup
    <button-pen> ;

: border-button-label-theme ( gadget -- )
    dup label? [ [ clone t >>bold? ] change-font ] when drop ;

: border-button-theme ( gadget -- gadget )
    dup gadget-child border-button-label-theme
    horizontal >>orientation
    <border-button-pen> >>interior
    dup dup interior>> pen-pref-dim >>min-dim
    { 10 0 } >>size ; inline

PRIVATE>

: <border-button> ( label quot -- button )
    <button> border-button-theme ;

TUPLE: repeat-button < button ;

repeat-button H{
    { T{ button-down } [ button-clicked ] }
    { T{ drag } [ button-clicked ] }
    { T{ button-up } [ button-update ] }
} set-gestures

: <repeat-button> ( label quot -- button )
    #! Button that calls the quotation every 100ms as long as
    #! the mouse is held down.
    repeat-button new-button border-button-theme ;

<PRIVATE

: <checkmark-pen> ( -- pen )
    "checkbox" theme-image <image-pen>
    "checkbox" theme-image <image-pen>
    "checkbox-clicked" theme-image <image-pen>
    "checkbox-set" theme-image <image-pen>
    "checkbox-set-clicked" theme-image <image-pen>
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

: <radio-pen> ( -- pen )
    "radio" theme-image <image-pen>
    "radio" theme-image <image-pen>
    "radio-clicked" theme-image <image-pen>
    "radio-set" theme-image <image-pen>
    "radio-set-clicked" theme-image <image-pen>
    <button-pen> ;

: <radio-knob> ( -- gadget )
    <gadget>
    <radio-pen> >>interior
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

: <command-button> ( target gesture command -- button )
    swapd [ command-name swap ] keep command-button-quot
    '[ drop @ ] <border-button> swap gesture>tooltip >>tooltip ;

: <toolbar> ( target -- toolbar )
    <shelf>
        1 >>fill
        { 5 5 } >>gap
        swap
        [ [ "toolbar" ] dip class-of get-command-at commands>> ]
        [ '[ [ _ ] 2dip <command-button> add-gadget ] ]
        bi assoc-each ;

: add-toolbar ( track -- track )
    dup <toolbar> { 3 3 } <border> align-left f track-add ;
