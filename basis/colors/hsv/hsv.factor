! Copyright (C) 2008 Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors combinators kernel math math.functions
random sequences sorting ;
IN: colors.hsv

! h [0,360)
! s [0,1]
! v [0,1]
TUPLE: hsva
{ hue read-only }
{ saturation read-only }
{ value read-only }
{ alpha read-only } ;

C: <hsva> hsva

INSTANCE: hsva color

<PRIVATE

: Hi ( hsv -- Hi ) hue>> 60 / floor 6 mod >integer ; inline

: f ( hsv -- f ) [ hue>> 60 / ] [ Hi ] bi - ; inline

: p ( hsv -- p ) [ saturation>> 1 swap - ] [ value>> ] bi * ; inline

: q ( hsv -- q ) [ [ f ] [ saturation>> ] bi * 1 swap - ] [ value>> ] bi * ; inline

: t ( hsv -- t ) [ [ f 1 swap - ] [ saturation>> ] bi * 1 swap - ] [ value>> ] bi * ; inline

PRIVATE>

M: hsva >rgba
    [
        dup Hi
        {
            { 0 [ [ value>> ] [ t ] [ p ] tri ] }
            { 1 [ [ q ] [ value>> ] [ p ] tri ] }
            { 2 [ [ p ] [ value>> ] [ t ] tri ] }
            { 3 [ [ p ] [ q ] [ value>> ] tri ] }
            { 4 [ [ t ] [ p ] [ value>> ] tri ] }
            { 5 [ [ value>> ] [ p ] [ q ] tri ] }
        } case
    ] [ alpha>> ] bi <rgba> ; inline

<PRIVATE

: sort-triple ( a b c -- d e f )
    sort-pair [ sort-pair ] dip sort-pair ;

PRIVATE>

GENERIC: >hsva ( color -- hsva )

M: object >hsva >rgba >hsva ;

M: hsva >hsva ; inline

M:: rgba >hsva ( rgba -- hsva )
    rgba >rgba-components :> ( r g b a )
    r g b sort-triple :> ( z y x )
    x z = x zero? or [ 0 0 x a <hsva> ] [
        {
            { [ r x = g z = and ] [ 5 x b - x z - / + ] }
            { [ r x = g z > and ] [ 1 x g - x z - / - ] }
            { [ g x = b z = and ] [ 1 x r - x z - / + ] }
            { [ g x = b z > and ] [ 3 x b - x z - / - ] }
            { [ b x = r z = and ] [ 3 x g - x z - / + ] }
            { [ b x = r z > and ] [ 5 x r - x z - / - ] }
        } cond 6 / 360 * x z - x / x a <hsva>
    ] if ;

: complimentary-color ( color -- color' )
    >hsva {
        [ hue>> 180 + 360 mod ]
        [ saturation>> ]
        [ value>> ]
        [ alpha>> ]
    } cleave <hsva> ;

: golden-rainbow ( num-colors saturation luminance -- colors )
    [ random-unit ] 3dip '[
        0.618033988749895 + 1.0 mod dup _ _ 1.0 <hsva>
    ] replicate nip ;
