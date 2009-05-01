! Copyright (C) 2006, 2009 Slava Pestov.
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
M: complex hashcode* nip >rect [ hashcode ] bi@ bitxor ;
: componentwise ( x y quot -- a b ) [ [ >rect ] bi@ ] dip bi-curry@ bi* ; inline
: complex= ( x y quot -- ? ) componentwise and ; inline
M: complex equal? over complex? [ [ = ] complex= ] [ 2drop f ] if ;
M: complex number= [ number= ] complex= ;
: complex-op ( x y quot -- z ) componentwise rect> ; inline
M: complex + [ + ] complex-op ;
M: complex - [ - ] complex-op ;
: *re ( x y -- xr*yr xi*yi ) [ >rect ] bi@ [ * ] bi-curry@ bi* ; inline
: *im ( x y -- xi*yr xr*yi ) swap [ >rect ] bi@ swap [ * ] bi-curry@ bi* ; inline
M: complex * [ *re - ] [ *im + ] 2bi rect> ;
: (complex/) ( x y -- r i m ) [ [ *re + ] [ *im - ] 2bi ] keep absq ; inline
: complex/ ( x y quot -- z ) [ (complex/) ] dip curry bi@ rect> ; inline
M: complex / [ / ] complex/ ;
M: complex /f [ /f ] complex/ ;
M: complex /i [ /i ] complex/ ;
M: complex abs absq >float fsqrt ;
M: complex sqrt >polar [ fsqrt ] [ 2.0 / ] bi* polar> ;

IN: syntax

SYNTAX: C{ \ } [ first2 rect> ] parse-literal ;

USE: prettyprint.custom

M: complex pprint* pprint-object ;
M: complex pprint-delims drop \ C{ \ } ;
M: complex >pprint-sequence >rect 2array ;