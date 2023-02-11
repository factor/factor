! Copyright (C) 2022 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors colors.gray colors.hsl combinators
kernel math math.order ;

IN: colors.hwb

TUPLE: hwba
{ hue read-only }
{ whiteness read-only }
{ blackness read-only }
{ alpha read-only } ;

C: <hwba> hwba

INSTANCE: hwba color

M: hwba >rgba
    [let
        {
            [ hue>> ] [ whiteness>> ] [ blackness>> ] [ alpha>> ]
        } cleave :> ( h w b a )

        w b + :> w+b

        w+b 1 >= [
            w w+b / a <gray>
        ] [
            h 1.0 0.5 a <hsla> >rgba-components
            [ [ 1 w+b - * w + ] tri@ ] dip <rgba>
        ] if
    ] ; inline

GENERIC: >hwba ( color -- hsla )

M: object >hwba >rgba >hwba ;

M: hwba >hwba ; inline

M: rgba >hwba
    [let
        >hsla [ hue>> ] [ >rgba-components ] bi :> ( h r g b a )
        r g b min min :> w
        r g b max max 1 swap - :> b
        h w b a <hwba>
    ] ;
