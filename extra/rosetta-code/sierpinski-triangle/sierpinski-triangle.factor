! Copyright (c) 2012 Anonymous
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel math sequences ;
IN: rosetta-code.sierpinski-triangle

! http://rosettacode.org/wiki/Sierpinski_triangle

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
    [ [ dup surround ] curry map ]
    [ drop [ dup " " glue ] map ] 2bi append ;

: (sierpinski) ( triangle spaces n -- triangle' )
    dup 0 = [ 2drop "\n" join ] [
        [
            [ iterate-triangle ]
            [ nip dup append ] 2bi
        ] dip 1 - (sierpinski)
    ] if ;

: sierpinski ( n -- )
    [ { "*" } " " ] dip (sierpinski) print ;
