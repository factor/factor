! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math ranges sequences locals hints ;
IN: benchmark.nested-empty-loop-2

: times ( seq quot -- ) [ drop ] prepose each ; inline

:: nested-empty-loop ( n -- )
    n [1..b] [
        n [1..b] [
            n [1..b] [
                n [1..b] [
                    n [1..b] [
                        n [1..b] [
                            n [1..b] [
                                n [1..b] [
                                    n [1..b] [ ] times
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
