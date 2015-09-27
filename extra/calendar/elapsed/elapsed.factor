! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: calendar combinators formatting kernel make math
math.parser sequences ;

IN: calendar.elapsed

GENERIC: elapsed-time ( seconds -- string )

M: real elapsed-time
    dup 0 < [ "negative seconds" throw ] when [
        {
            { 60 "s" }
            { 60 "m" }
            { 24 "h" }
            {  7 "d" }
            { 52 "w" }
            {  f "y" }
        } [
            [ first [ /mod ] [ dup ] if* ] [ second ] bi swap
            dup 0 > [ number>string prepend , ] [ 2drop ] if
        ] each drop
    ] { } make [ "0s" ] [ reverse " " join ] if-empty ;

M: duration elapsed-time
    duration>seconds elapsed-time ;

! XXX: Anything up to 2 hours is "about an hour"
: relative-time-offset ( seconds -- string )
    abs {
        { [ dup 1 < ] [ drop "just now" ] }
        { [ dup 60 < ] [ drop "less than a minute" ] }
        { [ dup 120 < ] [ drop "about a minute" ] }
        { [ dup 2700 < ] [ 60 / "%d minutes" sprintf ] }
        { [ dup 7200 < ] [ drop "about an hour" ] }
        { [ dup 86400 < ] [ 3600 /i "%d hours" sprintf ] }
        { [ dup 172800 < ] [ drop "1 day" ] }
        [ 86400 / "%d days" sprintf ]
    } cond ;

GENERIC: relative-time ( seconds -- string )

M: real relative-time
    [ relative-time-offset ] [
        dup abs 1 < [
            drop
        ] [
            0 < "hence" "ago" ? " " glue
        ] if
    ] bi ;

M: duration relative-time
    duration>seconds relative-time ;

M: timestamp relative-time
    now swap time- relative-time ;
