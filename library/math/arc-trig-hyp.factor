! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: kernel math math-internals ;

! Inverse trigonometric functions:
!    acos asec asin acosec atan acot

! Inverse hyperbolic functions:
!    acosh asech asinh acosech atanh acoth

: acosh dup sq 1- sqrt + log ; inline
: asech recip acosh ; inline
: asinh dup sq 1+ sqrt + log ; inline
: acosech recip asinh ; inline
: atanh dup 1+ swap 1- neg / log 2 / ; inline
: acoth recip atanh ; inline
: [-1,1]? ( x -- ? ) dup complex? [ drop f ] [ abs 1 <= ] if ; inline
: asin dup [-1,1]? [ fasin ] [ i * asinh -i * ] if ; inline
: acos dup [-1,1]? [ facos ] [ asin pi 2 / swap - ] if ; inline
: atan dup [-1,1]? [ fatan ] [ i * atanh i * ] if ; inline
: asec recip acos ; inline
: acosec recip asin ; inline
: acot recip atan ; inline
