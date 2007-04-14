! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private math math.private sequences
sequences.private ;
IN: arrays

M: array clone (clone) ;
M: array length array-capacity ;
M: array nth-unsafe >r >fixnum r> array-nth ;
M: array set-nth-unsafe >r >fixnum r> set-array-nth ;
M: array resize resize-array ;

: >array ( seq -- array ) { } clone-like ;

M: object new drop f <array> ;

M: f new drop dup zero? [ drop f ] [ f <array> ] if ;

M: array like drop dup array? [ >array ] unless ;

M: array equal?
    over array? [ sequence= ] [ 2drop f ] if ;

INSTANCE: array sequence

: 1array ( x -- array ) 1 swap <array> ; flushable

: 2array ( x y -- array ) { } 2sequence ; flushable

: 3array ( x y z -- array ) { } 3sequence ; flushable

: 4array ( w x y z -- array ) { } 4sequence ; flushable

PREDICATE: pair < array length 2 number= ;
