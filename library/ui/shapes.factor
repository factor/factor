! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math matrices namespaces sdl
sequences vectors ;

SYMBOL: x
SYMBOL: y

: origin ( -- loc ) x get y get 0 3vector ;

GENERIC: inside? ( loc shape -- ? )
GENERIC: shape-loc ( shape -- loc )
GENERIC: set-shape-loc ( loc shape -- )
GENERIC: shape-dim ( shape -- dim )
GENERIC: set-shape-dim ( dim shape -- )

: shape-x shape-loc first ;
: shape-y shape-loc second ;
: shape-w shape-dim first ;
: shape-h shape-dim second ;

: with-trans ( shape quot -- )
    #! All drawing done inside the quotation is translated
    #! relative to the shape's origin.
    [
        >r dup
        shape-x x [ + ] change
        shape-y y [ + ] change
        r> call
    ] with-scope ; inline

: shape-pos ( shape -- pos )
    dup shape-x swap shape-y rect> ;

: shape-bounds ( shape -- loc dim )
    dup shape-loc swap shape-dim ;

: shape-extent ( shape -- loc dim )
    dup shape-loc dup rot shape-dim v+ ;

: translate ( shape shape -- point )
    #! Translate a point relative to the shape.
    swap shape-loc swap shape-loc v- ;

M: vector shape-loc ;
M: vector shape-dim drop { 0 0 0 } ;

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

: intersect ( shape shape -- rect )
    >r shape-extent r> shape-extent
    swapd vmin >r vmax dup r> swap v- { 0 0 0 } vmax
    <rectangle> ;
