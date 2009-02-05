! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors math namespaces opengl opengl.gl
sequences math.vectors ui.gadgets ui.gadgets.grids
ui.gadgets.grids.private ui.render math.rectangles
fry locals arrays ;
IN: ui.gadgets.grid-lines

TUPLE: grid-lines color ;

C: <grid-lines> grid-lines

<PRIVATE

: grid-line-offsets ( n ns orientation gap -- seq )
    [ swap suffix ] [ v. 2/ ] 2bi* '[ _ + ] map ;

:: (compute-grid-lines) ( grid n ns orientation -- seq )
    n ns orientation grid gap>> grid-line-offsets [
        [ orientation n*v ]
        [ dup 2array grid dim>> swap orientation set-axis ]
        bi 2array
    ] map ;

: compute-grid-lines ( grid -- lines )
    dup <grid-layout>
    [ accumulate-cell-xs horizontal (compute-grid-lines) ]
    [ accumulate-cell-ys vertical (compute-grid-lines) ]
    2bi append ;

PRIVATE>

M: grid-lines draw-boundary
    color>> gl-color compute-grid-lines [ first2 gl-line ] each ;
