! Copyright (C) 2005, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math sequences sequences.private ;
IN: arrays

BUILTIN: array { length array-capacity read-only initial: 0 } ;

PRIMITIVE: <array> ( n elt -- array )
PRIMITIVE: resize-array ( n array -- new-array )

M: array clone (clone) ; inline
M: array length length>> ; inline
M: array nth-unsafe [ integer>fixnum ] dip array-nth ; inline
M: array set-nth-unsafe [ integer>fixnum ] dip set-array-nth ; inline
M: array resize resize-array ; inline
M: array equal? over array? [ sequence= ] [ 2drop f ] if ;
M: array hashcode* [ sequence-hashcode ] recursive-hashcode ;
M: object new-sequence drop 0 <array> ; inline
M: f new-sequence drop [ f ] [ 0 <array> ] if-zero ; inline

INSTANCE: array sequence

: >array ( seq -- array ) { } clone-like ;
: 1array ( x -- array ) 1 swap <array> ; inline
: 2array ( x y -- array ) { } 2sequence ; inline
: 3array ( x y z -- array ) { } 3sequence ; inline
: 4array ( w x y z -- array ) { } 4sequence ; inline

PREDICATE: pair < array length>> 2 number= ;
