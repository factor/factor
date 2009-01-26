! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math models namespaces sequences
strings quotations assocs combinators classes colors
classes.tuple opengl opengl.gl math.vectors ui.commands ui.gadgets
ui.gadgets.borders ui.gadgets.labels ui.gadgets.theme
ui.gadgets.tracks ui.gadgets.packs ui.gadgets.worlds ui.gestures
ui.render math.geometry.rect locals alien.c-types
specialized-arrays.float fry combinators.smart ;
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
    >>pressed?
    relayout-1 ;

: if-clicked ( button quot -- )
    [ dup button-update dup button-rollover? ] dip [ drop ] if ;

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
    button-paint dup [ draw-interior ] [ 2drop ] if ;

M: button-paint draw-boundary
    button-paint dup [ draw-boundary ] [ 2drop ] if ;

: align-left ( button -- button )
    { 0 1/2 } >>align ; inline

: roll-button-theme ( button -- button )
    f black <solid> dup f <button-paint> >>boundary
    f f pressed-gradient f <button-paint> >>interior
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

TUPLE: checkmark-paint < caching-pen color last-vertices ;

: <checkmark-paint> ( color -- paint )
    checkmark-paint new swap >>color ;

<PRIVATE

: checkmark-points ( dim -- points )
    [
        {
            [ { 0 0 } v* { 0.5 0.5 } v+ ]
            [ { 1 1 } v* { 0.5 0.5 } v+ ]
            [ { 1 0 } v* { -0.3 0.5 } v+ ]
            [ { 0 1 } v* { -0.3 0.5 } v+ ]
        } cleave
    ] output>array ;

: checkmark-vertices ( dim -- vertices )
    checkmark-points concat >float-array ;

PRIVATE>

M: checkmark-paint recompute-pen
    swap dim>> checkmark-vertices >>last-vertices drop ;

M: checkmark-paint draw-interior
    [ compute-pen ]
    [ color>> gl-color ]
    [ last-vertices>> gl-vertex-pointer ] tri
    GL_LINES 0 4 glDrawArrays ;

: checkmark-theme ( gadget -- gadget )
    f
    f
    black <solid>
    black <checkmark-paint>
    <button-paint> >>interior
    black <solid> >>boundary ;

: <checkmark> ( -- gadget )
    <gadget>
    checkmark-theme
    { 14 14 } >>dim ;

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
    swap value>> >>selected? relayout-1 ;

TUPLE: radio-paint < caching-pen color interior-vertices boundary-vertices ;

: <radio-paint> ( color -- paint ) radio-paint new swap >>color ;

<PRIVATE

: circle-steps 8 ;

PRIVATE>

M: radio-paint recompute-pen
    swap dim>>
    [ { 4 4 } swap { 9 9 } v- circle-steps fill-circle-vertices >>interior-vertices ]
    [ { 1 1 } swap { 3 3 } v- circle-steps circle-vertices >>boundary-vertices ] bi
    drop ;

<PRIVATE

: (radio-paint) ( gadget paint -- )
    [ compute-pen ] [ color>> gl-color ] bi ;

PRIVATE>

M: radio-paint draw-interior
    [ (radio-paint) ] [ interior-vertices>> gl-vertex-pointer ] bi
    GL_POLYGON 0 circle-steps glDrawArrays ;

M: radio-paint draw-boundary
    [ (radio-paint) ] [ boundary-vertices>> gl-vertex-pointer ] bi
    GL_LINE_STRIP 0 circle-steps 1+ glDrawArrays ;

:: radio-knob-theme ( gadget -- gadget )
    black <radio-paint> :> radio-paint
    gadget
    f f radio-paint radio-paint <button-paint> >>interior
    radio-paint >>boundary
    { 16 16 } >>dim ;

: <radio-knob> ( -- gadget )
    <gadget> radio-knob-theme ;

TUPLE: radio-control < button value ;

: <radio-control> ( value model label -- control )
    [ [ value>> ] keep set-control-value ]
    radio-control new-button
        swap >>model
        swap >>value
        align-left ; inline

M: radio-control model-changed
    2dup [ value>> ] bi@ = >>selected? relayout-1 drop ;

:: <radio-controls> ( parent model assoc quot: ( value model label -- gadget ) -- parent )
    assoc model [ parent swap quot call add-gadget ] assoc-each ; inline

: radio-button-theme ( gadget -- gadget )
    { 5 5 } >>gap
    1/2 >>align ; inline

: <radio-button> ( value model label -- gadget )
    <radio-knob> label-on-right radio-button-theme <radio-control> ;

: <radio-buttons> ( model assoc -- gadget )
    <filled-pile>
        [ <radio-button> ] <radio-controls>
        { 5 5 } >>gap ;

: <toggle-button> ( value model label -- gadget )
    <radio-control> bevel-button-theme ;

: <toggle-buttons> ( model assoc -- gadget )
    <shelf>
        [ <toggle-button> ] <radio-controls> ;

: command-button-quot ( target command -- quot )
    '[ _ _ invoke-command drop ] ;

: <command-button> ( target gesture command -- button )
    [ command-string swap ] keep command-button-quot <bevel-button> ;

: <toolbar> ( target -- toolbar )
    <shelf>
        1 >>fill
        swap
        [ [ "toolbar" ] dip class command-map commands>> ] keep
        '[ [ _ ] 2dip <command-button> add-gadget ] assoc-each ;

: add-toolbar ( track -- track )
    dup <toolbar> f track-add ;
