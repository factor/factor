! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs backtrack kernel math memoize ranges sequences
words ;
IN: benchmark.backtrack

! This was suggested by Dr_Ford. Compute the number of quadruples
! (a,b,c,d) with 1 <= a,b,c,d <= 10 such that we can make 24 by
! placing them on the stack, and applying the operations
! +, -, * and rot as many times as we wish.

: nop ( -- ) ;

: do-something ( a b -- c )
    { + - * } amb-execute ;

: some-rots ( a b c -- a b c )
    ! Try to rot 0, 1 or 2 times.
    { nop rot -rot } amb-execute ;

MEMO: 24-from-1 ( a -- ? )
    24 = ;

MEMO: 24-from-2 ( a b -- ? )
    [ do-something 24-from-1 ] [ 2drop ] if-amb ;

MEMO: 24-from-3 ( a b c -- ? )
    [ some-rots do-something 24-from-2 ] [ 3drop ] if-amb ;

MEMO: 24-from-4 ( a b c d -- ? )
    [ some-rots do-something 24-from-3 ] [ 4drop ] if-amb ;

: find-impossible-24 ( -- n )
    10 [1..b] [| a |
        10 [1..b] [| b |
            10 [1..b] [| c |
                10 [1..b] [| d |
                    a b c d 24-from-4
                ] count
            ] map-sum
        ] map-sum
    ] map-sum ;

CONSTANT: 24-words { 24-from-1 24-from-2 24-from-3 24-from-4 }

: backtrack-benchmark ( -- )
    24-words [ reset-memoized ] each
    find-impossible-24 6479 assert=
    24-words [ "memoize" word-prop assoc-size ] map
    { 1588 5137 4995 10000 } assert= ;

MAIN: backtrack-benchmark
