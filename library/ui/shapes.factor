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

GENERIC: draw-shape ( shape -- )

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
