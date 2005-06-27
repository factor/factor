! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl sequences
vectors ;

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

: set-shape-loc ( loc shape -- )
    >r 3unseq drop r> move-shape ;

GENERIC: resize-shape ( w h shape -- )

: set-shape-dim ( loc shape -- )
    >r 3unseq drop r> resize-shape ;

! The painting protocol. Painting is controlled by various
! dynamically-scoped variables. See library/styles.factor.

GENERIC: draw-shape ( obj -- )

! Utility words

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

: shape-size ( shape -- w h )
    dup shape-w swap shape-h ;

: shape-dim ( shape -- dim )
    dup shape-w swap shape-h 0 3vector ;

: shape-loc ( shape -- loc )
    dup shape-x swap shape-y 0 3vector ;
