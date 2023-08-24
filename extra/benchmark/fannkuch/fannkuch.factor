! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.combinatorics math.order sequences
io prettyprint ;
IN: benchmark.fannkuch

: count ( quot: ( -- ? ) -- n )
    ! Call quot until it returns false, return number of times
    ! it was true
    [ 0 ] dip '[ _ dip swap [ [ 1 + ] when ] keep ] loop ; inline

: count-flips ( perm -- flip# )
    '[
        _ dup first dup 1 =
        [ 2drop f ] [ head-slice reverse! drop t ] if
    ] count ; inline

: write-permutation ( perm -- )
    [ CHAR: 0 + write1 ] each nl ; inline

: fannkuch-step ( counter max-flips perm -- counter max-flips )
    pick 30 < [ [ 1 + ] [ ] [ dup write-permutation ] tri* ] when
    count-flips max ; inline

: fannkuch ( n -- )
    [
        [ 0 0 ] dip <iota> [ 1 + ] B{ } map-as
        [ fannkuch-step ] each-permutation nip
    ] keep
    "Pfannkuchen(" write pprint ") = " write . ;

: fannkuch-benchmark ( -- )
    9 fannkuch ;

MAIN: fannkuch-benchmark
