! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel random random.sfmt random.sfmt.private
sequences tools.test ;

! Period certified by virtue of seed
{ } [ 5 <sfmt-19937> drop ] unit-test

{ 1331696015 }
[ 5 <sfmt-19937> dup generate dup generate uint-array>> first ] unit-test

{ 1432875926 }
[ 5 <sfmt-19937> random-32* ] unit-test


! Period certified by flipping a bit
{ } [ 7 <sfmt-19937> drop ] unit-test

{ 1674111379 }
[ 7 <sfmt-19937> dup generate dup generate uint-array>> first ] unit-test

{ 489955657 }
[ 7 <sfmt-19937> random-32* ] unit-test


! Test re-seeding SFMT
{ t }
[
    100 <sfmt-19937>
    [ random-32* ]
    [ 100 seed-random random-32* ] bi =
] unit-test
