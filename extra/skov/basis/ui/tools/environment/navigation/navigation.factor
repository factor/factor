! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.smart kernel models sequences
skov.basis.code skov.basis.code.execution
skov.basis.ui.pens.gradient-rounded
skov.basis.ui.tools.environment.cell
skov.basis.ui.tools.environment.navigation.dot-pattern
skov.basis.ui.tools.environment.theme
skov.basis.ui.tools.environment.tree ui.gadgets ui.gadgets.borders
ui.gadgets.labels ui.gadgets.packs ui.gestures ;
FROM: models => change-model ;
IN: skov.basis.ui.tools.environment.navigation

TUPLE: navigation < pack ;

: <category> ( background name -- gadget )
    <label>
    [ t >>bold? ] change-font { 26 0 } <border>
    swap dark-text-colour <gradient-pointy> >>interior
    { 0 22 } >>min-dim horizontal >>orientation ;

: <name-bar> ( vocab/word selection -- gadget )
    <cell> { 0 30 } >>min-dim ;

: <navigation> ( model -- navigation )
     navigation new swap >>model vertical >>orientation 1 >>fill ;

:: new-item ( navigation class -- )
    navigation control-value [ vocab? ] find-parent
    class add-from-class contents>> last navigation set-control-value ;

: find-navigation ( gadget -- navigation )
    [ navigation? ] find-parent ;

: set-children-font ( gadget -- gadget )
    dup children>> [ [ label? ] [ set-result-font drop ] [ set-children-font drop ] smart-if ] each ;

M:: navigation model-changed ( model gadget -- )
    gadget dup clear-gadget
    model value>> parents [ vocab? ] filter reverse
    dup last :> voc
    [ model <name-bar> ] map add-gadgets
    blue-background "Vocabularies" <category> { 0 10 } <border> <dot-pattern> add-gadget
    voc contents>> [ vocab? ] filter vocab new "⨁" >>name suffix [ model <name-bar> ] map add-gadgets
    green-background "Words" <category> { 0 10 } <border> <dot-pattern> add-gadget
    voc contents>> [ word? ] filter word new "⨁" >>name suffix [ 
        [ model <name-bar> add-gadget ] 
        [ [ model value>> eq? ]
          [ <tree-editor> { 10 15 } <border> add-gadget ] smart-when* ]
        [ [ model value>> parent>> eq? model value>> result? and ]
          [ result>> contents>> set-children-font { 10 45 } <border> add-gadget ] smart-when* ] tri
    ] each drop ;

: toggle-result ( nav -- )
    model>> [ {
      { [ dup executable? ] [ dup run-word result>> ] }
      { [ dup result? ] [ parent>> ] }
      [  ]
    } cond ] change-model ;

navigation H{
    { T{ key-down f { C+ } "v" }    [ vocab new-item ] }
    { T{ key-down f { C+ } "V" }    [ vocab new-item ] }
    { T{ key-down f { C+ } "n" }    [ word new-item ] }
    { T{ key-down f { C+ } "N" }    [ word new-item ] }
    { T{ key-down f { S+ } "UP" }   [ model>> [ [ result? not ] find-parent left side-node ] change-model ] }
    { T{ key-down f { S+ } "DOWN" } [ model>> [ [ result? not ] find-parent right side-node ] change-model ] }
    { T{ key-down f { S+ } "RET" }  [ toggle-result ] }
} set-gestures
