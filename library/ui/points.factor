! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl sequences
vectors ;

M: number inside? ( point point -- )
    >r shape-pos r> = ;

M: number shape-x real ;
M: number shape-y imaginary ;
M: number shape-w drop 0 ;
M: number shape-h drop 0 ;

: translate ( point shape -- point )
    #! Translate a point relative to the shape.
    swap shape-pos swap shape-pos - ;

M: vector inside? ( point point -- )
    >r shape-loc r> = ;

M: vector shape-x first ;
M: vector shape-y second ;
M: vector shape-w drop 0 ;
M: vector shape-h drop 0 ;
