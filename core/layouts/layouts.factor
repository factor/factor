! Copyright (C) 2007, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs kernel kernel.private math math.order namespaces ;
IN: layouts

SYMBOL: data-alignment

SYMBOL: tag-mask

SYMBOL: tag-bits

SYMBOL: num-types

SYMBOL: type-numbers

SYMBOL: mega-cache-size

SYMBOL: header-bits

: type-number ( class -- n )
    type-numbers get at ;

: tag-fixnum ( n -- tagged )
    tag-bits get shift ;

: tag-header ( n -- tagged )
    header-bits get shift ;

: untag-fixnum ( n -- tagged )
    tag-bits get neg shift ;

: hashcode-shift ( -- n )
    tag-bits get header-bits get + ;

: leaf-stack-frame-size ( -- n ) 16 ;

! We do this in its own compilation unit so that they can be
! folded below
<<
: cell ( -- n ) OBJ-CELL-SIZE special-object ; foldable

: (fixnum-bits) ( m -- n ) tag-bits get - ; foldable

: (first-bignum) ( m -- n ) (fixnum-bits) 1 - 2^ ; foldable
>>

: cells ( m -- n ) cell * ; inline

: cell-bits ( -- n ) 8 cells ; inline

: 32-bit? ( -- ? ) cell-bits 32 = ; inline

: 64-bit? ( -- ? ) cell-bits 64 = ; inline

: bootstrap-cell ( -- n ) \ cell get cell or ; inline

: bootstrap-cells ( m -- n ) bootstrap-cell * ; inline

: bootstrap-cell-bits ( -- n ) 8 bootstrap-cells ; inline

: first-bignum ( -- n )
    cell-bits (first-bignum) ; inline

: fixnum-bits ( -- n )
    cell-bits (fixnum-bits) ; inline

: bootstrap-fixnum-bits ( -- n )
    bootstrap-cell-bits (fixnum-bits) ; inline

: most-positive-fixnum ( -- n )
    first-bignum 1 - >fixnum ; inline

: most-negative-fixnum ( -- n )
    first-bignum neg >fixnum ; inline

: (max-array-capacity) ( b -- n )
    2 - 2^ 1 - ; inline

: max-array-capacity ( -- n )
    fixnum-bits (max-array-capacity) ; inline

: bootstrap-first-bignum ( -- n )
    bootstrap-cell-bits (first-bignum) ;

: bootstrap-most-positive-fixnum ( -- n )
    bootstrap-first-bignum 1 - ;

: bootstrap-most-negative-fixnum ( -- n )
    bootstrap-first-bignum neg ;

: bootstrap-max-array-capacity ( -- n )
    bootstrap-fixnum-bits (max-array-capacity) ;

M: bignum >integer
    dup most-negative-fixnum most-positive-fixnum between?
    [ >fixnum ] when ;

M: real >integer
    dup most-negative-fixnum most-positive-fixnum between?
    [ >fixnum ] [ >bignum ] if ; inline

UNION: immediate fixnum POSTPONE: f ;
