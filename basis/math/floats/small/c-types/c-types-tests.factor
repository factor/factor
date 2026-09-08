! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data kernel math.floats.small.c-types
tools.test ;
IN: math.floats.small.c-types.tests

{ 2 2 } [ half heap-size bfloat heap-size ] unit-test
{ 1.5 } [ 1.5 half <ref> half deref ] unit-test
{ -2.5 } [ -2.5 bfloat <ref> bfloat deref ] unit-test
