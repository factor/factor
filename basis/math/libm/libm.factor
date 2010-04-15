! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax ;
IN: math.libm

LIBRARY: libm

FUNCTION-ALIAS: facos
    double acos ( double x ) ;

FUNCTION-ALIAS: fasin
    double asin ( double x ) ;

FUNCTION-ALIAS: fatan
    double atan ( double x ) ;

FUNCTION-ALIAS: fatan2
    double atan2 ( double x, double y ) ;

FUNCTION-ALIAS: fcos
    double cos ( double x ) ;

FUNCTION-ALIAS: fsin
    double sin ( double x ) ;

FUNCTION-ALIAS: ftan
    double tan ( double x ) ;

FUNCTION-ALIAS: fcosh
    double cosh ( double x ) ;

FUNCTION-ALIAS: fsinh
    double sinh ( double x ) ;

FUNCTION-ALIAS: ftanh
    double tanh ( double x ) ;

FUNCTION-ALIAS: fexp
    double exp ( double x ) ;

FUNCTION-ALIAS: flog
    double log ( double x ) ;

FUNCTION-ALIAS: flog10
    double log10 ( double x ) ;

FUNCTION-ALIAS: fpow
    double pow ( double x, double y ) ;

FUNCTION-ALIAS: fsqrt
    double sqrt ( double x ) ;
    
! Windows doesn't have these...
FUNCTION-ALIAS: flog1+
    double log1p ( double x ) ;

FUNCTION-ALIAS: facosh
    double acosh ( double x ) ;

FUNCTION-ALIAS: fasinh
    double asinh ( double x ) ;

FUNCTION-ALIAS: fatanh
    double atanh ( double x ) ;
