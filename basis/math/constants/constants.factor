! Copyright (C) 2004, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USE: math
IN: math.constants

: e ( -- e ) 2.7182818284590452354 ; inline
: euler ( -- gamma ) 0.57721566490153286060 ; inline
: phi ( -- phi ) 1.61803398874989484820 ; inline
: pi ( -- pi ) 3.14159265358979323846 ; inline
: 2pi ( -- 2pi ) 2 pi * ; inline
: epsilon ( -- epsilon ) 0x3cb0000000000000 bits>double ; foldable
: single-epsilon ( -- epsilon ) 0x34000000 bits>float ; foldable
: smallest-float ( -- x ) 0x1 bits>double ; foldable
: largest-float ( -- x ) 0x7fefffffffffffff bits>double ; foldable
