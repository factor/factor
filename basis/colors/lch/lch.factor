! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors colors.lab colors.luv colors.xyz kernel
math math.functions math.libm math.trig ;

IN: colors.lch

TUPLE: LCHuv l c h alpha ;

C: <LCHuv> LCHuv

INSTANCE: LCHuv color

M: LCHuv >rgba >luva >rgba ;

M: LCHuv >xyza >luva >xyza ;

M: LCHuv >luva
    [
        [let
            [ l>> ] [ c>> ] [ h>> ] tri :> ( l c h )
            h deg>rad :> hr

            l
            c hr cos *
            c hr sin *
        ]
    ] [ alpha>> ] bi <luva> ;

GENERIC: >LCHuv ( color -- LCHuv )

M: object >LCHuv >luva >LCHuv ;

M: LCHuv >LCHuv ; inline

M: luva >LCHuv
    [
        [let
            [ l>> ] [ u>> ] [ v>> ] tri :> ( l u v )
            v u fatan2 rad>deg
            [ dup 360 > ] [ 360 - ] while
            [ dup 0 < ] [ 360 + ] while :> h

            l
            u sq v sq + sqrt
            h
        ]
    ] [ alpha>> ] bi <LCHuv> ;

TUPLE: LCHab l c h alpha ;

C: <LCHab> LCHab

INSTANCE: LCHab color

M: LCHab >rgba >laba >rgba ;

M: LCHab >laba
    [
        [let
            [ l>> ] [ c>> ] [ h>> ] tri :> ( l c h )
            h deg>rad :> hr

            l
            c hr cos *
            c hr sin *
        ]
    ] [ alpha>> ] bi <laba> ;

GENERIC: >LCHab ( color -- LCHab )

M: object >LCHab >laba >LCHab ;

M: LCHab >LCHab ; inline

M: laba >LCHab
    [
        [let
            [ l>> ] [ a>> ] [ b>> ] tri :> ( l a b )
            b a fatan2 rad>deg
            [ dup 360 > ] [ 360 - ] while
            [ dup 0 < ] [ 360 + ] while :> h

            l
            a sq b sq + sqrt
            h
        ]
    ] [ alpha>> ] bi <LCHab> ;
