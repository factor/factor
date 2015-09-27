! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel locals math math.order math.ranges sequences
sequences.private ;

IN: sorting.bubble

<PRIVATE

:: (bubble-sort!) ( seq quot: ( obj1 obj2 -- <=> ) -- )
    seq length 1 - [
        f over [0,b) [| i |
            i i 1 + [ seq nth-unsafe ] bi@ 2dup quot call +gt+ =
            [ i 1 + i [ seq set-nth-unsafe ] bi-curry@ bi* 2drop i t ]
            [ 2drop ] if
        ] each
    ] loop drop ; inline

PRIVATE>

: bubble-sort! ( seq quot: ( obj1 obj2 -- <=> ) -- )
    over length 2 < [ 2drop ] [ (bubble-sort!) ] if ; inline

: natural-bubble-sort! ( seq -- )
    [ <=> ] bubble-sort! ;
