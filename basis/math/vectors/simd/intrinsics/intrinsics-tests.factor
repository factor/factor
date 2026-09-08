! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data arrays byte-arrays classes
classes.algebra compiler.test cpu.architecture kernel math
math.floats.small.c-types math.vectors.simd.intrinsics.private
sequences specialized-arrays tools.test ;
IN: math.vectors.simd.intrinsics.tests

! Dynamic dispatch must retain the element type, length, and shared storage.
:: check-rep-array ( rep -- ? )
    16 <byte-array> :> bytes
    bytes rep byte>rep-array :> array
    array class-of rep rep-component-type c-array-type =
    array length rep rep-length = and
    array underlying>> bytes eq? and
    7 0 array set-nth
    0 bytes rep byte>rep-array nth 7 number= and ;

{ t } [ vector-reps [ check-rep-array ] all? ] unit-test

! A known representation still specializes to direct element access.
{ t } [
    [ int-4-rep byte>rep-array first ] final-classes first integer class<=
] unit-test

{ t } [
    [ half-8-rep byte>rep-array ] final-classes first
    half c-array-type =
] unit-test

{ 7 } [
    16 <byte-array> uint-4-rep byte>rep-array
    [ 7 0 rot set-nth ] [ underlying>> ] bi
    [ uint-4-rep byte>rep-array first ] compile-call
] unit-test
