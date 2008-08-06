! Copyright © 2008 Reginald Keith Ford II
! Tool for computing the derivative of a function at a point 
USING: kernel math math.points math.function-tools ;
IN: math.derivatives

: small-amount ( -- n ) 1.0e-14 ;
: some-more ( x -- y ) small-amount + ;
: some-less ( x -- y ) small-amount - ;
: derivative ( x function -- m ) [ [ some-more ] dip eval ] [ [ some-less ] dip eval ] 2bi slope ;
: derivative-func ( function -- function ) [ derivative ] curry ;