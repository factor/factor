! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions ;
IN: math.quadratic

: monic ( c b a -- c' b' ) tuck / >r / r> ;

: discriminant ( c b -- b d ) tuck sq 4 / swap - sqrt ;

: critical ( b d -- -b/2 d ) >r -2 / r> ;

: +- ( x y -- x+y x-y ) [ + ] 2keep - ;

: quadratic ( c b a -- alpha beta )
    #! Solve a quadratic equation ax^2 + bx + c = 0
    monic discriminant critical +- ;

: qeval ( x c b a -- y )
    #! Evaluate ax^2 + bx + c
    >r pick * r> roll sq * + + ;
