! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors colors.gray kernel locals math
math.order sequences ui.gadgets ui.gadgets.buttons combinators.smart
skov.basis.ui.pens.gradient-rounded
skov.basis.ui.tools.environment.theme ;
IN: skov.basis.ui.gadgets.buttons.round

TUPLE: round-button < button ;

M: round-button pref-dim*
    gadget-child [ text>> length 1 > ]
    [ pref-dim first2 [ 15 + ] dip [ 20 max ] bi@ 2array ]
    [ { 20 20 } ] smart-if* ;

:: <round-button> ( colors label quot -- button )
    label quot round-button new-button
    colors dup first >gray gray>> 0.5 < light-text-colour dark-text-colour ?
    <gradient-squircle> >>interior
    dup gadget-child
    [ t >>bold? 13 >>size transparent >>background ] change-font drop ;
