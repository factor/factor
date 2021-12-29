USING: math.primes.brute-force tools.test ;

{ { } } [ -5 brute-force-factors ] unit-test
{ { { 999983 2 } { 1000003 1 } } } [ 999969000187000867 brute-force-factors ] unit-test
