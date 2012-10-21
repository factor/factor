! Copyright (C) 2008 Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors combinators kernel locals math
math.functions sequences sorting ;
IN: colors.hsv

! h [0,360)
! s [0,1]
! v [0,1]
TUPLE: hsva < color
{ hue read-only }
{ saturation read-only }
{ value read-only }
{ alpha read-only } ;

C: <hsva> hsva

<PRIVATE

: Hi ( hsv -- Hi ) hue>> 60 / floor 6 mod ; inline

: f ( hsv -- f ) [ hue>> 60 / ] [ Hi ] bi - ; inline

: p ( hsv -- p ) [ saturation>> 1 swap - ] [ value>> ] bi * ; inline

: q ( hsv -- q ) [ [ f ] [ saturation>> ] bi * 1 swap - ] [ value>> ] bi * ; inline

: t ( hsv -- t ) [ [ f 1 swap - ] [ saturation>> ] bi * 1 swap - ] [ value>> ] bi * ; inline

PRIVATE>

M: hsva >rgba ( hsva -- rgba )
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
    ] [ alpha>> ] bi <rgba> ;

:: rgba>hsva ( rgba -- hsva )
    rgba >rgba-components :> ( r g b a )
    r g b 3array natural-sort first3 :> ( z y x )
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
