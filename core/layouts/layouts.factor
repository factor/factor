! Copyright (C) 2007, 2009 Slava Pestov.
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

SYMBOL: mega-cache-size

: type-number ( class -- n )
    type-numbers get at ;

: tag-number ( class -- n )
    type-number dup num-tags get >= [ drop object tag-number ] when ;

: tag-fixnum ( n -- tagged )
    tag-bits get shift ;

! We do this in its own compilation unit so that they can be
! folded below
<<
: cell ( -- n ) 7 getenv ; foldable

: (first-bignum) ( m -- n ) tag-bits get - 1 - 2^ ; foldable
>>

: cells ( m -- n ) cell * ; inline

: cell-bits ( -- n ) 8 cells ; inline

: bootstrap-cell ( -- n ) \ cell get cell or ; inline

: bootstrap-cells ( m -- n ) bootstrap-cell * ; inline

: bootstrap-cell-bits ( -- n ) 8 bootstrap-cells ; inline

: first-bignum ( -- n )
    cell-bits (first-bignum) ; inline

: most-positive-fixnum ( -- n )
    first-bignum 1- ; inline

: most-negative-fixnum ( -- n )
    first-bignum neg ; inline

: (max-array-capacity) ( b -- n )
    5 - 2^ 1- ; inline

: max-array-capacity ( -- n )
    cell-bits (max-array-capacity) ; inline

: bootstrap-first-bignum ( -- n )
    bootstrap-cell-bits (first-bignum) ;

: bootstrap-most-positive-fixnum ( -- n )
    bootstrap-first-bignum 1- ;

: bootstrap-most-negative-fixnum ( -- n )
    bootstrap-first-bignum neg ;

: bootstrap-max-array-capacity ( -- n )
    bootstrap-cell-bits (max-array-capacity) ;

M: bignum >integer
    dup most-negative-fixnum most-positive-fixnum between?
    [ >fixnum ] when ;

M: real >integer
    dup most-negative-fixnum most-positive-fixnum between?
    [ >fixnum ] [ >bignum ] if ;

UNION: immediate fixnum POSTPONE: f ;
