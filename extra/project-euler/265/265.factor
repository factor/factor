! Copyright (c) 2010 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: generalizations kernel math math.functions project-euler.common
sequences sets ;
IN: project-euler.265

! https://projecteuler.net/problem=265

! 2^(N) binary digits can be placed in a circle so that all the
! N-digit clockwise subsequences are distinct.

! For N=3, two such circular arrangements are possible, ignoring
! rotations.

! For the first arrangement, the 3-digit subsequences, in
! clockwise order, are: 000, 001, 010, 101, 011, 111, 110 and
! 100.

! Each circular arrangement can be encoded as a number by
! concatenating the binary digits starting with the subsequence
! of all zeros as the most significant bits and proceeding
! clockwise. The two arrangements for N=3 are thus represented
! as 23 and 29:
! 00010111 _(2) = 23
! 00011101 _(2) = 29

! Calling S(N) the sum of the unique numeric representations, we
! can see that S(3) = 23 + 29 = 52.

! Find S(5).

CONSTANT: N 5

: decompose ( n -- seq )
    N <iota> [ drop [ 2/ ] [ 1 bitand ] bi ] map nip reverse ;

: bits ( seq -- n )
    0 [ [ 2 * ] [ + ] bi* ] reduce ;

: complete ( seq -- seq' )
    unclip decompose append [ 1 bitand ] map ;

: rotate-bits ( seq -- seq' )
    dup length <iota> [ cut prepend bits ] with map ;

: ?register ( acc seq -- )
    complete rotate-bits
    dup [ 2 N ^ mod ] map all-unique? [ infimum swap push ] [ 2drop ] if ;

: add-bit ( seen bit -- seen' t/f )
    over last 2 * + 2 N ^ mod
    2dup swap member? [ drop f ] [ suffix t ] if ;

: iterate ( acc left seen -- )
    over 0 = [
        nip ?register
    ] [
        [ 1 - ] dip
        { 0 1 } [ add-bit [ iterate ] [ 3drop ] if ] 3 nwith each
    ] if ;

: euler265 ( -- answer )
    V{ } clone [ 2 N ^ N - { 0 } iterate ] [ sum ] bi ;

! [ euler265 ] time
! Running time: 0.376389019 seconds

SOLUTION: euler265
