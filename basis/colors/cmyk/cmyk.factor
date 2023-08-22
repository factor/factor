! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors combinators colors colors.gray kernel math
math.order ;

IN: colors.cmyk

TUPLE: cmyka
{ cyan read-only }
{ magenta read-only }
{ yellow read-only }
{ black read-only }
{ alpha read-only } ;

C: <cmyka> cmyka

INSTANCE: cmyka color

M: cmyka >rgba
    [ [ cyan>> ] [ black>> ] bi + ]
    [ [ magenta>> ] [ black>> ] bi + ]
    [ [ yellow>> ] [ black>> ] bi + ] tri
    [ 1.0 min 1.0 swap - ] tri@ 1.0 <rgba> ; inline

GENERIC: >cmyka ( color -- cmyka )

M: object >cmyka >rgba >cmyka ;

M: rgba >cmyka
    >rgba-components [
        [ 1 swap - ] tri@ 3dup min min
        [ [ - 0.0 1.0 clamp ] curry tri@ ] keep
    ] dip <cmyka> ;

M: cmyka >gray
    [
        {
            [ cyan>> 0.3 * ]
            [ magenta>> 0.59 * ]
            [ yellow>> 0.11 * ]
            [ black>> ]
        } cleave + + + 1.0 min 1.0 swap -
    ] [ alpha>> ] bi <gray> ;
