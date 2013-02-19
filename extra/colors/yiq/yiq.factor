! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors colors combinators kernel math math.order ;

IN: colors.yiq

TUPLE: yiqa < color
{ y read-only }
{ in-phase read-only }
{ quadrature read-only }
{ alpha read-only } ;

C: <yiqa> yiqa

M: yiqa >rgba
    {
        [ y>> ] [ in-phase>> ] [ quadrature>> ] [ alpha>> ]
    } cleave [
        [ [ 0.948262 * ] [ 0.624013 * ] bi* + + ]
        [ [ 0.276066 * ] [ 0.639810 * ] bi* + - ]
        [ [ 1.105450 * ] [ 1.729860 * ] bi* - - ]
        3tri [ 0.0 1.0 clamp ] tri@
    ] dip <rgba> ; inline

: rgba>yiqa ( rgba -- yiqa )
    >rgba-components [
        [ [ 0.30 * ] [ 0.59 * ] [ 0.11 * ] tri* + + ]
        [ [ 0.60 * ] [ 0.28 * ] [ 0.32 * ] tri* + - ]
        [ [ 0.21 * ] [ 0.52 * ] [ 0.31 * ] tri* - - ]
        3tri
    ] dip <yiqa> ;
