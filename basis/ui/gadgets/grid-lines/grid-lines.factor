! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors math namespaces opengl opengl.gl
sequences math.vectors ui.gadgets ui.gadgets.grids ui.render
math.geometry.rect fry ;
IN: ui.gadgets.grid-lines

TUPLE: grid-lines color ;

C: <grid-lines> grid-lines

SYMBOL: grid-dim

: half-gap ( -- gap ) grid get gap>> [ 2/ ] map ; inline

: grid-line-from/to ( orientation point -- from to )
    half-gap v- swap
    [ [ half-gap ] 2dip set-axis ]
    [ [ grid-dim get ] 2dip set-axis ] 2bi ;

: draw-grid-lines ( gaps orientation -- )
    [ grid get swap grid-positions grid get dim>> suffix ] dip
    [ '[ _ v- ] map ] keep
    '[ _ swap grid-line-from/to gl-line ] each ;

M: grid-lines draw-boundary
    color>> gl-color [
        [ grid set ]
        [ dim>> half-gap v- grid-dim set ]
        [ compute-grid ] tri
        [ horizontal draw-grid-lines ]
        [ vertical draw-grid-lines ]
        bi*
    ] with-scope ;
