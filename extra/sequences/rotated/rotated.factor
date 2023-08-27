! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors kernel math sequences ;
IN: sequences.rotated

TUPLE: rotated
{ seq read-only }
{ n integer read-only } ;

C: <rotated> rotated

M: rotated length seq>> length ;

M: rotated virtual@
    [ n>> + ] [ seq>> ] bi [
        length over 0 < [ + ] [
            2dup >= [ - ] [ drop ] if
        ] if
    ] keep ;

M: rotated virtual-exemplar seq>> ;

INSTANCE: rotated virtual-sequence

: all-rotations ( seq -- seq' )
    dup length <iota> [ <rotated> ] with map ;
