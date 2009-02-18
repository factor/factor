! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors math namespaces opengl opengl.gl
sequences math.vectors ui.pens ui.gadgets ui.gadgets.grids
ui.gadgets.grids.private ui.render math.rectangles
fry locals arrays assocs ;
IN: ui.gadgets.grid-lines

TUPLE: grid-lines color ;

C: <grid-lines> grid-lines

<PRIVATE

:: (compute-grid-lines) ( grid n ns orientation -- seq )
    grid gap>> :> gap
    ns n suffix gap orientation v. '[ _ - orientation n*v ] map
    dup grid dim>> gap v- orientation reverse [ v* ] keep '[ _ _ v+ v+ ] map
    [ [ gap [ 2/ ] map v+ ] map ] bi@ zip ;

: compute-grid-lines ( grid -- lines )
    dup <grid-layout>
    [ accumulate-cell-xs horizontal (compute-grid-lines) ]
    [ accumulate-cell-ys vertical (compute-grid-lines) ]
    2bi append ;

PRIVATE>

M: grid-lines draw-boundary
    color>> gl-color compute-grid-lines [ first2 gl-line ] each ;
