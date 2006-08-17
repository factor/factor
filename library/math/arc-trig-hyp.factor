! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: kernel math math-internals ;

: acosh ( x -- y ) dup sq 1- sqrt + log ; inline

: asech ( x -- y ) recip acosh ; inline

: asinh ( x -- y ) dup sq 1+ sqrt + log ; inline

: acosech ( x -- y ) recip asinh ; inline

: atanh ( x -- y ) dup 1+ swap 1- neg / log 2 / ; inline

: acoth ( x -- y ) recip atanh ; inline

: [-1,1]? ( x -- ? )
    dup complex? [ drop f ] [ abs 1 <= ] if ; inline

: asin ( x -- y )
    dup [-1,1]? [ fasin ] [ i * asinh -i * ] if ; inline

: acos ( x -- y )
    dup [-1,1]? [ facos ] [ asin pi 2 / swap - ] if ; inline

: atan ( x -- y )
    dup [-1,1]? [ fatan ] [ i * atanh i * ] if ; inline

: asec ( x -- y ) recip acos ; inline

: acosec ( x -- y ) recip asin ; inline

: acot ( x -- y ) recip atan ; inline
