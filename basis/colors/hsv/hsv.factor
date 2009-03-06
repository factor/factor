! Copyright (C) 2008 Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: colors kernel combinators math math.functions accessors ;
IN: colors.hsv

! h [0,360)
! s [0,1]
! v [0,1]
TUPLE: hsva < color { hue read-only } { saturation read-only } { value read-only } { alpha read-only } ;

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
