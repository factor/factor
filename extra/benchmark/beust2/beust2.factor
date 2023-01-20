! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: benchmark.beust2

! https://crazybob.org/BeustSequence.java.html

:: (count-numbers) ( remaining first value used max listener: ( -- ) -- ? )
    10 first - <iota> [| i |
        i first + :> digit
        digit 2^ :> mask
        i value + :> value'
        used mask bitand zero? [
            value max > [ t ] [
                remaining 1 <= [
                    listener call f
                ] [
                    remaining 1 -
                    0
                    value' 10 *
                    used mask bitor
                    max
                    listener
                    (count-numbers)
                ] if
            ] if
        ] [ f ] if
    ] any? ; inline recursive

:: count-numbers ( max listener -- )
    10 <iota> [ 1 + 1 1 0 max listener (count-numbers) ] any? drop ; inline

:: beust2-benchmark ( -- )
    0 :> i!
    5000000000 [ i 1 + i! ] count-numbers
    i 7063290 assert= ;

MAIN: beust2-benchmark
