! Copyright (C) 2019 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test factlog factlog.examples.fib2 ;
IN: factlog.examples.fib2.tests

{ { H{ { F 6765 } } } } [
    { fibo 20 F } query
] unit-test
