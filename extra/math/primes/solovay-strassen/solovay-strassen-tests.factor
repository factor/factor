USING: kernel math.primes sequences tools.test ;
IN: math.primes.solovay-strassen

{ t } [
    100,000 iota [ solovay-strassen ] filter
    100,000 primes-upto =
] unit-test
