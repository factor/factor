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

! The painting protocol. Painting is controlled by various
! dynamically-scoped variables.

! Colors are lists of three integers, 0..255.
SYMBOL: foreground ! Used for text and outline shapes.
SYMBOL: background ! Used for filled shapes.
SYMBOL: reverse-video

: fg reverse-video get background foreground ? get ;
: bg reverse-video get foreground background ? get ;

SYMBOL: font  ! a list of two elements, a font name and size.

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

: shape-pos ( shape -- pos )
    dup shape-x swap shape-y rect> ;
