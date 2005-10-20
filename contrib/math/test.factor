IN: temporary
USING: kernel math test sequences ;

! Tests
[ { 0 1 } ] [ { 0 1 0 0 } ptrim ] unit-test
[ { 1 } ] [ { 1 0 0 } ptrim ] unit-test
[ { 0 } ] [ { 0 } ptrim ] unit-test
[ { 3 10 8 } ] [ { 1 2 } { 3 4 } p* ] unit-test
[ { 3 10 8 } ] [ { 3 4 } { 1 2 } p* ] unit-test
[ { 0 0 0 0 0 0 0 0 0 0 } ] [ { 0 0 0 } { 0 0 0 0 0 0 0 0 } p* ] unit-test
[ { 0 1 } ] [ { 0 1 } { 1 } p* ] unit-test
[ { 0 0 0 } ] [ { 0 0 0 } { 0 0 0 } p+ ] unit-test
[ { 0 0 0 } ] [ { 0 0 0 } { 0 0 0 } p- ] unit-test
[ { 0 0 0 } ] [ 4 { 0 0 0 } n*p ] unit-test
[ { 4 8 0 12 } ] [ 4 { 1 2 0 3 } n*p ] unit-test
[ { 1 4 7 6 0 0 0 0 0 } ] [ { 1 2 3 0 0 0 } { 1 2 0 0 } conv ] unit-test
[ { 1 4 7 6 0 0 0 0 0 } ] [ { 1 2 3 0 0 0 } { 1 2 0 0 } p* ] unit-test
[ { 7 -2 1 } { -20 0 0 } ] [ { 1 1 1 1 } { 3 1 } p/mod ] unit-test
[ { 0 0 } { 1 1 } ] [ { 1 1 } { 1 1 1 1 } p/mod ] unit-test
[ { 1 0 1 } { 0 0 0 } ] [ { 1 1 1 1 } { 1 1 } p/mod ] unit-test
[ { 1 0 1 } { 0 0 0 } ] [ { 1 1 1 1 } { 1 1 0 0 0 0 0 0 } p/mod ] unit-test
[ { 1 0 1 } { 0 0 0 } ] [ { 1 1 1 1 0 0 0 0 } { 1 1 0 0 } p/mod ] unit-test
! [ { 5.0 } { 0.0 } ] [ { 10.0 } { 2.0 } p/mod ] unit-test
! [ { 15/16 } { 0 } ] [ { 3/4 } { 4/5 } p/mod ] unit-test
[ t ] [ { 0 1 } { 0 1 0 } p= ] unit-test
[ f ] [ { 0 0 1 } { 0 1 0 } p= ] unit-test
[ t ] [ { 1 1 1 } { 1 1 1 } p= ] unit-test
[ { 0 0 } { 1 1 } ] [ { 1 1 1 1 } { 1 1 } pgcd ] unit-test

[ t ] [ 10 3 nPk 10 factorial 7 factorial / = ] unit-test
[ t ] [ 10 3 nCk 10 factorial 3 factorial 7 factorial * / = ] unit-test
[ 1 ] [ 0 factorial ] unit-test
[ 1 ] [ 1 factorial ] unit-test
[ 2 ] [ 2 factorial ] unit-test
[ 120 ] [ 5 factorial ] unit-test
[ 3628800 ] [ 10 factorial ] unit-test
[ 1 ] [ 1 0 1 factorial-part ] unit-test
[ 2 ] [ 1 1 2 factorial-part ] unit-test
[ 1 ] [ 1 1 1 factorial-part ] unit-test
[ 3628800 ] [ 120 5 10 factorial-part ] unit-test
[ 1 ] [ 2 2 nCk ] unit-test
[ 2 ] [ 2 2 nPk ] unit-test
[ 1 ] [ 2 0 nCk ] unit-test
[ 1 ] [ 2 0 nPk ] unit-test
[ t ] [ -9000000000000000000000000000000000000000000 gamma inf = ] unit-test
[ t ] [ -1.5 gamma 2.36327 - abs .0001 < ] unit-test
[ t ] [ -1 gamma inf = ] unit-test
[ t ] [ -0.5 gamma -3.5449 - abs .0001 < ] unit-test
[ t ] [ 0 gamma inf = ] unit-test
[ t ] [ .5 gamma 1.7725 - abs .0001 < ] unit-test
[ t ] [ 1 gamma 1 - abs .0001 < ] unit-test
[ t ] [ 2 gamma 1 - abs .0001 < ] unit-test
[ t ] [ 3 gamma 2 - abs .0001 < ] unit-test
[ t ] [ 11 gamma 3628800 - abs .0001 < ] unit-test
[ t ] [ 90000000000000000000000000000000000000000000 gamma inf = ] unit-test
! some fun identities
[ t ] [ 2/3 gamma 2 pi * 3 sqrt 1/3 gamma * / - abs .00001 < ] unit-test
[ t ] [ 3/4 gamma 2 sqrt pi * 1/4 gamma / - abs .0001 < ] unit-test
[ t ] [ 4/5 gamma 2 5 sqrt / 2 + sqrt pi * 1/5 gamma / - abs .0001 < ] unit-test
[ t ] [ 3/5 gamma 2 2 5 sqrt / - sqrt pi * 2/5 gamma / - abs .0001 < ] unit-test
[ t ] [ -90000000000000000000000000000000000000000000 gammaln inf = ] unit-test
[ t ] [ -1.5 gammaln inf = ] unit-test
[ t ] [ -1 gammaln inf = ] unit-test
[ t ] [ -0.5 gammaln inf = ] unit-test
[ t ] [ 0 gammaln inf = ] unit-test
[ t ] [ .5 gammaln .5724 - abs .0001 < ] unit-test
[ t ] [ 1 gammaln 0 - abs .0001 < ] unit-test
[ t ] [ 2 gammaln 0 - abs .0001 < ] unit-test
[ t ] [ 3 gammaln 0.6931 - abs .0001 < ] unit-test
[ t ] [ 11 gammaln 15.1044 - abs .0001 < ] unit-test
[ t ] [ 9000000000000000000000000000000000000000000 gammaln 8.811521863477754e+44 - abs 5.387515050969975e+30 < ] unit-test

