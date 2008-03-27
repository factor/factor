USING: kernel math random namespaces random.mersenne-twister
sequences tools.test ;
IN: random.mersenne-twister.tests

: check-random ( max -- ? )
    dup >r random 0 r> between? ;

[ t ] [ 100 [ drop 674 check-random ] all? ] unit-test

: make-100-randoms
    [ 100 [ 100 random , ] times ] { } make ;

: test-rng ( seed quot -- )
    >r <mersenne-twister> r> with-random ;

[ f ] [ 1234 [ make-100-randoms make-100-randoms = ] test-rng ] unit-test

[ 1333075495 ] [
    0 [ 1000 [ drop random-generator get random-32* drop ] each random-generator get random-32* ] test-rng
] unit-test

[ 1575309035 ] [
    0 [ 10000 [ drop random-generator get random-32* drop ] each random-generator get random-32* ] test-rng
] unit-test


[ 3 ] [ 101 [ 3 random-bytes length ] test-rng ] unit-test
[ 33 ] [ 101 [ 33 random-bytes length ] test-rng ] unit-test
[ t ] [ 101 [ 100 random-bits log2 90 > ] test-rng ] unit-test
