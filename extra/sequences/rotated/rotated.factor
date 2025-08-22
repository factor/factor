! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors kernel math sequences ;
IN: sequences.rotated

TUPLE: rotated < wrapped-sequence
{ n integer read-only } ;

C: <rotated> rotated

M: rotated virtual@
    [ n>> + ] [ seq>> ] bi [
        length over 0 < [ + ] [
            2dup >= [ - ] [ drop ] if
        ] if
    ] keep ;

: all-rotations ( seq -- seq' )
    dup length <iota> [ <rotated> ] with map ;
