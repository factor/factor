! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel locals math sequences tools.test
ui.text.directwrite.transforms ;
IN: ui.text.directwrite.transforms.tests

: test-transform ( -- matrix )
    { 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 } clone ;

! Cancel a large scroll position before converting anything to float32.
! Both the fractional pixel and the original matrix must survive.
{ { 0.25 7.0 } { 0 0 } } [
    test-transform dup { -59114872.75 5 } translate-directwrite-transform
    { 59114873 2 } translate-directwrite-transform
    12 14 rot subseq swap 12 14 rot subseq
] unit-test

! Projection composition must not round the large translation either.
{ -59114872.75 } [
    test-transform
    test-transform { -59114872.75 5 } translate-directwrite-transform
    multiply-directwrite-transforms 12 swap nth
] unit-test

! Translation obeys the current scale, including mirroring.
{ { -17 23 } } [
    { -2 0 0 0 0 3 0 0 0 0 1 0 5 2 0 1 }
    { 11 7 } translate-directwrite-transform 12 14 rot subseq
] unit-test
