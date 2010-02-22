USING: byte-arrays math math.bitwise math.primes.erato sequences tools.test ;

[ B{ 255 251 247 126 } ] [ 100 sieve ] unit-test
[ 1 100 sieve marked-prime? ] [ bounds-error? ] must-fail-with
[ 120 100 sieve marked-prime? ] [ bounds-error? ] must-fail-with
[ f ] [ 119 100 sieve marked-prime? ] unit-test
[ t ] [ 113 100 sieve marked-prime? ] unit-test

! There are 25997 primes below 300000. 1 must be removed and 3 5 7 added.
[ 25997 ] [ 299999 sieve [ bit-count ] map-sum 2 + ] unit-test
