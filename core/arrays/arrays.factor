! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel kernel.private math math.private
sequences sequences.private ;
IN: arrays

M: array clone (clone) ;
M: array length length>> ;
M: array nth-unsafe [ >fixnum ] dip array-nth ;
M: array set-nth-unsafe [ >fixnum ] dip set-array-nth ;
M: array resize resize-array ;

: >array ( seq -- array ) { } clone-like ;

M: object new-sequence drop 0 <array> ;

M: f new-sequence drop dup zero? [ drop f ] [ 0 <array> ] if ;

M: array equal?
    over array? [ sequence= ] [ 2drop f ] if ;

INSTANCE: array sequence

: 1array ( x -- array ) 1 swap <array> ; inline

: 2array ( x y -- array ) { } 2sequence ; inline

: 3array ( x y z -- array ) { } 3sequence ; inline

: 4array ( w x y z -- array ) { } 4sequence ; inline

PREDICATE: pair < array length 2 number= ;
