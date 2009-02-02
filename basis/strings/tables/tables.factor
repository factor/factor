! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences fry math.order ;
IN: strings.tables

<PRIVATE

: format-column ( seq ? -- seq )
    [
        dup [ length ] [ max ] map-reduce
        '[ _ CHAR: \s pad-tail ] map
    ] unless ;

: map-last ( seq quot -- seq )
    [ dup length <reversed> ] dip '[ 0 = @ ] 2map ; inline

PRIVATE>

: format-table ( table -- seq )
    flip [ format-column ] map-last
    flip [ " " join ] map ;