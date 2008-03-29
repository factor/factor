! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel math namespaces sequences
io.backend io.binary combinators system vocabs.loader ;
IN: random.backend

SYMBOL: insecure-random-generator
SYMBOL: secure-random-generator
SYMBOL: random-generator

GENERIC: seed-random ( tuple seed -- )
GENERIC: random-32* ( tuple -- r )
GENERIC: random-bytes* ( n tuple -- bytes )

M: object random-bytes* ( n tuple -- byte-array )
    swap [ drop random-32* ] with map >c-uint-array ;

M: object random-32* ( tuple -- n ) 4 random-bytes* le> ;

ERROR: no-random-number-generator ;

M: f random-bytes* ( n obj -- * ) no-random-number-generator ;

M: f random-32* ( obj -- * ) no-random-number-generator ;
