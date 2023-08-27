! Copyright (C) 2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: sequences strings tools.test rosetta-code.multisplit ;
IN: rosetta-code.multisplit.tests

{ { "a" "" "b" "" "c" } } [
    "a!===b=!=c" { "==" "!=" "=" } multisplit [ >string ] map
] unit-test
