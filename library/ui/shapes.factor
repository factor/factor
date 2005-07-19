! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math matrices namespaces sdl
sequences vectors ;

SYMBOL: x
SYMBOL: y

: origin ( -- loc ) x get y get 0 3vector ;

TUPLE: rectangle loc dim ;

GENERIC: inside? ( loc shape -- ? )

: shape-x rectangle-loc first ;
: shape-y rectangle-loc second ;
: shape-w rectangle-dim first ;
: shape-h rectangle-dim second ;

: with-trans ( shape quot -- )
    #! All drawing done inside the quotation is translated
    #! relative to the shape's origin.
    [
        >r dup
        shape-x x [ + ] change
        shape-y y [ + ] change
        r> call
    ] with-scope ; inline

: shape-bounds ( shape -- loc dim )
    dup rectangle-loc swap rectangle-dim ;

: shape-extent ( shape -- loc dim )
    dup rectangle-loc dup rot rectangle-dim v+ ;

: screen-bounds ( shape -- rect )
    shape-bounds >r origin v+ r> <rectangle> ;

M: rectangle inside? ( loc rect -- ? )
    screen-bounds shape-bounds { 1 1 1 } v- { 0 0 0 } vmax
    >r v- { 0 0 0 } r> vbetween? conj ;

: intersect ( shape shape -- rect )
    >r shape-extent r> shape-extent
    swapd vmin >r vmax dup r> swap v- { 0 0 0 } vmax
    <rectangle> ;
