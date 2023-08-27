! Copyright (C) 2023 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math random tools.test random.pcg ;
IN: random.pcg.tests

{ 3182460383 1446378418 } [
    1 1 <Mwc128XXA32> dup random-32* swap
    999999 [ dup random-32* drop ] times random-32*
] unit-test

{
    0x05e5078c
    0xc712599d
    0xcb088197
    0x38b1f3b7
} [
    1 1 <Mwc256XXA64>
    2 [ [ random-32* ] keep ] times
    1999998 [ dup random-32* drop ] times
    2 [ [ random-32* ] keep ] times
    drop
] unit-test
