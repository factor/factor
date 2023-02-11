! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors kernel math sequences sequences.private ;
IN: sequences.shifted

TUPLE: shifted
{ underlying read-only }
{ n integer read-only }
{ fill read-only } ;

C: <shifted> shifted

M: shifted length underlying>> length ;

M: shifted like underlying>> like ;

M: shifted new-sequence underlying>> new-sequence ;

M: shifted nth-unsafe
    [ n>> neg + ] [ underlying>> ] [ ] tri
    2over bounds-check? [ drop nth-unsafe ] [ 2nip fill>> ] if ;

M: shifted set-nth-unsafe
    [ n>> neg + ] [ underlying>> ] bi
    2dup bounds-check? [ set-nth-unsafe ] [ 3drop ] if ;

INSTANCE: shifted sequence
