! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel kernel.private math math.private
math.libm math.functions prettyprint.backend arrays
math.functions.private sequences parser ;
IN: math.complex.private

M: real real-part ;
M: real imaginary-part drop 0 ;

M: complex real-part real>> ;
M: complex imaginary-part imaginary>> ;

M: complex absq >rect [ sq ] bi@ + ;

: 2>rect ( x y -- xr yr xi yi )
    [ [ real-part ] bi@ ] 2keep
    [ imaginary-part ] bi@ ; inline

M: complex number=
    2>rect number= [ number= ] [ 2drop f ] if ;

: *re ( x y -- xr*yr xi*ri ) 2>rect * >r * r> ; inline
: *im ( x y -- xi*yr xr*yi ) 2>rect >r * swap r> * ; inline

M: complex + 2>rect + >r + r> (rect>) ;
M: complex - 2>rect - >r - r> (rect>) ;
M: complex * 2dup *re - -rot *im + (rect>) ;

: complex/ ( x y -- r i m )
    dup absq >r 2dup *re + -rot *im - r> ; inline

M: complex / complex/ tuck / >r / r> (rect>) ;

M: complex abs absq >float fsqrt ;

M: complex sqrt >polar swap fsqrt swap 2.0 / polar> ;

M: complex hashcode* nip >rect >fixnum swap >fixnum bitxor ;

IN: syntax

: C{ \ } [ first2 rect> ] parse-literal ; parsing

M: complex pprint-delims drop \ C{ \ } ;

M: complex >pprint-sequence >rect 2array ;
