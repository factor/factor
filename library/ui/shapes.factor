! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel math namespaces ;

! Shape protocol. Shapes are immutable; moving or resizing a
! shape makes a new shape.

! These dynamically-bound variables affect the generic word
! inside?.
SYMBOL: x
SYMBOL: y

GENERIC: inside? ( point shape -- ? )

! A shape is an object with a defined bounding
! box, and a notion of interior.
GENERIC: shape-x
GENERIC: shape-y
GENERIC: shape-w
GENERIC: shape-h

GENERIC: move-shape ( x y shape -- shape )
GENERIC: resize-shape ( w h shape -- shape )

: with-translation ( shape quot -- )
    #! All drawing done inside the quotation is translated
    #! relative to the shape's origin.
    [
        >r dup
        shape-x x [ + ] change
        shape-y y [ + ] change
        r> call
    ] with-scope ; inline

! A point, represented as a complex number, is the simplest type
! of shape.
M: number inside? = ;

M: number shape-x real ;
M: number shape-y imaginary ;
M: number shape-w drop 0 ;
M: number shape-h drop 0 ;

M: number move-shape ( x y point -- point ) drop rect> ;

! A rectangle maps trivially to the shape protocol.
TUPLE: rectangle x y w h ;
M: rectangle shape-x rectangle-x ;
M: rectangle shape-y rectangle-y ;
M: rectangle shape-w rectangle-w ;
M: rectangle shape-h rectangle-h ;

: fix-neg ( a b c -- a+c b -c )
    dup 0 < [ neg tuck >r >r + r> r> ] when ;

C: rectangle ( x y w h -- rect )
    #! We handle negative w/h for convinience.
    >r fix-neg >r fix-neg r> r>
    [ set-rectangle-h ] keep
    [ set-rectangle-w ] keep
    [ set-rectangle-y ] keep
    [ set-rectangle-x ] keep ;

M: number resize-shape ( w h point -- rect )
     >rect 2swap <rectangle> ;

M: rectangle move-shape ( x y rect -- rect )
    [ rectangle-w ] keep rectangle-h <rectangle> ;

M: rectangle resize-shape ( w h rect -- rect )
    [ rectangle-x ] keep rectangle-y 2swap <rectangle> ;

: rectangle-x-extents ( rect -- x1 x2 )
    dup rectangle-x x get + swap rectangle-w dupd + ;

: rectangle-y-extents ( rect -- x1 x2 )
    dup rectangle-y y get + swap rectangle-h dupd + ;

M: rectangle inside? ( point rect -- ? )
    over shape-x over rectangle-x-extents between? >r
    swap shape-y swap rectangle-y-extents between? r> and ;

! Delegates to a bounded shape, but absorbs all points.
WRAPPER: everywhere
M: everywhere inside? ( point world -- ? ) 2drop t ;

M: everywhere move-shape ( x y everywhere -- )
    everywhere-delegate move-shape <everywhere> ;

M: everywhere resize-shape ( w h everywhere -- )
    everywhere-delegate resize-shape <everywhere> ;
