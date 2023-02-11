! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors colors kernel math math.order ;

IN: colors.ryb

TUPLE: ryba
    { red read-only }
    { yellow read-only }
    { blue read-only }
    { alpha read-only } ;

C: <ryba> ryba

INSTANCE: ryba color

<PRIVATE

: normalized ( a b c quot: ( a b c -- a' b' c' ) -- a' b' c' )
    [ 3dup min min ] dip over
    [ [ - ] curry tri@ ]
    [ call ]
    [ [ + ] curry tri@ ] tri* ; inline

:: ryb>rgb ( r! y! b! -- r g b )
    r y b max max :> my

    y b min :> g!
    y g - y!
    b g - b!

    b g [ 0 > ] both? [
        b 2 * b!
        g 2 * g!
    ] when

    r y + r!
    g y + g!

    r g b 3dup max max [
        my swap / [ * ] curry tri@
    ] unless-zero ;

:: rgb>ryb ( r! g! b! -- r y b )
    r g b max max :> mg

    r g min :> y!
    r y - r!
    g y - g!

    b g [ 0 > ] both? [
        b 2 /f b!
        g 2 /f g!
    ] when

    y g + y!
    b g + b!

    r y b 3dup max max [
        mg swap / [ * ] curry tri@
    ] unless-zero ;

PRIVATE>

M: ryba >rgba
    [
        [ red>> ] [ yellow>> ] [ blue>> ] tri
        [ ryb>rgb ] normalized
    ] [ alpha>> ] bi <rgba> ;

GENERIC: >ryba ( color -- ryba )

M: object >ryba >rgba >ryba ;

M: ryba >ryba ; inline

M: rgba >ryba
    >rgba-components [ [ rgb>ryb ] normalized ] [ <ryba> ] bi* ;
