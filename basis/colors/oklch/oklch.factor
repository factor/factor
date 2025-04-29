! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors colors.oklab kernel math math.functions
math.libm ;

IN: colors.oklch

TUPLE: oklcha l c h alpha ;

C: <oklcha> oklcha

INSTANCE: oklcha color

M: oklcha >rgba >oklaba >rgba ;

M: oklcha >oklaba
    [
        [let
            [ l>> ] [ c>> ] [ h>> ] tri :> ( l c h )
            h deg>rad :> hr

            l
            c hr cos *
            c hr sin *
        ]
    ] [ alpha>> ] bi <oklaba> ;

GENERIC: >oklcha ( color -- oklcha )

M: object >oklcha >oklaba >oklcha ;

M: oklaba >oklcha
    [
        [let
            [ l>> ] [ a>> ] [ b>> ] tri :> ( l a b )

            l
            a sq b sq + sqrt
            b a fatan2 rad>deg
            [ dup 360 > ] [ 360 - ] while
            [ dup 0 < ] [ 360 + ] while
        ]
    ] [ alpha>> ] bi <oklcha> ;
