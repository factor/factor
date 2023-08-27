! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math math.vectors opengl
sequences ui.gadgets ui.gadgets.grids.private ui.pens ;
IN: ui.gadgets.grid-lines

TUPLE: grid-lines color ;

C: <grid-lines> grid-lines

<PRIVATE

:: (compute-grid-lines) ( grid n ns orientation -- seq )
    grid gap>> :> gap
    ns n suffix gap orientation vdot '[ _ - orientation n*v ] map
    dup grid dim>> gap v- orientation reverse v* '[ _ v+ ] map
    gap [ 2 /f ] map '[ [ _ v+ ] map ] bi@ zip ;

: compute-grid-lines ( grid -- lines )
    dup <grid-layout>
    [ accumulate-cell-xs horizontal (compute-grid-lines) ]
    [ accumulate-cell-ys vertical (compute-grid-lines) ]
    2bi append ;

PRIVATE>

M: grid-lines draw-boundary
    color>> gl-color compute-grid-lines [ first2 gl-line ] each ;
