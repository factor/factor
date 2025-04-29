! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors colors.xyz colors.xyz.private kernel
math math.functions ;

IN: colors.oklab

TUPLE: oklaba l a b alpha ;

C: <oklaba> oklaba

INSTANCE: oklaba color

M: oklaba >rgba
    [
        [let
            [ l>> ] [ a>> ] [ b>> ] tri :> ( l a b )

            l a 0.3963377774 * + b 0.2158037573 * + 3 ^ :> l_
            l a 0.1055613458 * - b 0.0638541728 * - 3 ^ :> m_
            l a 0.0894841775 * - b 1.2914855480 * - 3 ^ :> s_

            l_ 4.0767416621 * m_ 3.3077115913 * - s_ 0.2309699292 * +
            l_ -1.2684380046 * m_ 2.6097574011 * + s_ 0.3413193965 * -
            l_ -0.0041960863 * m_ 0.7034186147 * - s_ 1.7076147010 * +
            [ srgb-compand ] tri@
        ]
    ] [ alpha>> ] bi <rgba> ;

GENERIC: >oklaba ( color -- oklaba )

M: object >oklaba >rgba >oklaba ;

M: rgba >oklaba
    [
        [let
            [ red>> ] [ green>> ] [ blue>> ] tri
            [ invert-srgb-compand ] tri@ :> ( r g b )

            r 0.4122214708 * g 0.5363325363 * b 0.0514459929 * + + 1/3 ^ :> l_
            r 0.2119034982 * g 0.6806995451 * b 0.1073969566 * + + 1/3 ^ :> m_
            r 0.0883024619 * g 0.2817188376 * b 0.6299787005 * + + 1/3 ^ :> s_

            l_ 0.2104542553 * m_ 0.7936177850 * + s_ 0.0040720468 * -
            l_ 1.9779984951 * m_ 2.4285922050 * - s_ 0.4505937099 * +
            l_ 0.0259040371 * m_ 0.7827717662 * + s_ 0.8086757660 * -
        ]
    ] [ alpha>> ] bi <oklaba> ;
