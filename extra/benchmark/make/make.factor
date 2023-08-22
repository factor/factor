! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: kernel make math sequences ;

IN: benchmark.make

: make-strings ( n -- seq )
    [ [ CHAR: a , ] times ] "" make ;

: make-arrays ( n -- seq )
    [ <iota> % ] { } make ;

: make-vectors ( n -- seq )
    [ <iota> % ] V{ } make ;

: make-benchmark ( -- )
    5,000 <iota> [
        [ make-strings ] [ make-arrays ] [ make-vectors ] tri
        3drop
    ] each ;

MAIN: make-benchmark
