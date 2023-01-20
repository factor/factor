! Copyright (C) 2014 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays compression.snappy kernel tools.test ;
IN: compression.snappy.tests

{ t } [
    1000 2 <array> >byte-array [ snappy-compress snappy-uncompress ] keep =
] unit-test

{ t } [
    B{ } [ snappy-compress snappy-uncompress ] keep =
] unit-test

{ t } [
    B{ 1 } [ snappy-compress snappy-uncompress ] keep =
] unit-test

{ t } [
    B{ 1 2 } [ snappy-compress snappy-uncompress ] keep =
] unit-test

{ t } [
    B{ 1 2 3 } [ snappy-compress snappy-uncompress ] keep =
] unit-test
