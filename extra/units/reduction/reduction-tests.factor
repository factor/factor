! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators fry kernel locals math math.functions
math.order math.parser sequences tools.test ;
IN: units.reduction

{ "0Bi" } [ 0 n>storage ] unit-test
{ "0B" } [ 0 n>Storage ] unit-test
{ "0Bi" } [ -0 n>storage ] unit-test
{ "0B" } [ -0 n>Storage ] unit-test
{ "1000Bi" } [ 1,000 n>storage ] unit-test
{ "1K" } [ 1,000 n>Storage ] unit-test
{ "976Ki" } [ 1,000,000 n>storage ] unit-test
{ "1Mi" } [ 2,000,000 n>storage ] unit-test
{ "190Mi" } [ 200,000,000 n>storage ] unit-test
{ "1M" } [ 1,000,000 n>Storage ] unit-test
{ "953Mi" } [ 1,000,000,000 n>storage ] unit-test
{ "1G" } [ 1,000,000,000 n>Storage ] unit-test
{ "931Gi" } [ 1,000,000,000,000 n>storage ] unit-test
{ "1T" } [ 1,000,000,000,000 n>Storage ] unit-test
{ "909Ti" } [ 1,000,000,000,000,000 n>storage ] unit-test
{ "1P" } [ 1,000,000,000,000,000 n>Storage ] unit-test
{ "888Pi" } [ 1,000,000,000,000,000,000 n>storage ] unit-test
{ "1E" } [ 1,000,000,000,000,000,000 n>Storage ] unit-test
{ "-1E" } [ -1,000,000,000,000,000,000 n>Storage ] unit-test

: test-n>storage ( string -- string ) n>storage storage>n n>storage ;
: test-n>Storage ( string -- string ) n>Storage storage>n n>Storage ;

{ "0Bi" } [ 0 test-n>storage ] unit-test
{ "0B" } [ 0 test-n>Storage ] unit-test
{ "0Bi" } [ -0 test-n>storage ] unit-test
{ "0B" } [ -0 test-n>Storage ] unit-test
{ "1000Bi" } [ 1,000 test-n>storage ] unit-test
{ "1K" } [ 1,000 test-n>Storage ] unit-test
{ "976Ki" } [ 1,000,000 test-n>storage ] unit-test
{ "1Mi" } [ 2,000,000 test-n>storage ] unit-test
{ "190Mi" } [ 200,000,000 test-n>storage ] unit-test
{ "1M" } [ 1,000,000 test-n>Storage ] unit-test
{ "953Mi" } [ 1,000,000,000 test-n>storage ] unit-test
{ "1G" } [ 1,000,000,000 test-n>Storage ] unit-test
{ "931Gi" } [ 1,000,000,000,000 test-n>storage ] unit-test
{ "1T" } [ 1,000,000,000,000 test-n>Storage ] unit-test
{ "909Ti" } [ 1,000,000,000,000,000 test-n>storage ] unit-test
{ "1P" } [ 1,000,000,000,000,000 test-n>Storage ] unit-test
{ "888Pi" } [ 1,000,000,000,000,000,000 test-n>storage ] unit-test
{ "1E" } [ 1,000,000,000,000,000,000 test-n>Storage ] unit-test
{ "-1E" } [ -1,000,000,000,000,000,000 test-n>Storage ] unit-test

[ "abc" storage>n ] [ bad-storage-string?  ] must-fail-with
[ "-abc" storage>n ] [ bad-storage-string?  ] must-fail-with
[ "10" storage>n ] [ bad-storage-string?  ] must-fail-with
[ "10b" storage>n ] [ bad-storage-string?  ] must-fail-with
[ "10Mib" storage>n ] [ bad-storage-string?  ] must-fail-with
[ "asdfBi" storage>n ] [ bad-storage-string?  ] must-fail-with
[ "asdfB" storage>n ] [ bad-storage-string?  ] must-fail-with
