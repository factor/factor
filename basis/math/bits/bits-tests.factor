! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test math math.bits sequences arrays ;

{ t } [ 0b111111 3 <bits> second ] unit-test
{ { t t t } } [ 0b111111 3 <bits> >array ] unit-test
{ f } [ 0b111101 3 <bits> second ] unit-test
{ { f f t } } [ 0b111100 3 <bits> >array ] unit-test
{ 3 } [ 0b111111 3 <bits> length ] unit-test
{ 6 } [ 0b111111 make-bits length ] unit-test
{ 1 } [ 0 make-bits length ] unit-test
{ 1 } [ 1 make-bits length ] unit-test
{ 2 } [ 3 make-bits length ] unit-test
[ -3 make-bits length ] [ non-negative-number-expected? ] must-fail-with

! Odd bug
{ t } [
    1067811677921310779 make-bits
    1067811677921310779 >bignum make-bits
    sequence=
] unit-test

{ t } [
    1067811677921310779 make-bits last
] unit-test

{ t } [
    1067811677921310779 >bignum make-bits last
] unit-test

{ 6 } [ 6 make-bits bits>number ] unit-test
{ 6 } [ 6 3 <bits> >array bits>number ] unit-test
