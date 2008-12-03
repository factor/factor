! Copyright (c) 2008 Reginald Keith Ford II.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.derivatives ;
IN: math.newtons-method

! Newton's method of approximating roots

<PRIVATE

: newton-step ( x function -- x2 )
    dupd [ call ] [ derivative ] 2bi / - ; inline

: newton-precision ( -- n ) 13 ; inline

PRIVATE>

: newtons-method ( guess function -- x )
    newton-precision [ [ newton-step ] keep ] times drop ;
