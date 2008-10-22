! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: math.floating-point

: float-sign ( float -- ? )
    float>bits -31 shift { 1 -1 } nth ; 

: double-sign ( float -- ? )
    double>bits -63 shift { 1 -1 } nth ;

: float-exponent-bits ( float -- n )
    float>bits -23 shift 8 2^ 1- bitand ;

: double-exponent-bits ( double -- n )
    double>bits -52 shift 11 2^ 1- bitand ;

: float-mantissa-bits ( float -- n )
    float>bits 23 2^ 1- bitand ;

: double-mantissa-bits ( double -- n )
    double>bits 52 2^ 1- bitand ;

: float-e ( -- float ) 127 ; inline
: double-e ( -- float ) 1023 ; inline

! : calculate-float ( S M E -- float )
    ! float-e - 2^ * * ; ! bits>float ;

! : calculate-double ( S M E -- frac )
    ! double-e - 2^ swap 52 2^ /f 1+ * * ;

