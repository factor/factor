IN: temporary
USING: kernel math tools.test ;

! Tests
[ { 0 1 } ] [ { 0 1 0 0 } ptrim ] unit-test
[ { 1 } ] [ { 1 0 0 } ptrim ] unit-test
[ { 0 } ] [ { 0 } ptrim ] unit-test
[ { 3 10 8 } ] [ { 1 2 } { 3 4 } p* ] unit-test
[ { 3 10 8 } ] [ { 3 4 } { 1 2 } p* ] unit-test
[ { 0 0 0 0 0 0 0 0 0 0 } ] [ { 0 0 0 } { 0 0 0 0 0 0 0 0 } p* ] unit-test
[ { 0 1 } ] [ { 0 1 } { 1 } p* ] unit-test
[ { 0 } ] [ { } { } p* ] unit-test
[ { 0 } ] [ { 0 } { } p* ] unit-test
[ { 0 } ] [ { } { 0 } p* ] unit-test
[ { 0 0 0 } ] [ { 0 0 0 } { 0 0 0 } p+ ] unit-test
[ { 0 0 0 } ] [ { 0 0 0 } { 0 0 0 } p- ] unit-test
[ { 0 0 0 } ] [ 4 { 0 0 0 } n*p ] unit-test
[ { 4 8 0 12 } ] [ 4 { 1 2 0 3 } n*p ] unit-test
[ { 1 4 7 6 0 0 0 0 0 } ] [ { 1 2 3 0 0 0 } { 1 2 0 0 } p* ] unit-test
[ V{ 7 -2 1 } V{ -20 0 0 } ] [ { 1 1 1 1 } { 3 1 } p/mod ] unit-test
[ V{ 0 0 } V{ 1 1 } ] [ { 1 1 } { 1 1 1 1 } p/mod ] unit-test
[ V{ 1 0 1 } V{ 0 0 0 } ] [ { 1 1 1 1 } { 1 1 } p/mod ] unit-test
[ V{ 1 0 1 } V{ 0 0 0 } ] [ { 1 1 1 1 } { 1 1 0 0 0 0 0 0 } p/mod ] unit-test
[ V{ 1 0 1 } V{ 0 0 0 } ] [ { 1 1 1 1 0 0 0 0 } { 1 1 0 0 } p/mod ] unit-test
[ V{ 5.0 } V{ 0.0 } ] [ { 10.0 } { 2.0 } p/mod ] unit-test
[ V{ 15/16 } V{ 0 } ] [ { 3/4 } { 4/5 } p/mod ] unit-test
[ t ] [ { 0 1 } { 0 1 0 } p= ] unit-test
[ f ] [ { 0 0 1 } { 0 1 0 } p= ] unit-test
[ t ] [ { 1 1 1 } { 1 1 1 } p= ] unit-test
[ { 0 0 } { 1 1 } ] [ { 1 1 1 1 } { 1 1 } pgcd ] unit-test

