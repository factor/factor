! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors colors.xyz kernel math ;

IN: colors.xyy

TUPLE: xyYa x y Y alpha ;

C: <xyYa> xyYa

INSTANCE: xyYa color

M: xyYa >rgba
    >xyza >rgba ;

M: xyYa >xyza
    [
        [let
            [ x>> ] [ y>> ] [ Y>> ] tri :> ( x y Y )
            x y / Y *
            Y
            1 x - y - y / Y *
        ]
    ] [ alpha>> ] bi <xyza> ;

GENERIC: >xyYa ( color -- xyYa )

M: object >xyYa >xyza >xyYa ;

M: xyYa >xyYa ; inline

M: xyza >xyYa
    [
        [let
            [ x>> ] [ y>> ] [ z>> ] tri :> ( x y z )
            x y z + +
            [ x swap / ]
            [ y swap / ] bi
            y
        ]
    ] [ alpha>> ] bi <xyYa> ;
