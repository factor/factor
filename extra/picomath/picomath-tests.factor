! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: kernel literals math math.functions ranges picomath
sequences tools.test ;

IN: picomath

{ t } [
    {
        { -3  -0.999977909503 }
        { -1  -0.842700792950 }
        { 0.0 0.0 }
        { 0.5 0.520499877813 }
        { 2.1 0.997020533344 }
    } [ [ first erf ] [ second - ] bi abs ] map
    maximum 1e-6 <
] unit-test

{ t } [
    {
        { -1               -0.632120558828558 }
        { 0.0              0.0 }
        { $[ 1e-5 1e-8 - ] 0.000009990049900216168 }
        { $[ 1e-5 1e-8 + ] 0.00001001005010021717 }
        { 0.5              0.6487212707001282 }
    } [ [ first expm1 ] [ second - ] bi abs ] map
    maximum 1e-6 <
] unit-test

{ t } [
    {
        { -3  0.00134989803163 }
        { -1  0.158655253931 }
        { 0.0 0.5 }
        { 0.5 0.691462461274 }
        { 2.1 0.982135579437 }
    } [ [ first phi ] [ second - ] bi abs ] map
    maximum 1e-3 <
] unit-test

: factorial ( n -- n! ) [ 1 ] [ [1..b] 1 [ * ] reduce ] if-zero ;

{ t } [
    { 0 1 10 100 1000 10000 } [
        [ factorial log ] [ log-factorial ] bi - abs
    ] map maximum 1e-6 <
] unit-test

: relative-error ( approx value -- relative-error )
    [ - abs ] keep / ;

{ t } [
    {
        { 1e-20 1e+20 }
        { 2.19824158876e-16 4.5490905327e+15 }   ! 0.99*DBL_EPSILON
        { 2.24265050974e-16 4.45900953205e+15 }  ! 1.01*DBL_EPSILON
        { 0.00099 1009.52477271 }
        { 0.00100 999.423772485 }
        { 0.00101 989.522792258 }
        { 6.1 142.451944066 }
        { 11.999 39819417.4793 }
        { 12 39916800.0 }
        { 12.001 40014424.1571 }
        { 15.2 149037380723.0 }
    } [ [ first gamma ] [ second relative-error ] bi ] map
    maximum 1e-6 <
] unit-test

{ t } [
    {
        { 1e-12 27.6310211159 }
        { 0.9999 5.77297915613e-05 }
        { 1.0001 -5.77133422205e-05 }
        { 3.1 0.787375083274 }
        { 6.3 5.30734288962 }
        { 11.9999 17.5020635801 }
        { 12 17.5023078459 }
        { 12.0001 17.5025521125 }
        { 27.4 62.5755868211 }
    } [ [ first log-gamma ] [ second relative-error ] bi ] map
    maximum 1e-10 <
] unit-test
