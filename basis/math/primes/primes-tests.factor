USING: arrays math.primes tools.test ;

{ 1237 } [ 1234 next-prime ] unit-test
{ f t } [ 1234 prime? 1237 prime? ] unit-test
{ { 2 3 5 7 } } [ 10 primes-upto >array ] unit-test
{ { 999983 1000003 } } [ 999982 1000010 primes-between >array ] unit-test

{ { 4999963 4999999 5000011 5000077 5000081 } }
[ 4999962 5000082 primes-between >array ] unit-test
