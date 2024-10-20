! Copyright (C) 2024 Your name.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test combinators.syntax math kernel  ;
IN: combinators.syntax.tests
{ 3 1 } [
    2 3
    *[ 1 + | 2 - ]
] unit-test
{ 6 7 } [
    5
    &[ 1 + | 2 + ]
] unit-test
{ 7 7 } [
    5 2
    [| x | &[ x + | x + ] ] call
] unit-test
{ 3 -1 } [
    1 2
    2 n&[ + | - ]
] unit-test
{ 7 -1 } [
    3 4 1 2
    2 n*[ + | - ]
] unit-test
{ 7 -1 } [
    14 6
    2 @[ 7 - ]
] unit-test
{ 1 2 } [
    0 1 1 1
    2 2 n@[ + ]
] unit-test
