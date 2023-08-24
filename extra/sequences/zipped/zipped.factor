! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors arrays kernel sequences sequences.private ;
IN: sequences.zipped

TUPLE: zipped
{ keys sequence read-only }
{ values sequence read-only } ;

C: <zipped> zipped

M: zipped length
    [ keys>> ] [ values>> ] bi min-length ;

M: zipped nth-unsafe
    [ keys>> nth-unsafe ] [ values>> nth-unsafe ] 2bi 2array ;

INSTANCE: zipped immutable-sequence
