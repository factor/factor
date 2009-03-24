USING: arrays kernel math sequences tools.test units.si
units.imperial units inverse math.functions ;
IN: units.tests

[ T{ dimensioned f 3 { m } { } } ] [ 3 m ] unit-test
[ T{ dimensioned f 3 { m } { s } } ] [ 3 m/s ] unit-test
[ T{ dimensioned f 4000 { m } { } } ] [ 4 km ] unit-test

[ t ] [ 4 m 5 m d+ 9 m = ] unit-test
[ t ] [ 5 m 1 m d- 4 m = ] unit-test
[ t ] [ 5 m 2 m d* 10 m^2 = ] unit-test
[ t ] [ 5 m 2 m d/ 5/2 { } { } <dimensioned> = ] unit-test
[ t ] [ 5 m 2 m tuck d/ drop 2 m = ] unit-test

[ t ] [ 1 m 2 m 3 m 3array d-product 6 m^3 = ] unit-test
[ t ] [ 3 m d-recip 1/3 { } { m } <dimensioned> = ] unit-test

: km/L ( n -- d ) km 1 L d/ ;
: mpg ( n -- d ) miles 1 gallons d/ ;

[ t ] [ 100 10 / km/L [ mpg ] undo 23 1 ~ ] unit-test
