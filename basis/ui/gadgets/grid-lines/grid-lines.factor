! Copyright (C) 2006, 2008 Slava Pestov.
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
    half-gap v-
    [ half-gap spin set-axis ] 2keep
    grid-dim get spin set-axis ;

: draw-grid-lines ( gaps orientation -- )
    [ grid get swap grid-positions grid get rect-dim suffix ] dip
    [ '[ _ v- ] map ] keep
    '[ _ swap grid-line-from/to gl-line ] each ;

M: grid-lines draw-boundary
    color>> gl-color [
        dup grid set
        dup rect-dim half-gap v- grid-dim set
        compute-grid
        [ { 1 0 } draw-grid-lines ]
        [ { 0 1 } draw-grid-lines ]
        bi*
    ] with-scope ;
