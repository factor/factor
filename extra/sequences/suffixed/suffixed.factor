! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors kernel math math.order sequences sequences.private ;
IN: sequences.suffixed

TUPLE: suffixed
{ seq sequence read-only }
{ elt object read-only } ;

C: <suffixed> suffixed

M: suffixed length seq>> length 1 + ;

M: suffixed nth-unsafe
    [ seq>> 2dup bounds-check? ] 1check
    [ drop nth-unsafe ] [ 2nip elt>> ] if ;

INSTANCE: suffixed immutable-sequence

