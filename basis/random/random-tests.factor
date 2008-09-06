USING: random sequences tools.test kernel ;
IN: random.tests

[ 4 ] [ 4 random-bytes length ] unit-test
[ 7 ] [ 7 random-bytes length ] unit-test

[ 4 ] [ [ 4 random-bytes length ] with-secure-random ] unit-test
[ 7 ] [ [ 7 random-bytes length ] with-secure-random ] unit-test

[ 2 ] [ V{ 10 20 30 } [ delete-random drop ] keep length ] unit-test
[ V{ } [ delete-random drop ] keep length ] must-fail
