USING: lists lists.lazy math.primes.lists tools.test ;

{ { 2 3 5 7 11 13 17 19 23 29 } } [ lprimes 10 ltake list>array ] unit-test
{ { 101 103 107 109 113 } } [ 100 lprimes-from 5 ltake list>array ] unit-test
{ { 1000117 1000121 } } [ 1000100 lprimes-from 2 ltake list>array ] unit-test
{ { 999983 1000003 } } [ 999982 lprimes-from 2 ltake list>array ] unit-test
