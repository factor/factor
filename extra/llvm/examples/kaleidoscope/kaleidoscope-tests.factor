! Copyright (C) 2017 Björn Lindqvist
! See https://factorcode.org/license.txt for BSD license.
USING: llvm.examples.kaleidoscope tools.test ;
IN: llvm.examples.kaleidoscope.tests


{
    V{ T{ ast-binop { lhs 3 } { rhs 4 } { operator "+" } } }
} [
    "3 + 4" parse-kaleidoscope
] unit-test
