! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: heaps math sequences kernel ;
IN: benchmark.heaps

: data ( -- seq )
    1 6000 [ 13 + 79 * 13591 mod dup ] replicate nip ;

: heap-test ( -- )
    <min-heap>
    data
    [ [ dup pick heap-push ] each ]
    [ length [ dup heap-pop* ] times ] bi
    drop ;

: heap-benchmark ( -- )
    100 [ heap-test ] times ;

MAIN: heap-benchmark