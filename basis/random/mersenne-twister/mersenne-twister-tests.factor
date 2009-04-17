USING: kernel math random namespaces make
random.mersenne-twister sequences tools.test math.order ;
IN: random.mersenne-twister.tests

: check-random ( max -- ? )
    [ random 0 ] keep between? ;

[ t ] [ 100 [ drop 674 check-random ] all? ] unit-test

: randoms ( -- seq )
    100 [ 100 random ] replicate ;

: test-rng ( seed quot -- )
    [  <mersenne-twister> ] dip with-random ; inline

[ f ] [ 1234 [ randoms randoms = ] test-rng ] unit-test

[ 1333075495 ] [
    0 [ 1000 [ drop random-generator get random-32* drop ] each random-generator get random-32* ] test-rng
] unit-test

[ 1575309035 ] [
    0 [ 10000 [ drop random-generator get random-32* drop ] each random-generator get random-32* ] test-rng
] unit-test


[ 3 ] [ 101 [ 3 random-bytes length ] test-rng ] unit-test
[ 33 ] [ 101 [ 33 random-bytes length ] test-rng ] unit-test
[ t ] [ 101 [ 100 random-bits log2 90 > ] test-rng ] unit-test
