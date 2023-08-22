! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: benchmark.memoize

MEMO: mem0 ( -- ) ;
MEMO: mem1 ( n -- n ) 1 + ;
MEMO: mem2 ( n n -- n ) + ;
MEMO: mem3 ( n n n -- n ) + + ;
MEMO: mem4 ( n n n n -- n ) + + + ;

: memoize-benchmark ( -- )
    1000 [
        1000 <iota> [
            mem0 [ mem1 ] keep [ mem2 ] 2keep [ mem3 ] 3keep mem4 drop
        ] each
    ] times ;

MAIN: memoize-benchmark
