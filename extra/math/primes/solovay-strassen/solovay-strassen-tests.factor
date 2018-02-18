USING: kernel math.primes math.primes.solovay-strassen sequences
tools.test ;

{ t } [
    100,000 <iota> [ solovay-strassen ] filter
    100,000 primes-upto =
] unit-test
