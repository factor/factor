! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors combinators kernel math math.order ;

IN: colors.hsl

TUPLE: hsla
{ hue read-only }
{ saturation read-only }
{ lightness read-only }
{ alpha read-only } ;

C: <hsla> hsla

INSTANCE: hsla color

<PRIVATE

: value ( p q t -- value )
    dup 0 < [ 1.0 + ] when
    dup 1 > [ 1.0 - ] when
    {
        { [ dup 1/6 < ] [ [ over - ] dip * 6 * + ] }
        { [ dup 1/2 < ] [ drop nip ] }
        { [ dup 2/3 < ] [ [ over - ] dip 2/3 swap - * 6 * + ] }
        [ 2drop ]
    } cond ;

PRIVATE>

M: hsla >rgba
    {
        [ hue>> ] [ saturation>> ] [ lightness>> ] [ alpha>> ]
    } cleave [| h s l |
        s zero? [
            l l l
        ] [
            l 0.5 < [ l s 1 + * ] [ l s + l s * - ] if :> q
            l 2 * q - :> p
            p q h 1/3 + value
            p q h value
            p q h 1/3 - value
        ] if
    ] dip <rgba> ; inline

GENERIC: >hsla ( color -- hsla )

M: object >hsla >rgba >hsla ;

M: hsla >hsla ; inline

M: rgba >hsla
    >rgba-components [| r g b |
        r g b min min :> min-c
        r g b max max :> max-c
        min-c max-c + 2 / :> l
        max-c min-c - :> d
        d zero? [ 0.0 0.0 ] [
            max-c {
                { r [ g b - d / g b < 6.0 0.0 ? + ] }
                { g [ b r - d / 2.0 + ] }
                { b [ r g - d / 4.0 + ] }
            } case 6.0 /
            l 0.5 > [
                d 2 max-c - min-c - /
            ] [
                d max-c min-c + /
            ] if
        ] if l
    ] dip <hsla> ;
