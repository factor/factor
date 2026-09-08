! Copyright (C) 2006, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax kernel locals system words ;
FROM: math => float mod zero? fp-special? ;
IN: math.libm

LIBRARY: libm

FUNCTION-ALIAS: facos
    double acos ( double x )

FUNCTION-ALIAS: fasin
    double asin ( double x )

FUNCTION-ALIAS: fatan
    double atan ( double x )

FUNCTION-ALIAS: fatan2
    double atan2 ( double x, double y )

FUNCTION-ALIAS: fcos
    double cos ( double x )

FUNCTION-ALIAS: fsin
    double sin ( double x )

FUNCTION-ALIAS: ftan
    double tan ( double x )

FUNCTION-ALIAS: fcosh
    double cosh ( double x )

FUNCTION-ALIAS: fsinh
    double sinh ( double x )

FUNCTION-ALIAS: ftanh
    double tanh ( double x )

FUNCTION-ALIAS: fexp
    double exp ( double x )

FUNCTION-ALIAS: fexp1-
    double expm1 ( double x )

FUNCTION-ALIAS: flog
    double log ( double x )

FUNCTION-ALIAS: flog10
    double log10 ( double x )

FUNCTION-ALIAS: (fpow)
    double pow ( double x, double y )

FUNCTION-ALIAS: fsqrt
    double sqrt ( double x )

FUNCTION-ALIAS: ffma
    double fma ( double x, double y, double z )

FUNCTION-ALIAS: ffmaf
    alien.c-types:float fmaf ( alien.c-types:float x, alien.c-types:float y, alien.c-types:float z )

<PRIVATE

:: report-pow-underflow ( x y result -- result )
    ! UCRT can return zero for a tiny nonzero power without raising underflow.
    ! Exclude exact zero results involving a zero base or infinite operands.
    result zero? x zero? not and x fp-special? not and y fp-special? not and [
        ! A foreign call retains the FP side effect even though its result is
        ! discarded. This raises underflow/inexact and honors enabled traps.
        1.0e-300 1.0e-300 0.0 ffma drop
    ] when
    result ;

PRIVATE>

:: fpow ( x y -- z )
    x y (fpow) :> result
    os windows? [ x y result report-pow-underflow ] [ result ] if ; inline

FUNCTION: double fmod ( double x, double y )

M: float mod fmod ; inline

! fsqrt has an intrinsic so we don't actually want to inline it
! unconditionally
<<
\ fsqrt f "inline" set-word-prop
>>

! Windows doesn't have these...
FUNCTION-ALIAS: flog1+
    double log1p ( double x )

FUNCTION-ALIAS: facosh
    double acosh ( double x )

FUNCTION-ALIAS: fasinh
    double asinh ( double x )

FUNCTION-ALIAS: fatanh
    double atanh ( double x )

FUNCTION-ALIAS: flgamma
    double lgamma ( double x )
