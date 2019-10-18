! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: kernel math namespaces opengl sequences ;

TUPLE: grid-lines color ;

SYMBOL: grid-dim

: half-gap grid get grid-gap [ 2/ ] map ; inline

: grid-line-from/to ( orientation point -- from to )
    half-gap v-
    [ half-gap swap rot set-axis ] 2keep
    grid-dim get swap rot set-axis ;

: draw-grid-lines ( gaps orientation -- )
    grid get rot grid-positions grid get rect-dim add [
        grid-line-from/to gl-line
    ] each-with ;

M: grid-lines draw-boundary
    origin get [
        -0.5 -0.5 0.0 glTranslated
        grid-lines-color gl-color [
            dup grid set
            dup rect-dim half-gap v- grid-dim set
            compute-grid
            { 0 1 } draw-grid-lines
            { 1 0 } draw-grid-lines
        ] with-scope
    ] with-translation ;
