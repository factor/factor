! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: generic kernel kernel-internals math math-internals ;

DEFER: ratio?
BUILTIN: ratio 4 ratio? { 0 "numerator" f } { 1 "denominator" f } ;
UNION: rational integer ratio ;

M: integer numerator ;
M: integer denominator drop 1 ;

: >fraction ( a/b -- a b )
    dup numerator swap denominator ; inline

IN: math-internals

: 2>fraction ( a/b c/d -- a c b d )
    >r >fraction r> >fraction swapd ; inline

M: ratio number= ( a/b c/d -- ? )
    2>fraction number= [ number= ] [ 2drop f ] ifte ;

: scale ( a/b c/d -- a*d b*c )
    2>fraction >r * swap r> * swap ; inline

: ratio+d ( a/b c/d -- b*d )
    denominator swap denominator * ; inline

M: ratio < scale < ;
M: ratio <= scale <= ;
M: ratio > scale > ;
M: ratio >= scale >= ;

M: ratio + ( x y -- x+y ) 2dup scale + -rot ratio+d / ;
M: ratio - ( x y -- x-y ) 2dup scale - -rot ratio+d / ;
M: ratio * ( x y -- x*y ) 2>fraction * >r * r> / ;
M: ratio / scale / ;
M: ratio /i scale /i ;
M: ratio /f scale /f ;

M: ratio truncate >fraction /i ;
M: ratio floor [ truncate ] keep 0 < [ 1 - ] when ;
M: ratio ceiling [ truncate ] keep 0 > [ 1 + ] when ;
