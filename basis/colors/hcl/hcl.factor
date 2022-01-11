! Copyright (C) 2022 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors colors colors.luv combinators kernel locals math
math.constants math.functions math.libm math.order ;

IN: colors.hcl

TUPLE: hcla
{ hue read-only }
{ chroma read-only }
{ luminance read-only }
{ alpha read-only } ;

C: <hcla> hcla

INSTANCE: hcla color

<PRIVATE

: deg2rad ( degree -- radian ) pi 180.0 / * ; inline

: rad2deg ( radian -- degree ) 180.0 pi / * ; inline

PRIVATE>

M: hcla >luva
    [let
        {
            [ hue>> ] [ chroma>> ] [ luminance>> ] [ alpha>> ]
        } cleave :> ( h c l a )

        l
        h deg2rad :> angle
        c angle cos *
        c angle sin *
        a
        <luva>
    ] ;

M: hcla >rgba >luva >rgba ;

GENERIC: >hcla ( color -- hcla )

M: object >hcla >luva >hcla ;

M: hcla >hcla ; inline

M: luva >hcla
    [let
        {
            [ l>> ] [ u>> ] [ v>> ] [ alpha>> ]
        } cleave :> ( l u v a )

        u sq v sq + sqrt :> c
        v u fatan2 rad2deg
        [ dup 360 > ] [ 360 - ] while
        [ dup 0 < ] [ 360 + ] while :> h

        h c l a <hcla>
    ] ;
