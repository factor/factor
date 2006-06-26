! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-grids
USING: gadgets kernel math namespaces opengl sequences ;

! You can set a grid's gadget-boundary to this.
TUPLE: grid-lines color ;

SYMBOL: grid-dim

: half-gap gap 2 v/n ; inline

: grid-line-from/to ( orientation point -- from to )
    half-gap v-
    [ half-gap swap rot set-axis ] 2keep
    grid-dim get swap rot set-axis ;

: draw-grid-lines ( gaps orientation -- )
    #! Clean this up later.
    swap grid-positions grid get rect-dim { 1 0 } v- add
    [ grid-line-from/to gl-line ] each-with ;

M: grid-lines draw-boundary ( gadget paint -- )
    #! Clean this up later.
    GL_MODELVIEW [
        0.5 0.5 0 glTranslated
        grid-lines-color gl-color [
            grid get rect-dim half-gap v- grid-dim set
            { 0 1 } draw-grid-lines
            { 1 0 } draw-grid-lines
        ] with-grid
    ] do-matrix ;
