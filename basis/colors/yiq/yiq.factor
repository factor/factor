! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors combinators kernel math
math.order ;

IN: colors.yiq

TUPLE: yiqa
{ y read-only }
{ in-phase read-only }
{ quadrature read-only }
{ alpha read-only } ;

C: <yiqa> yiqa

INSTANCE: yiqa color

M: yiqa >rgba
    {
        [ y>> ] [ in-phase>> ] [ quadrature>> ] [ alpha>> ]
    } cleave [
        [ [ 0.9468822170900693 * ] [ 0.6235565819861433 * ] bi* + + ]
        [ [ 0.27478764629897834 * ] [ 0.6356910791873801 * ] bi* + - ]
        [ [ 1.1085450346420322 * ] [ 1.7090069284064666 * ] bi* - - ]
        3tri [ 0.0 1.0 clamp ] tri@
    ] dip <rgba> ; inline

GENERIC: >yiqa ( color -- yiqa )

M: object >yiqa >rgba >yiqa ;

M: yiqa >yiqa ; inline

M:: rgba >yiqa ( rgba -- yiqa )
    rgba >rgba-components :> ( r g b a )
    0.30 r *  0.59 g * 0.11 b * + + :> y
    r y - :> r-y
    b y - :> b-y
    0.74 r-y * 0.27 b-y * - :> i
    0.48 r-y * 0.41 b-y * + :> q
    y i q a <yiqa> ;
