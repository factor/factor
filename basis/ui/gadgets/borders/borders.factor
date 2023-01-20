! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel math math.rectangles math.vectors
opengl sequences ui.baseline-alignment ui.gadgets ;
IN: ui.gadgets.borders

TUPLE: border < aligned-gadget
    { size initial: { 0 0 } }
    { fill initial: { 0 0 } }
    { align initial: { 1/2 1/2 } }
    { min-dim initial: { 0 0 } } ;

: new-border ( child class -- border )
    new swap add-gadget ; inline

: <border> ( child gap -- border )
    [ border new-border ] dip >>size ;

: <filled-border> ( child gap -- border )
    <border> { 1 1 } >>fill ;

: border-pref-dim ( border child-dim -- pref-dim )
    '[ size>> 2 v*n _ v+ ] [ min-dim>> ] bi vmax [ gl-round ] map ;

M: border pref-dim*
    dup gadget-child pref-dim border-pref-dim ;

<PRIVATE

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

: border-metric ( border quot -- n )
    [ drop size>> second ] [ [ gadget-child ] dip call ] 2bi
    dup [ + ] [ nip ] if ; inline

PRIVATE>

M: border baseline* [ baseline ] border-metric ;

M: border cap-height* [ cap-height ] border-metric ;

M: border layout*
    [ border-child-rect ] [ gadget-child ] bi set-rect-bounds ;

M: border focusable-child*
    gadget-child ;
