! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors colors.xyz colors.xyz.private kernel
math math.functions ;

IN: colors.lab

TUPLE: laba l a b alpha ;

C: <laba> laba

INSTANCE: laba color

M: laba >rgba >xyza >rgba ;

M: laba >xyza
    [
        [let
            [ l>> ] [ a>> ] [ b>> ] tri :> ( l a b )
            l 16 + 116 / :> fy
            a 500 / fy + :> fx
            fy b 200 / - :> fz

            fx 3 ^ :> fx3
            fz 3 ^ :> fz3

            fx3 xyz_epsilon > [
                fx3
            ] [
                116 fx * 16 - xyz_kappa /
            ] if :> x

            l xyz_kappa xyz_epsilon * > [
                l 16 + 116 / 3 ^
            ] [
                l xyz_kappa /
            ] if :> y

            fz3 xyz_epsilon > [
                fz3
            ] [
                116 fz * 16 - xyz_kappa /
            ] if :> z

            x wp_x * y wp_y * z wp_z *
        ]
    ] [ alpha>> ] bi <xyza> ;

GENERIC: >laba ( color -- laba )

M: object >laba >rgba >laba ;

M: rgba >laba >xyza >laba ;

M: xyza >laba
    [
        [let
            [ x>> wp_x / ] [ y>> wp_y / ] [ z>> wp_z / ] tri
            [
                dup xyz_epsilon >
                [ 1/3 ^ ] [ xyz_kappa * 16 + 116 / ] if
            ] tri@ :> ( fx fy fz )
            116 fy * 16 -
            500 fx fy - *
            200 fy fz - *
        ]
    ] [ alpha>> ] bi <laba> ;
