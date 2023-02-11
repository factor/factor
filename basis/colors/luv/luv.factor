! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors colors.xyz colors.xyz.private kernel
math math.functions ;

IN: colors.luv

TUPLE: luva l u v alpha ;

C: <luva> luva

INSTANCE: luva color

<PRIVATE

:: xyz-to-uv ( x y z -- u v )
    x y 15 * z 3 * + + :> d
    4 x * d /
    9 y * d / ; foldable

PRIVATE>

M: luva >rgba >xyza >rgba ;

M: luva >xyza
    [
        [let
            wp_x wp_y wp_z xyz-to-uv :> ( u_wp v_wp )
            [ l>> ] [ u>> ] [ v>> ] tri :> ( l u v )

            52 l * 13 l * u_wp * u + / 1 - 3 / :> a
            l xyz_kappa xyz_epsilon * > [
                l 16 + 116 / 3 ^ wp_y *
            ] [
                l xyz_kappa / wp_y *
            ] if :> y
            y -5 * :> b
            39 l * 13 l * v_wp * v + / 5 - y * :> d
            d b - a 1/3 + / :> x
            a x * b + :> z

            x y z
        ]
    ] [ alpha>> ] bi <xyza> ;

GENERIC: >luva ( color -- luva )

M: object >luva >rgba >luva ;

M: rgba >luva >xyza >luva ;

M: luva >luva ; inline

M: xyza >luva
    [
        [let
            wp_x wp_y wp_z xyz-to-uv :> ( u_wp v_wp )
            [ x>> ] [ y>> ] [ z>> ] tri :> ( x_ y_ z_ )
            x_ y_ z_ xyz-to-uv :> ( u_ v_ )

            y_ wp_y / :> y

            y xyz_epsilon > [
                y 1/3 ^ 116 * 16 -
            ] [
                xyz_kappa y *
            ] if :> l
            13 l * u_ u_wp - * :> u
            13 l * v_ v_wp - * :> v

            l u v
        ]
    ] [ alpha>> ] bi <luva> ;
