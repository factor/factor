! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel alien alien.data cpu.architecture libc ;
IN: math.vectors.simd.intrinsics

ERROR: bad-simd-call ;

: (simd-v+) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-v-) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-v*) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-v/) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-vmin) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-vmax) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-vsqrt) ( v1 v2 rep -- v3 ) bad-simd-call ;
: (simd-sum) ( v1 rep -- v2 ) bad-simd-call ;
: (simd-broadcast) ( x rep -- v ) bad-simd-call ;
: (simd-gather-2) ( a b rep -- v ) bad-simd-call ;
: (simd-gather-4) ( a b c d rep -- v ) bad-simd-call ;
: assert-positive ( x -- y ) ;

: alien-vector ( c-ptr n rep -- value )
    ! Inefficient version for when intrinsics are missing
    [ swap <displaced-alien> ] dip rep-size memory>byte-array ;

: set-alien-vector ( value c-ptr n rep -- )
    ! Inefficient version for when intrinsics are missing
    [ swap <displaced-alien> swap ] dip rep-size memcpy ;

