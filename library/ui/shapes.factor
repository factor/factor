! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel math namespaces ;

! Shape protocol.

! These dynamically-bound variables affect the generic word
! inside?.
SYMBOL: x ! x translation
SYMBOL: y ! y translation

! A shape is an object with a defined bounding
! box, and a notion of interior.
GENERIC: shape-x
GENERIC: shape-y
GENERIC: shape-w
GENERIC: shape-h

GENERIC: inside? ( point shape -- ? )

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
M: number shape-x real ;
M: number shape-y imaginary ;
M: number shape-w drop 0 ;
M: number shape-h drop 0 ;
M: number inside? = ;

! A rectangle maps trivially to the shape protocol.
TUPLE: rect x y w h ;
M: rect shape-x rect-x ;
M: rect shape-y rect-y ;
M: rect shape-w rect-w ;
M: rect shape-h rect-h ;

: fix-neg ( a b c -- a+c b -c )
    dup 0 < [ neg tuck >r >r + r> r> ] when ;

C: rect ( x y w h -- rect )
    #! We handle negative w/h for convinience.
    >r fix-neg >r fix-neg r> r>
    [ set-rect-h ] keep
    [ set-rect-w ] keep
    [ set-rect-y ] keep
    [ set-rect-x ] keep ;

: rect-x-extents ( rect -- x1 x2 )
    dup rect-x x get + swap rect-w dupd + ;

: rect-y-extents ( rect -- x1 x2 )
    dup rect-y y get + swap rect-h dupd + ;

M: rect inside? ( point rect -- ? )
    over real over rect-x-extents between? >r
    swap imaginary swap rect-y-extents between? r> and ;
