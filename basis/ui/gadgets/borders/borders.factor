! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ui.gadgets kernel math
namespaces vectors sequences math.vectors math.geometry.rect ;
IN: ui.gadgets.borders

TUPLE: border < gadget
{ size initial: { 0 0 } }
{ fill initial: { 0 0 } }
{ align initial: { 1/2 1/2 } } ;

: new-border ( child class -- border )
    new-gadget swap add-gadget ; inline

: <border> ( child gap -- border )
    swap border new-border
        swap >>size ;

: <filled-border> ( child gap -- border )
    <border> { 1 1 } >>fill ;

M: border pref-dim*
    [ size>> 2 v*n ] [ gadget-child pref-dim ] bi v+ ;

M: border baseline
    [ size>> second ] [ gadget-child baseline ] bi + ;

: border-major-dim ( border -- dim )
    [ dim>> ] [ size>> 2 v*n ] bi v- ;

: border-minor-dim ( border -- dim )
    gadget-child pref-dim ;

: scale ( a b s -- c )
    [ v* ] [ { 1 1 } swap v- v* ] bi-curry bi* v+ ;

: border-dim ( border -- dim )
    [ border-major-dim ] [ border-minor-dim ] [ fill>> ] tri scale ;

: border-loc ( border dim -- loc )
    [ [ size>> ] [ align>> ] [ border-major-dim ] tri ] dip
    v- v* v+ [ >fixnum ] map ;

: border-child-rect ( border -- rect )
    dup border-dim [ border-loc ] keep <rect> ;

M: border layout*
    [ gadget-child ] [ border-child-rect ] bi
    [ loc>> >>loc ] [ dim>> >>dim ] bi
    drop ;

M: border focusable-child*
    gadget-child ;
