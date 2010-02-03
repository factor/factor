! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences fry math.order splitting ;
IN: strings.tables

<PRIVATE

: map-last ( seq quot -- seq )
    [ dup length iota <reversed> ] dip '[ 0 = @ ] 2map ; inline

: max-length ( seq -- n )
    [ length ] [ max ] map-reduce ;

: format-row ( seq -- seq )
    dup max-length
    '[ _ "" pad-tail ] map ;

: format-column ( seq ? -- seq )
    [
        dup max-length
        '[ _ CHAR: \s pad-tail ] map
    ] unless ;

PRIVATE>

: format-table ( table -- seq )
    [ [ string-lines ] map format-row flip ] map concat
    flip [ format-column ] map-last flip [ " " join ] map ;