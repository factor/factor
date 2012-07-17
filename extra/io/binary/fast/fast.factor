! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators combinators.smart fry kernel macros math
math.ranges sequences sequences.generalizations io.binary
locals ;
IN: io.binary.fast

ERROR: bad-length bytes n ;

: check-length ( bytes n -- bytes n )
    2dup [ length ] dip > [ bad-length ] when ; inline

<<
: be-range ( n -- range )
    1 - 8 * 0 -8 <range> ; inline

: le-range ( n -- range )
    1 - 8 * 0 swap 8 <range> ; inline

: reassemble-bytes ( range -- quot )
    [ [ [ ] ] [ '[ _ shift ] ] if-zero ] map
    '[ [ _ spread ] [ bitor ] reduce-outputs ] ; inline

MACRO: reassemble-be ( n -- quot ) be-range reassemble-bytes ;

MACRO: reassemble-le ( n -- quot ) le-range reassemble-bytes ;
>>

:: n-be> ( bytes n -- x )
    bytes n check-length drop n firstn-unsafe n reassemble-be ; inline

:: n-le> ( bytes n -- x )
    bytes n check-length drop n firstn-unsafe n reassemble-le ; inline

: 2be> ( bytes -- x ) 2 n-be> ;
: 4be> ( bytes -- x ) 4 n-be> ;
: 8be> ( bytes -- x ) 8 n-be> ;

: 2le> ( bytes -- x ) 2 n-le> ;
: 4le> ( bytes -- x ) 4 n-le> ;
: 8le> ( bytes -- x ) 8 n-le> ;

