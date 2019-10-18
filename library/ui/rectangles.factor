! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl ;

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

M: rectangle draw-shape drop ;

! A rectangle only whose outline is visible.
TUPLE: hollow-rect ;

C: hollow-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-delegate ] keep ;

: hollow-rect ( shape -- )
    #! Draw a hollow rect with the bounds of an arbitrary shape.
    rect>screen >r 1 - r> 1 - fg rgb rectangleColor ;

M: hollow-rect draw-shape ( rect -- )
    >r surface get r> hollow-rect ;

! A rectangle that is filled.
TUPLE: plain-rect ;

C: plain-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-delegate ] keep ;

: plain-rect ( shape -- )
    #! Draw a filled rect with the bounds of an arbitrary shape.
    rect>screen bg rgb boxColor ;

M: plain-rect draw-shape ( rect -- )
    >r surface get r> plain-rect ;

! A rectangle that is filled with the background color and also
! has an outline.
TUPLE: etched-rect ;

C: etched-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-delegate ] keep ;

M: etched-rect draw-shape ( rect -- )
    >r surface get r> 2dup plain-rect hollow-rect ;

! A rectangle that has a visible outline only if the rollover
! paint property is set.
SYMBOL: rollover?

TUPLE: roll-rect ;

C: roll-rect ( x y w h -- rect )
    [ >r <rectangle> r> set-delegate ] keep ;

M: roll-rect draw-shape ( rect -- )
    >r surface get r> 2dup
    plain-rect rollover? get [ hollow-rect ] [ 2drop ] ifte ;
