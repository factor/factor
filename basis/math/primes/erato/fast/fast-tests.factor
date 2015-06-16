USING: sequences tools.test ;
IN: math.primes.erato.fast

{

    V{
        2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71
        73 79 83 89 97
    }
} [ 100 sieve ] unit-test

{ 1229 } [ 10,000 sieve length ] unit-test
{ 9592 } [ 100,000 sieve length ] unit-test
{ 78498 } [ 1,000,000 sieve length ] unit-test
