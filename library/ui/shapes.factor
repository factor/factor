! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces ;

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

GENERIC: move-shape ( x y shape -- )
GENERIC: resize-shape ( w h shape -- )

: with-translation ( shape quot -- )
    #! All drawing done inside the quotation is translated
    #! relative to the shape's origin.
    [
        >r dup
        shape-x x [ + ] change
        shape-y y [ + ] change
        r> call
    ] with-scope ; inline

: max-width ( list -- n )
    #! The width of the widest shape.
    [ shape-w ] map [ > ] top ;

: max-height ( list -- n )
    #! The height of the tallest shape.
    [ shape-h ] map [ > ] top ;

: run-widths ( list -- w list )
    #! Compute a list of running sums of widths of shapes.
    [ 0 swap [ over , shape-w + ] each ] make-list ;

: run-heights ( list -- h list )
    #! Compute a list of running sums of heights of shapes.
    [ 0 swap [ over , shape-h + ] each ] make-list ;

! A point is the simplest shape.
TUPLE: point x y ;

C: point ( x y -- point )
    [ set-point-y ] keep [ set-point-x ] keep ;

M: point inside? ( point point -- )
    over shape-x over point-x = >r
    swap shape-y swap point-y = r> and ;

M: point shape-x point-x ;
M: point shape-y point-y ;
M: point shape-w drop 0 ;
M: point shape-h drop 0 ;

M: point move-shape ( x y point -- )
    tuck set-point-y set-point-x ;

: translate ( point shape -- point )
    #! Translate a point relative to the shape.
    over shape-y over shape-y - >r
    swap shape-x swap shape-x - r> <point> ;

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

M: rectangle move-shape ( x y rect -- )
    tuck set-rectangle-y set-rectangle-x ;

M: rectangle resize-shape ( w h rect -- )
    tuck set-rectangle-h set-rectangle-w ;

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
