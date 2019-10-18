USING: arrays errors kernel math sequences si-units test units ;

[ T{ dimensioned f 3 { m } { } } ] [ 3 m ] unit-test
[ T{ dimensioned f 3 { m } { s } } ] [ 3 m/s ] unit-test
[ T{ dimensioned f 4000 { m } { } } ] [ 4 km ] unit-test
[ t ] [ 4 km { m } { } convert 4000 m = ] unit-test

