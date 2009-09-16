! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types ;
IN: math.libm

: facos ( x -- y )
    double "libm" "acos" { double } alien-invoke ;

: fasin ( x -- y )
    double "libm" "asin" { double } alien-invoke ;

: fatan ( x -- y )
    double "libm" "atan" { double } alien-invoke ;

: fatan2 ( x y -- z )
    double "libm" "atan2" { double double } alien-invoke ;

: fcos ( x -- y )
    double "libm" "cos" { double } alien-invoke ;

: fsin ( x -- y )
    double "libm" "sin" { double } alien-invoke ;

: ftan ( x -- y )
    double "libm" "tan" { double } alien-invoke ;

: fcosh ( x -- y )
    double "libm" "cosh" { double } alien-invoke ;

: fsinh ( x -- y )
    double "libm" "sinh" { double } alien-invoke ;

: ftanh ( x -- y )
    double "libm" "tanh" { double } alien-invoke ;

: fexp ( x -- y )
    double "libm" "exp" { double } alien-invoke ;

: flog ( x -- y )
    double "libm" "log" { double } alien-invoke ;

: flog10 ( x -- y )
    double "libm" "log10" { double } alien-invoke ;

: fpow ( x y -- z )
    double "libm" "pow" { double double } alien-invoke ;

: fsqrt ( x -- y )
    double "libm" "sqrt" { double } alien-invoke ;
    
! Windows doesn't have these...
: flog1+ ( x -- y )
    double "libm" "log1p" { double } alien-invoke ;

: facosh ( x -- y )
    double "libm" "acosh" { double } alien-invoke ;

: fasinh ( x -- y )
    double "libm" "asinh" { double } alien-invoke ;

: fatanh ( x -- y )
    double "libm" "atanh" { double } alien-invoke ;
