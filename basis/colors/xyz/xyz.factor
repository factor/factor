! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors kernel math math.functions
math.order ;

IN: colors.xyz

TUPLE: xyza x y z alpha ;

C: <xyza> xyza

INSTANCE: xyza color

<PRIVATE

CONSTANT: xyz_epsilon 216/24389
CONSTANT: xyz_kappa 24389/27

CONSTANT: wp_x 0.95047
CONSTANT: wp_y 1.00000
CONSTANT: wp_z 1.08883

: srgb-compand ( v -- v' )
    dup 0.0031308 <= [ 12.92 * ] [ 2.4 recip ^ 1.055 * 0.055 - ] if ;

PRIVATE>

M: xyza >rgba
    [
        [let
            [ x>> ] [ y>> ] [ z>> ] tri :> ( x y z )
            x 3.2404542 * y -1.5371385 * z -0.4985314 * + +
            x -0.9692660 * y 1.8760108 * z 0.0415560 * + +
            x 0.0556434 * y -0.2040259 * z 1.0572252 * + +
            [ srgb-compand 0.0 1.0 clamp ] tri@
        ]
    ] [ alpha>> ] bi <rgba> ;

GENERIC: >xyza ( color -- xyza )

M: object >xyza >rgba >xyza ;

M: xyza >xyza ; inline

<PRIVATE

: invert-rgb-compand ( v -- v' )
    dup 0.04045 <= [ 12.92 / ] [ 0.055 + 1.055 / 2.4 ^ ] if ;

PRIVATE>

M: rgba >xyza
    [
        [let
            [ red>> ] [ green>> ] [ blue>> ] tri
            [ invert-rgb-compand ] tri@ :> ( r g b )
            r 0.4124564 * g 0.3575761 * b 0.1804375 * + +
            r 0.2126729 * g 0.7151522 * b 0.0721750 * + +
            r 0.0193339 * g 0.1191920 * b 0.9503041 * + +
        ]
    ] [ alpha>> ] bi <xyza> ;
