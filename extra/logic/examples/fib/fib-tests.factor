! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test logic lists logic.examples.fib ;

{ { H{ { L L{ 0 } } } } } [ { fibo 0 L } query ] unit-test

{ { H{ { L L{ 1 1 0 } } } } } [ { fibo 2 L } query ] unit-test

{ { H{ { L L{ 55 34 21 13 8 5 3 2 1 1 0 } } } } } [
    { fibo 10 L } query
] unit-test
