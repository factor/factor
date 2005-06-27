! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl styles ;

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

M: ellipse draw-shape drop ;

TUPLE: hollow-ellipse ;

C: hollow-ellipse ( x y w h -- ellipse )
    [ >r <ellipse> r> set-delegate ] keep ;

M: hollow-ellipse draw-shape ( ellipse -- )
    >r surface get r> ellipse>screen fg rgb
    ellipseColor ;

TUPLE: plain-ellipse ;

C: plain-ellipse ( x y w h -- ellipse )
    [ >r <ellipse> r> set-delegate ] keep ;

M: plain-ellipse draw-shape ( ellipse -- )
    >r surface get r> ellipse>screen bg rgb
    filledEllipseColor ;
