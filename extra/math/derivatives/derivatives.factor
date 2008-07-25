! Copyright © 2008 Reginald Keith Ford II
! Tool for computing the derivative of a function at a point 
USING: kernel math math.points math.function-tools ;
IN: math.derivatives

: small-amount ( -- n ) 1.0e-12 ;
: near ( x -- y ) small-amount + ;
: derivative ( x function -- m ) 2dup [ near ] dip [ eval ] 2bi@ slope ;
: derivative-func ( function -- function ) [ derivative ] curry ;