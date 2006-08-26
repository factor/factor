! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
DEFER: alien-invoke

IN: math-internals

: facos ( x -- y )
    "double" "libm" "acos" { "double" } alien-invoke ;
    foldable

: fasin ( x -- y )
    "double" "libm" "asin" { "double" } alien-invoke ;
    foldable

: fatan ( x -- y )
    "double" "libm" "atan" { "double" } alien-invoke ;
    foldable

: fatan2 ( x y -- z )
    "double" "libm" "atan2" { "double" "double" } alien-invoke ;
    foldable

: fcos ( x -- y )
    "double" "libm" "cos" { "double" } alien-invoke ;
    foldable

: fexp ( x -- y )
    "double" "libm" "exp" { "double" } alien-invoke ;
    foldable

: fcosh ( x -- y )
    "double" "libm" "cosh" { "double" } alien-invoke ;
    foldable

: flog ( x -- y )
    "double" "libm" "log" { "double" } alien-invoke ;
    foldable

: fpow ( x y -- z )
    "double" "libm" "pow" { "double" "double" } alien-invoke ;
    foldable

: fsin ( x -- y )
    "double" "libm" "sin" { "double" } alien-invoke ;
    foldable

: fsinh ( x -- y )
    "double" "libm" "sinh" { "double" } alien-invoke ;
    foldable

: fsqrt ( x -- y )
    "double" "libm" "sqrt" { "double" } alien-invoke ;
    foldable
