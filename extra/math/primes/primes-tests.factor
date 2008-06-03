USING: arrays math.primes tools.test lists lists.lazy ;

{ 1237 } [ 1234 next-prime ] unit-test
{ f t } [ 1234 prime? 1237 prime? ] unit-test
{ { 2 3 5 7 11 13 17 19 23 29 } } [ 10 lprimes ltake list>array ] unit-test
{ { 101 103 107 109 113 } } [ 5 100 lprimes-from ltake list>array ] unit-test
{ { 1000117 1000121 } } [ 2 1000100 lprimes-from ltake list>array ] unit-test
{ { 999983 1000003 } } [ 2 999982 lprimes-from ltake list>array ] unit-test
{ { 2 3 5 7 } } [ 10 primes-upto >array ] unit-test
{ { 999983 1000003 } } [ 999982 1000010 primes-between >array ] unit-test
