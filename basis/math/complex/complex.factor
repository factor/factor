! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel kernel.private math math.private
math.functions arrays math.functions.private sequences
sequences.private parser ;
IN: math.complex

<PRIVATE

M: real real-part ; inline
M: real imaginary-part drop 0 ; inline
M: complex real-part real>> ; inline
M: complex imaginary-part imaginary>> ; inline
M: complex absq >rect [ sq ] bi@ + ; inline
M: complex hashcode* nip >rect [ hashcode ] bi@ bitxor ; inline
: componentwise ( x y quot -- a b ) [ [ >rect ] bi@ ] dip bi-curry@ bi* ; inline
: complex= ( x y quot -- ? ) componentwise and ; inline
M: complex equal? over complex? [ [ = ] complex= ] [ 2drop f ] if ; inline
M: complex number= [ number= ] complex= ; inline
: complex-op ( x y quot -- z ) componentwise rect> ; inline
M: complex + [ + ] complex-op ; inline
M: complex - [ - ] complex-op ; inline
: *re ( x y -- xr*yr xi*yi ) [ >rect ] bi@ [ * ] bi-curry@ bi* ; inline
: *im ( x y -- xi*yr xr*yi ) swap [ >rect ] bi@ swap [ * ] bi-curry@ bi* ; inline
M: complex * [ *re - ] [ *im + ] 2bi rect> ; inline
: (complex/) ( x y -- r i m ) [ [ *re + ] [ *im - ] 2bi ] keep absq ; inline
: complex/ ( x y quot -- z ) [ (complex/) ] dip curry bi@ rect> ; inline
M: complex / [ / ] complex/ ; inline
M: complex /f [ /f ] complex/ ; inline
M: complex /i [ /i ] complex/ ; inline
M: complex abs absq sqrt ; inline
M: complex sqrt >polar [ sqrt ] [ 2.0 / ] bi* polar> ; inline

PRIVATE>

ERROR: malformed-complex obj ;

: parse-complex ( seq -- complex )
    dup length 2 = [ first2-unsafe rect> ] [ malformed-complex ] if ;

IN: syntax

SYNTAX: C{ \ } [ parse-complex ] parse-literal ;

USE: prettyprint.custom

M: complex pprint* pprint-object ;
M: complex pprint-delims drop \ C{ \ } ;
M: complex >pprint-sequence >rect 2array ;

