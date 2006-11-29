! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel-internals
USING: kernel namespaces math ;

: bootstrap-cell \ cell get ; inline
: cells ( m -- n ) cell * ; inline
: bootstrap-cells bootstrap-cell * ; inline

: cell-bits ( -- n ) 8 cells ; inline
: bootstrap-cell-bits 8 bootstrap-cells ; inline

: tag-address ( x tag -- tagged ) swap tag-bits shift bitor ;
: tag-header ( id -- tagged ) object-tag tag-address ;

IN: math

: i ( -- i ) C{ 0 1 } ; inline
: -i ( -- -i ) C{ 0 -1 } ; inline
: e ( -- e ) 2.7182818284590452354 ; inline
: pi ( -- pi ) 3.14159265358979323846 ; inline
: epsilon ( -- epsilon ) 2.2204460492503131e-16 ; inline

: first-bignum ( -- n )
    1 bootstrap-cell-bits tag-bits - 1- shift ;

: most-positive-fixnum ( -- n ) first-bignum 1- ;
: most-negative-fixnum ( -- n ) first-bignum neg ;
