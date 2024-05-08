! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors kernel math math.order sequences sequences.private ;
IN: sequences.prefixed

TUPLE: prefixed
{ elt object read-only }
{ seq sequence read-only } ;

C: <prefixed> prefixed

M: prefixed length seq>> length 1 + ;

M: prefixed nth-unsafe
    over zero? [ nip elt>> ] [ [ 1 - ] [ seq>> ] bi* nth-unsafe ] if ;

INSTANCE: prefixed immutable-sequence

