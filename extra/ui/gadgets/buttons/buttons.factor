! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.controls ui.gadgets.labels ui.gadgets.theme
ui.gadgets.tracks ui.gadgets.packs ui.gadgets.worlds ui.gestures
ui.render kernel math models namespaces sequences strings
quotations assocs combinators classes colors tuples opengl
math.vectors ;
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

: <button> ( gadget quot -- button )
    button construct-empty
    [ set-button-quot ] keep
    [ set-gadget-delegate ] keep ;

TUPLE: button-paint plain rollover pressed selected ;

C: <button-paint> button-paint

: find-button [ [ button? ] is? ] find-parent ;

: button-paint ( button paint -- button paint )
    over find-button {
        { [ dup button-pressed? ] [ drop button-paint-pressed ] }
        { [ dup button-selected? ] [ drop button-paint-selected ] }
        { [ dup button-rollover? ] [ drop button-paint-rollover ] }
        { [ t ] [ drop button-paint-plain ] }
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

: checkbox-theme
    f over set-gadget-interior
    { 5 5 } over set-pack-gap
    1/2 swap set-pack-align ;

: <checkbox> ( model label -- checkbox )
    <checkmark>
    label-on-right
    over [ toggle-model drop ] curry <button>
    [ set-button-selected? ] <control>
    dup checkbox-theme ;

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

: <radio-control> ( model value gadget quot -- control )
    >r dupd [ set-control-value ] curry* r> call
    [ >r = r> set-button-selected? ] curry* <control> ; inline

: <radio-controls> ( model assoc quot -- gadget )
    swapd [ >r -rot r> call gadget, ] 2curry assoc-each ; inline

: radio-button-theme
    { 5 5 } over set-pack-gap 1/2 swap set-pack-align ;

: <radio-button> ( model value label -- gadget )
    <radio-knob> label-on-right
    [ <button> ] <radio-control>
    dup radio-button-theme ;

: radio-buttons-theme
    { 5 5 } swap set-pack-gap ;

: <radio-buttons> ( model assoc -- gadget )
    [ [ <radio-button> ] <radio-controls> ] make-filled-pile
    dup radio-buttons-theme ;

: <toggle-button> ( model value label -- gadget )
    [ <bevel-button> ] <radio-control> ;

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
