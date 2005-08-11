! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: kernel math math-internals ;

! Inverse trigonometric functions:
!    acos asec asin acosec atan acot

! Inverse hyperbolic functions:
!    acosh asech asinh acosech atanh acoth

: acosh dup sq 1 - sqrt + log ; stateless
: asech recip acosh ; stateless
: asinh dup sq 1 + sqrt + log ; stateless
: acosech recip asinh ; stateless
: atanh dup 1 + swap 1 - neg / log 2 / ; stateless
: acoth recip atanh ; stateless
: <=1 ( x -- ? ) dup complex? [ drop f ] [ abs 1 <= ] ifte ; stateless
: asin dup <=1 [ fasin ] [ i * asinh -i * ] ifte ; stateless
: acos dup <=1 [ facos ] [ asin pi 2 / swap - ] ifte ; stateless
: atan dup <=1 [ fatan ] [ i * atanh i * ] ifte ; stateless
: asec recip acos ; stateless
: acosec recip asin ; stateless
: acot recip atan ; stateless
