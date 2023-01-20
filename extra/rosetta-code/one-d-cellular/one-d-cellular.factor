! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: bit-arrays io kernel math sequences ;
IN: rosetta-code.one-d-cellular

! https://rosettacode.org/wiki/One-dimensional_cellular_automata

! Assume an array of cells with an initial distribution of live
! and dead cells, and imaginary cells off the end of the array
! having fixed values.

! Cells in the next generation of the array are calculated based
! on the value of the cell and its left and right nearest
! neighbors in the current generation. If, in the following
! table, a live cell is represented by 1 and a dead cell by 0 then
! to generate the value of the cell at a particular index in the
! array of cellular values you use the following table:

! 000 -> 0  #
! 001 -> 0  #
! 010 -> 0  # Dies without enough neighbors
! 011 -> 1  # Needs one neighbor to survive
! 100 -> 0  #
! 101 -> 1  # Two neighbors giving birth
! 110 -> 1  # Needs one neighbor to survive
! 111 -> 0  # Starved to death.

: bool-sum ( bool1 bool2 -- sum )
    [ [ 2 ] [ 1 ] if ]
    [ [ 1 ] [ 0 ] if ] if ;

:: neighbors ( index world -- # )
    index [ 1 - ] [ 1 + ] bi [ world ?nth ] bi@ bool-sum ;

: count-neighbors ( world -- neighbors )
    [ length <iota> ] keep [ neighbors ] curry map ;

: life-law ( alive? neighbors -- alive? )
    swap [ 1 = ] [ 2 = ] if ;

: step ( world -- world' )
    dup count-neighbors [ life-law ] ?{ } 2map-as ;

: print-cellular ( world -- )
    [ CHAR: # CHAR: _ ? ] "" map-as print ;

: main-cellular ( -- )
    ?{ f t t t f t t f t f t f t f t f f t f f }
    10 [ dup print-cellular step ] times print-cellular ;

MAIN: main-cellular
