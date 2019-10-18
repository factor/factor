! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math words generic kernel alien byte-arrays
assocs vectors strings sbufs arrays bit-arrays quotations ;
IN: kernel

SYMBOL: tag-mask
SYMBOL: num-tags
SYMBOL: tag-bits

SYMBOL: num-types

SYMBOL: tag-numbers

SYMBOL: type-numbers

: tag-number ( class -- n ) tag-numbers get at ;
: type-number ( class -- n ) type-numbers get at ;

: bootstrap-cell \ cell get ; inline
: cells ( m -- n ) cell * ; inline
: bootstrap-cells bootstrap-cell * ; inline

: cell-bits ( -- n ) 8 cells ; inline
: bootstrap-cell-bits 8 bootstrap-cells ; inline

: tag-address ( x tag -- tagged )
    swap tag-bits get shift bitor ;

: tag-header ( id -- tagged )
    object tag-number tag-address ;

: first-bignum ( -- n )
    bootstrap-cell-bits tag-bits get - 1 - 2^ ;

IN: math

: most-positive-fixnum ( -- n ) first-bignum 1- ;
: most-negative-fixnum ( -- n ) first-bignum neg ;

IN: sequences-internals

: max-array-capacity ( -- n )
    bootstrap-cell-bits tag-bits get - 2 - 2^ 1- ;
