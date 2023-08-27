! Copyright (C) 2007 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions ;
IN: math.quadratic

: monic ( c b a -- c' b' ) [ / ] curry bi@ ;

: discriminant ( c b -- b d ) [ nip ] [ sq 4 / swap - sqrt ] 2bi ;

: critical ( b d -- -b/2 d ) [ -2 / ] dip ;

: +- ( x y -- x+y x-y ) [ + ] [ - ] 2bi ;

: quadratic ( c b a -- alpha beta )
    monic discriminant critical +- ;

:: qeval ( x c b a -- y )
    c b x * + a x sq * + ;
