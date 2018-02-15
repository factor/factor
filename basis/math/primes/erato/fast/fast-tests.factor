USING: fry kernel math.primes.erato.fast sequences tools.test ;

{

    V{
        2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71
        73 79 83 89 97
    }
} [ 100 sieve ] unit-test

{ 1229 } [ 10,000 sieve length ] unit-test
{ 9592 } [ 100,000 sieve length ] unit-test
{ 78498 } [ 1,000,000 sieve length ] unit-test

{ t } [
    { 2 3 5 7 11 13 } 100 make-sieve '[ _ marked-prime? ] all?
] unit-test
{ t } [
    { 4 6 8 9 10 12 } 100 make-sieve '[ _ marked-prime? not ] all?
] unit-test
