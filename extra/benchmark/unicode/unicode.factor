! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math random sequences splitting unicode ;
IN: benchmark.unicode

: crazy-unicode-string ( -- string )
    8 [ 8 0xffff randoms ] replicate join-words ;

: unicode-benchmark ( -- )
    crazy-unicode-string 8 [
        [ >title ] [ >lower ] [ >upper ] tri 3append
        ! [ >lower ] [ >upper ] bi append
    ] times drop ;

MAIN: unicode-benchmark
