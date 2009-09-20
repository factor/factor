! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types cpu.architecture kernel
math.vectors.simd.functor vocabs.loader ;
FROM: sequences => each ;
IN: math.vectors.simd

<<

{ double float char uchar short ushort int uint }
[ [ define-simd-128 ] [ define-simd-256 ] bi ] each

>>

"math.vectors.simd.alien" require
