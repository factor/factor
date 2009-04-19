! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math math.ranges math.parser sequences kernel io locals ;
IN: benchmark.beust2

! http://crazybob.org/BeustSequence.java.html

:: (count-numbers) ( remaining first value used max listener: ( -- ) -- ? )
    10 first - [| i |
        [let* | digit [ i first + ]
                mask [ digit 2^ ]
                value' [ i value + ] |
            used mask bitand zero? [
                value max > [ t ] [
                    remaining 1 <= [
                        listener call f
                    ] [
                        remaining 1-
                        0
                        value' 10 *
                        used mask bitor
                        max
                        listener
                        (count-numbers)
                    ] if
                ] if
            ] [ f ] if
        ]
    ] any? ; inline recursive

:: count-numbers ( max listener -- )
    10 [ 1+ 1 1 0 max listener (count-numbers) ] any? drop ;
    inline

:: beust ( -- )
    [let | i! [ 0 ] |
        5000000000 [ i 1+ i! ] count-numbers
        i number>string " unique numbers." append print
    ] ;

MAIN: beust
