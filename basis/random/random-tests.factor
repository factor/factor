USING: random sequences tools.test ;
IN: random.tests

[ 4 ] [ 4 random-bytes length ] unit-test
[ 7 ] [ 7 random-bytes length ] unit-test

[ 4 ] [ [ 4 random-bytes length ] with-secure-random ] unit-test
[ 7 ] [ [ 7 random-bytes length ] with-secure-random ] unit-test
