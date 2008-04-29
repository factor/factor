! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math words kernel assocs classes
math.order kernel.private ;
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

: tag-fixnum ( n -- tagged )
    tag-bits get shift ;

: cell ( -- n ) 7 getenv ; foldable

: cells ( m -- n ) cell * ; inline

: cell-bits ( -- n ) 8 cells ; inline

: bootstrap-cell \ cell get cell or ; inline

: bootstrap-cells bootstrap-cell * ; inline

: bootstrap-cell-bits 8 bootstrap-cells ; inline

: (first-bignum) ( m -- n )
    tag-bits get - 1 - 2^ ;

: first-bignum ( -- n )
    cell-bits (first-bignum) ;

: most-positive-fixnum ( -- n )
    first-bignum 1- ;

: most-negative-fixnum ( -- n )
    first-bignum neg ;

: bootstrap-first-bignum ( -- n )
    bootstrap-cell-bits (first-bignum) ;

: bootstrap-most-positive-fixnum ( -- n )
    bootstrap-first-bignum 1- ;

: bootstrap-most-negative-fixnum ( -- n )
    bootstrap-first-bignum neg ;

M: bignum >integer
    dup most-negative-fixnum most-positive-fixnum between?
    [ >fixnum ] when ;

M: real >integer
    dup most-negative-fixnum most-positive-fixnum between?
    [ >fixnum ] [ >bignum ] if ;
