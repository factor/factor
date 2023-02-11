! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: io kernel math sequences splitting ;
IN: rosetta-code.sierpinski-triangle

! https://rosettacode.org/wiki/Sierpinski_triangle

! Produce an ASCII representation of a Sierpinski triangle of
! order N. For example, the Sierpinski triangle of order 4 should
! look like this:

!                       *
!                      * *
!                     *   *
!                    * * * *
!                   *       *
!                  * *     * *
!                 *   *   *   *
!                * * * * * * * *
!               *               *
!              * *             * *
!             *   *           *   *
!            * * * *         * * * *
!           *       *       *       *
!          * *     * *     * *     * *
!         *   *   *   *   *   *   *   *
!        * * * * * * * * * * * * * * * *

: iterate-triangle ( triange spaces -- triangle' )
    [ [ 1surround ] curry map ]
    [ drop [ dup " " glue ] map ] 2bi append ;

: (sierpinski) ( triangle spaces n -- triangle' )
    dup 0 = [ 2drop join-lines ] [
        [
            [ iterate-triangle ]
            [ nip dup append ] 2bi
        ] dip 1 - (sierpinski)
    ] if ;

: sierpinski ( n -- )
    [ { "*" } " " ] dip (sierpinski) print ;
