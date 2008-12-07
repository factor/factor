! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien ;
IN: math.libm

: facos ( x -- y )
    "double" "libm" "acos" { "double" } alien-invoke ;
    inline

: fasin ( x -- y )
    "double" "libm" "asin" { "double" } alien-invoke ;
    inline

: fatan ( x -- y )
    "double" "libm" "atan" { "double" } alien-invoke ;
    inline

: fatan2 ( x y -- z )
    "double" "libm" "atan2" { "double" "double" } alien-invoke ;
    inline

: fcos ( x -- y )
    "double" "libm" "cos" { "double" } alien-invoke ;
    inline

: fsin ( x -- y )
    "double" "libm" "sin" { "double" } alien-invoke ;
    inline

: ftan ( x -- y )
    "double" "libm" "tan" { "double" } alien-invoke ;
    inline

: fcosh ( x -- y )
    "double" "libm" "cosh" { "double" } alien-invoke ;
    inline

: fsinh ( x -- y )
    "double" "libm" "sinh" { "double" } alien-invoke ;
    inline

: ftanh ( x -- y )
    "double" "libm" "tanh" { "double" } alien-invoke ;
    inline

: fexp ( x -- y )
    "double" "libm" "exp" { "double" } alien-invoke ;
    inline

: flog ( x -- y )
    "double" "libm" "log" { "double" } alien-invoke ;
    inline

: fpow ( x y -- z )
    "double" "libm" "pow" { "double" "double" } alien-invoke ;
    inline

: fsqrt ( x -- y )
    "double" "libm" "sqrt" { "double" } alien-invoke ;
    inline
    
! Windows doesn't have these...
: facosh ( x -- y )
    "double" "libm" "acosh" { "double" } alien-invoke ;
    inline

: fasinh ( x -- y )
    "double" "libm" "asinh" { "double" } alien-invoke ;
    inline

: fatanh ( x -- y )
    "double" "libm" "atanh" { "double" } alien-invoke ;
    inline
