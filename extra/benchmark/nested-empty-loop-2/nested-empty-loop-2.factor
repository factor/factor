! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.ranges sequences locals hints ;
IN: benchmark.nested-empty-loop-2

: times ( seq quot -- ) [ drop ] prepose each ; inline

:: nested-empty-loop ( n -- )
    1 n [a,b] [
        1 n [a,b] [
            1 n [a,b] [
                1 n [a,b] [
                    1 n [a,b] [
                        1 n [a,b] [
                            1 n [a,b] [
                                1 n [a,b] [
                                    1 n [a,b] [ ] times
                                ] times
                            ] times
                        ] times
                    ] times
                ] times
            ] times
        ] times
    ] times ;

HINTS: nested-empty-loop fixnum ;

: nested-empty-loop-2-benchmark ( -- ) 7 nested-empty-loop ;

MAIN: nested-empty-loop-2-benchmark
