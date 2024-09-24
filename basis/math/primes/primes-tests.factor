USING: arrays kernel math math.primes math.primes.miller-rabin
sequences tools.test ;

{ 1237 } [ 1234 next-prime ] unit-test
{ f t } [ 1234 prime? 1237 prime? ] unit-test
{ { 2 3 5 7 } } [ 10 primes-upto >array ] unit-test
{ { 2 } } [ 2 primes-upto >array ] unit-test
{ { } } [ 1 primes-upto >array ] unit-test
{ { 999983 1000003 } } [ 999982 1000010 primes-between >array ] unit-test
{ { } } [ 0 nprimes ] unit-test
{ { 2 3 5 7 } } [ 4 nprimes ] unit-test
{ t } [ 1000 nprimes [ prime? ] all? ] unit-test
{ 1000 } [ 1000 nprimes length ] unit-test
{ 1000 } [ 1000 nprimes last primes-upto length ] unit-test

{ f } [ "ABC" prime? ] unit-test
{ f } [ { } prime? ] unit-test

{ { 4999963 4999999 5000011 5000077 5000081 } }
[ 4999962 5000082 primes-between >array ] unit-test

{ { 8999981 8999993 9000011 9000041 } }
[ 8999980 9000045 primes-between >array ] unit-test

{ { } } [ 5 4 primes-between >array ] unit-test

{ { 2 } } [ 2 2 primes-between >array ] unit-test

{ { 2 } } [ 1.5 2.5 primes-between >array ] unit-test

{ 2 } [ 1 next-prime ] unit-test
{ 3 } [ 2 next-prime ] unit-test
{ 5 } [ 3 next-prime ] unit-test
{ 101 } [ 100 next-prime ] unit-test
{ t } [ 2135623355842621559 miller-rabin ] unit-test
{ 100000000000031 } [ 100000000000000 next-prime ] unit-test

{ 49 } [ 50 random-prime log2 ] unit-test

{ t } [ 5000077 dup find-relative-prime coprime? ] unit-test

{ 5 t { 14 14 14 14 14 } }
[ 5 15 unique-primes [ length ] [ [ prime? ] all? ] [ [ log2 ] map ] tri ] unit-test

{ t t } [ 11 dup >bignum [ prime? ] bi@ ] unit-test
