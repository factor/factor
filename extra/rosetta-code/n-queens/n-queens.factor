! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: kernel sequences math math.combinatorics formatting io ;
IN: rosetta-code.n-queens

! https://rosettacode.org/wiki/N-queens_problem

! Solve the eight queens puzzle. You can extend the problem to
! solve the puzzle with a board of side NxN.

:: safe?  ( board q -- ? )
    [let q board nth :> x
        q <iota> [
            x swap
            [ board nth ] keep
            q swap -
            [ + = not ]
            [ - = not ] 3bi and
        ] all?
    ] ;

: solution? ( board -- ? )
    dup length <iota> [ dupd safe? ] all? nip ;

: queens ( n -- l )
    <iota> all-permutations [ solution? ] filter ;

: queens. ( n -- )
    queens [ [ 1 + "%d " printf ] each nl ] each ;
