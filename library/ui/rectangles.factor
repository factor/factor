! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math matrices namespaces sdl styles
vectors ;

TUPLE: rectangle loc dim ;

M: rectangle shape-loc rectangle-loc ;
M: rectangle set-shape-loc set-rectangle-loc ;

M: rectangle shape-dim rectangle-dim ;
M: rectangle set-shape-dim set-rectangle-dim ;

: screen-bounds ( shape -- rect )
    shape-bounds >r origin v+ r> <rectangle> ;

M: rectangle inside? ( loc rect -- ? )
    screen-bounds shape-bounds { 1 1 1 } v- { 0 0 0 } vmax
    >r v- { 0 0 0 } r> vbetween? conj ;

M: rectangle draw-shape drop ;

: intersect ( shape shape -- rect )
    >r shape-extent r> shape-extent
    swapd vmin >r vmax dup r> swap v- { 0 0 0 } vmax
    <rectangle> ;

: rect>screen ( shape -- x1 y1 x2 y2 )
    [ shape-x x get + ] keep
    [ shape-y y get + ] keep
    [ shape-w pick + ] keep
    shape-h pick + ;

! A rectangle only whose outline is visible.
TUPLE: hollow-rect ;

C: hollow-rect ( loc dim -- rect )
    [ >r <rectangle> r> set-delegate ] keep ;

: hollow-rect ( shape -- )
    #! Draw a hollow rect with the bounds of an arbitrary shape.
    rect>screen >r 1 - r> 1 - fg rgb rectangleColor ;

M: hollow-rect draw-shape ( rect -- )
    >r surface get r> hollow-rect ;

! A rectangle that is filled.
TUPLE: plain-rect ;

C: plain-rect ( loc dim -- rect )
    [ >r <rectangle> r> set-delegate ] keep ;

: plain-rect ( shape -- )
    #! Draw a filled rect with the bounds of an arbitrary shape.
    rect>screen bg rgb boxColor ;

M: plain-rect draw-shape ( rect -- )
    >r surface get r> plain-rect ;

! A rectangle that is filled with the background color and also
! has an outline.
TUPLE: etched-rect ;

C: etched-rect ( loc dim -- rect )
    [ >r <rectangle> r> set-delegate ] keep ;

M: etched-rect draw-shape ( rect -- )
    >r surface get r> 2dup plain-rect hollow-rect ;
