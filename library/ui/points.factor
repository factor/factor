! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl ;

! A point, represented as a complex number, is the simplest
! shape. It is not mutable and cannot be used as the delegate of
! a gadget.
M: number inside? ( point point -- )
    >r shape-pos r> = ;

M: number shape-x real ;
M: number shape-y imaginary ;
M: number shape-w drop 0 ;
M: number shape-h drop 0 ;

: translate ( point shape -- point )
    #! Translate a point relative to the shape.
    swap shape-pos swap shape-pos - ;
