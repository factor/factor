! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl ;

! Shape protocol. Shapes are immutable; moving or resizing a
! shape makes a new shape.

! These dynamically-bound variables affect the generic word
! inside? and others.
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

: with-trans ( shape quot -- )
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
    [ [ shape-w ] map [ > ] top ] [ 0 ] ifte* ;

: max-height ( list -- n )
    #! The height of the tallest shape.
    [ [ shape-h ] map [ > ] top ] [ 0 ] ifte* ;

: accumilate ( gap list -- n list )
    #! The nth element of the resulting list is the sum of the
    #! first n elements of the given list plus gap, n times.
    [ 0 swap [ over , + over + ] each ] make-list >r swap - r> ;

: run-widths ( gap list -- w list )
    #! Compute a list of running sums of widths of shapes.
    [ shape-w ] map accumilate ;

: run-heights ( gap list -- h list )
    #! Compute a list of running sums of heights of shapes.
    [ shape-h ] map accumilate ;

! A point, represented as a complex number, is the simplest
! shape. It is not mutable and cannot be used as the delegate of
! a gadget.
: shape-pos ( shape -- pos )
    dup shape-x swap shape-y rect> ;

M: number inside? ( point point -- )
    >r shape-pos r> = ;

M: number shape-x real ;
M: number shape-y imaginary ;
M: number shape-w drop 0 ;
M: number shape-h drop 0 ;

: translate ( point shape -- point )
    #! Translate a point relative to the shape.
    swap shape-pos swap shape-pos - ;

! A rectangle maps trivially to the shape protocol.
TUPLE: rectangle x y w h ;
M: rectangle shape-x rectangle-x ;
M: rectangle shape-y rectangle-y ;
M: rectangle shape-w rectangle-w ;
M: rectangle shape-h rectangle-h ;

: rect>screen ( shape -- x1 y1 x2 y2 )
    [ rectangle-x x get + ] keep
    [ rectangle-y y get + ] keep
    [ rectangle-w pick + ] keep
    rectangle-h pick + ;

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

: rectangle-x-extents ( rect x0 -- x1 x2 )
    >r dup shape-x r> + swap shape-w dupd + ;

: rectangle-y-extents ( rect y0 -- y1 y2 )
    >r dup shape-y r> + swap shape-h dupd + ;

: inside-rect? ( point rect -- ? )
    over shape-x over x get rectangle-x-extents 1 - between? >r
    swap shape-y swap y get rectangle-y-extents 1 - between? r>
    and ;

M: rectangle inside? ( point rect -- ? )
    inside-rect? ;

! A line.
TUPLE: line x y w h ;

M: line shape-x dup line-x dup rot line-w + min ;
M: line shape-y dup line-y dup rot line-h + min ;
M: line shape-w line-w abs 1 + ;
M: line shape-h line-h abs 1 + ;

: line-pos ( line -- #{ x y }# )
    dup line-x x get + swap line-y y get + rect> ;

: line-dir ( line -- #{ w h }# ) dup line-w swap line-h rect> ;

: move-line-x ( x line -- )
    [ line-w dupd - max ] keep set-line-x ;

: move-line-y ( y line -- )
    [ line-h dupd - max ] keep set-line-y ;

M: line move-shape ( x y line -- )
    tuck move-line-y move-line-x ;

: resize-line-w ( w line -- )
    dup line-w 0 >= [
        set-line-w
    ] [
        2dup
        [ [ line-w + ] keep line-x + ] keep set-line-x
        >r neg r> set-line-w
    ] ifte ;

: resize-line-h ( w line -- )
    dup line-h 0 >= [
        set-line-h
    ] [
        2dup
        [ [ line-h + ] keep line-y + ] keep set-line-y
        >r neg r> set-line-h
    ] ifte ;

M: line resize-shape ( w h line -- )
    tuck resize-line-h resize-line-w ;

: line>screen ( shape -- x1 y1 x2 y2 )
    [ line-x x get + ] keep
    [ line-y y get + ] keep
    [ line-w pick + ] keep
    line-h pick + ; 

: line-inside? ( p d -- ? )
    dupd proj - absq 4 < ;

M: line inside? ( point line -- ? )
    2dup inside-rect? [
        [ line-pos - ] keep line-dir line-inside?
    ] [
        2drop f
    ] ifte ;

! An ellipse.
TUPLE: ellipse x y w h ;
M: ellipse shape-x ellipse-x ;
M: ellipse shape-y ellipse-y ;
M: ellipse shape-w ellipse-w ;
M: ellipse shape-h ellipse-h ;

C: ellipse ( x y w h -- line )
    #! We handle negative w/h for convenience.
    >r fix-neg >r fix-neg r> r>
    [ set-ellipse-h ] keep
    [ set-ellipse-w ] keep
    [ set-ellipse-y ] keep
    [ set-ellipse-x ] keep ;

M: ellipse move-shape ( x y line -- )
    tuck set-ellipse-y set-ellipse-x ;

M: ellipse resize-shape ( w h line -- )
    tuck set-ellipse-h set-ellipse-w ;

: ellipse>screen ( shape -- x y rx ry )
    [ dup shape-x swap shape-w 2 /i + x get + ] keep
    [ dup shape-y swap shape-h 2 /i + y get + ] keep
    [ shape-w 2 /i ] keep
    shape-h 2 /i ;

M: ellipse inside? ( point ellipse -- ? )
    ellipse>screen swap sq swap sq
    2dup * >r >r >r
    pick shape-y - sq
    >r swap shape-x - sq r>
    r> * r> rot * + r> <= ;
