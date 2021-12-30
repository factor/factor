USING: fry kernel math math.bitwise math.primes.erato
ranges sequences tools.test ;

{ B{ 255 251 247 126 } } [ 100 sieve ] unit-test
[ 1 100 sieve marked-prime? ] [ bounds-error? ] must-fail-with
[ 120 100 sieve marked-prime? ] [ bounds-error? ] must-fail-with
{ f } [ 119 100 sieve marked-prime? ] unit-test
{ t } [ 113 100 sieve marked-prime? ] unit-test

! There are 25997 primes below 300000. 1 must be removed and 3 5 7 added.
{ 25997 } [ 299999 sieve [ bit-count ] map-sum 2 + ] unit-test

! Check sieve array length logic by making sure we get the right
! end-point for numbers with all possibilities mod 30. If something
! were to go wrong, we'd get a bounds-error.
{ } [ 2 100 [a..b] [ dup sieve marked-prime? drop ] each ] unit-test

{ t } [
    { 2 3 5 7 11 13 } 100 sieve '[ _ marked-prime? ] all?
] unit-test
{ t } [
    { 4 6 8 9 10 12 } 100 sieve '[ _ marked-prime? not ] all?
] unit-test
