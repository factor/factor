USING: arrays math math.primes math.primes.miller-rabin
tools.test ;
IN: math.primes.tests

{ 1237 } [ 1234 next-prime ] unit-test
{ f t } [ 1234 prime? 1237 prime? ] unit-test
{ { 2 3 5 7 } } [ 10 primes-upto >array ] unit-test
{ { 999983 1000003 } } [ 999982 1000010 primes-between >array ] unit-test

{ { 4999963 4999999 5000011 5000077 5000081 } }
[ 4999962 5000082 primes-between >array ] unit-test

[ 2 ] [ 1 next-prime ] unit-test
[ 3 ] [ 2 next-prime ] unit-test
[ 5 ] [ 3 next-prime ] unit-test
[ 101 ] [ 100 next-prime ] unit-test
[ t ] [ 2135623355842621559 miller-rabin ] unit-test
[ 100000000000031 ] [ 100000000000000 next-prime ] unit-test

[ 49 ] [ 50 random-prime log2 ] unit-test
