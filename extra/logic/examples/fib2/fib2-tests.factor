! Copyright (C) 2019 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test logic logic.examples.fib2 ;

{ { H{ { F 6765 } } } } [
    { fibo 20 F } query
] unit-test
