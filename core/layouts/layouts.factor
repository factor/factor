! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math words kernel assocs system classes ;
IN: layouts

SYMBOL: tag-mask

SYMBOL: num-tags

SYMBOL: tag-bits

SYMBOL: num-types

SYMBOL: tag-numbers

SYMBOL: type-numbers

: tag-number ( class -- n )
    tag-numbers get at [ object tag-number ] unless* ;

: type-number ( class -- n )
    type-numbers get at ;

: tag-header ( n -- tagged )
    tag-bits get shift ;

: first-bignum ( -- n )
    bootstrap-cell-bits tag-bits get - 1 - 2^ ;

: most-positive-fixnum ( -- n )
    first-bignum 1- ;

: most-negative-fixnum ( -- n )
    first-bignum neg ;
