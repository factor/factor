! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors combinators kernel math
math.order ;

IN: colors.yuv

TUPLE: yuva
{ y read-only }
{ u read-only }
{ v read-only }
{ alpha read-only } ;

C: <yuva> yuva

INSTANCE: yuva color

<PRIVATE

CONSTANT: Wr 0.299
CONSTANT: Wb 0.114
CONSTANT: Wg 0.587
CONSTANT: Umax 0.436
CONSTANT: Vmax 0.615

PRIVATE>

M: yuva >rgba
    { [ y>> ] [ u>> ] [ v>> ] [ alpha>> ] } cleave
    [| y u v |
        y 1 Wr - Vmax / v * +

        y
        Wb 1 Wb - * Umax Wg * / neg u *
        Wr 1 Wr - * Vmax Wg * / neg v * + +

        y 1 Wb - Umax / u * +

        [ 0.0 1.0 clamp ] tri@
    ] dip <rgba> ; inline

GENERIC: >yuva ( color -- yuva )

M: object >yuva >rgba >yuva ;

M: yuva >yuva ; inline

M:: rgba >yuva ( rgba -- yuva )
    rgba >rgba-components :> ( r g b a )
    Wr r * Wg g * Wb b * + + :> y
    Umax 1 Wb - / b y - * :> u
    Vmax 1 Wr - / r y - * :> v
    y u v a <yuva> ;
