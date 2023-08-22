! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays kernel namespaces sequences math memory ;
IN: benchmark.gc2

! Runs slowly if clean cards are not unmarked.
SYMBOL: oldies

: make-old-objects ( -- )
    1000000 [ 1 f <array> ] replicate oldies set gc
    oldies get [ "HI" swap set-first ] each ;

: allocate ( -- x ) 20000 (byte-array) ;

: age ( -- )
    1000 [ allocate drop ] times ;

: gc2-benchmark ( -- )
    [
        make-old-objects
        50000 [ age ] times
    ] with-scope ;

MAIN: gc2-benchmark
