! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: kernel math math-internals ;

! Inverse trigonometric functions:
!    acos asec asin acosec atan acot

! Inverse hyperbolic functions:
!    acosh asech asinh acosech atanh acoth

: acosh dup sq 1 - sqrt + log ;
: asech recip acosh ;
: asinh dup sq 1 + sqrt + log ;
: acosech recip asinh ;
: atanh dup 1 + swap 1 - neg / log 2 / ;
: acoth recip atanh ;
: <=1 ( x -- ? ) dup complex? [ drop f ] [ abs 1 <= ] ifte ;
: asin dup <=1 [ fasin ] [ i * asinh -i * ] ifte ;
: acos dup <=1 [ facos ] [ asin pi/2 swap - ] ifte ;
: atan dup <=1 [ fatan ] [ i * atanh i * ] ifte ;
: asec recip acos ;
: acosec recip asin ;
: acot recip atan ;
