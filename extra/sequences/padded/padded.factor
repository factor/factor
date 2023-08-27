! Copyright (C) 2020 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors kernel math math.order sequences sequences.private ;
IN: sequences.padded

TUPLE: padded
{ underlying sequence read-only }
{ length integer read-only }
{ elt object read-only } ;

TUPLE: padded-head < padded ;
TUPLE: padded-tail < padded ;

C: <padded-head> padded-head
C: <padded-tail> padded-tail

M: padded length
    [ underlying>> length ] [ length>> ] bi max ;

M: padded-head nth-unsafe
    [ [ length>> ] [ underlying>> ] bi [ length [-] - ] keep ] keep
    2over bounds-check? [ drop nth-unsafe ] [ 2nip elt>> ] if ;

M: padded-tail nth-unsafe
    [ underlying>> ] keep 2over bounds-check?
    [ drop nth-unsafe ] [ 2nip elt>> ] if ;

INSTANCE: padded immutable-sequence

