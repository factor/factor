! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel kernel.private math math.private
math.libm math.functions arrays math.functions.private sequences
parser ;
IN: math.complex.private

M: real real-part ;
M: real imaginary-part drop 0 ;

M: complex real-part real>> ;
M: complex imaginary-part imaginary>> ;

M: complex absq >rect [ sq ] bi@ + ;

: 2>rect ( x y -- xr yr xi yi )
    [ [ real-part ] bi@ ]
    [ [ imaginary-part ] bi@ ] 2bi ; inline

M: complex hashcode*
    nip >rect [ hashcode ] bi@ bitxor ;

M: complex equal?
    over complex? [
        2>rect = [ = ] [ 2drop f ] if
    ] [ 2drop f ] if ;

M: complex number=
    2>rect number= [ number= ] [ 2drop f ] if ;

: *re ( x y -- xr*yr xi*ri ) 2>rect [ * ] 2bi@ ; inline
: *im ( x y -- xi*yr xr*yi ) 2>rect [ * swap ] dip * ; inline

M: complex + 2>rect [ + ] 2bi@ (rect>) ;
M: complex - 2>rect [ - ] 2bi@ (rect>) ;
M: complex * [ *re - ] [ *im + ] 2bi (rect>) ;

: complex/ ( x y -- r i m )
    [ [ *re + ] [ *im - ] 2bi ] keep absq ; inline

M: complex / complex/ tuck [ / ] 2bi@ (rect>) ;

M: complex abs absq >float fsqrt ;

M: complex sqrt >polar [ fsqrt ] [ 2.0 / ] bi* polar> ;

IN: syntax

: C{ \ } [ first2 rect> ] parse-literal ; parsing
