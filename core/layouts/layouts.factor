! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math words kernel assocs classes
math.order kernel.private sequences sequences.private ;
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

! We do this in its own compilation unit so that they can be
! folded below
<<
: cell ( -- n ) OBJ-CELL-SIZE special-object ; foldable

: (fixnum-bits) ( m -- n ) tag-bits get - ; foldable

: (first-bignum) ( m -- n ) (fixnum-bits) 1 - 2^ ; foldable
>>

: cells ( m -- n ) cell * ; inline

: cell-bits ( -- n ) 8 cells ; inline

: bootstrap-cell ( -- n ) \ cell get cell or ; inline

: bootstrap-cells ( m -- n ) bootstrap-cell * ; inline

: bootstrap-cell-bits ( -- n ) 8 bootstrap-cells ; inline

: first-bignum ( -- n )
    cell-bits (first-bignum) ; inline

: fixnum-bits ( -- n )
    cell-bits (fixnum-bits) ; inline

: most-positive-fixnum ( -- n )
    first-bignum 1 - >fixnum ; inline

: most-negative-fixnum ( -- n )
    first-bignum neg >fixnum ; inline

: (max-array-capacity) ( b -- n )
    6 - 2^ 1 - ; inline

: max-array-capacity ( -- n )
    cell-bits (max-array-capacity) ; inline

: bootstrap-first-bignum ( -- n )
    bootstrap-cell-bits (first-bignum) ;

: bootstrap-most-positive-fixnum ( -- n )
    bootstrap-first-bignum 1 - ;

: bootstrap-most-negative-fixnum ( -- n )
    bootstrap-first-bignum neg ;

: bootstrap-max-array-capacity ( -- n )
    bootstrap-cell-bits (max-array-capacity) ;

M: bignum >integer
    dup most-negative-fixnum most-positive-fixnum between?
    [ >fixnum ] when ;

M: real >integer
    dup most-negative-fixnum most-positive-fixnum between?
    [ >fixnum ] [ >bignum ] if ; inline

! we put this here so that it can use the references to
! most-positive-fixnum otherwise would be in combinatrs
M: iota hashcode*
    over 0 <= [ 2drop 0 ] [
        nip length [
            0 most-positive-fixnum clamp integer>fixnum
            0 swap [ sequence-hashcode-step ] each-integer
        ] [
            most-positive-fixnum swap
            [ sequence-hashcode-step ] (each-integer)
        ] bi
    ] if ;

UNION: immediate fixnum POSTPONE: f ;
