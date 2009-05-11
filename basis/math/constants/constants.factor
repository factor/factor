! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USE: math
IN: math.constants

: e ( -- e ) 2.7182818284590452354 ; inline
: euler ( -- gamma ) 0.57721566490153286060 ; inline
: phi ( -- phi ) 1.61803398874989484820 ; inline
: pi ( -- pi ) 3.14159265358979323846 ; inline
: 2pi ( -- pi ) 2 pi * ; inline
: epsilon ( -- epsilon ) 2.2204460492503131e-16 ; inline
: smallest-float ( -- x ) HEX: 1 bits>double ; foldable
: largest-float ( -- x ) HEX: 7fefffffffffffff bits>double ; foldable
