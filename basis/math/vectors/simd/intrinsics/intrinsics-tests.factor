! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data arrays byte-arrays classes
classes.algebra compiler.test cpu.architecture fry kernel kernel.private math
math.floats.small.c-types math.vectors.simd.intrinsics.private
math.vectors math.vectors.simd sequences specialized-arrays tools.test ;
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

! Compare public fallback calls and specialized machine code against explicit
! results, rather than just comparing two implementations of the same helper.
:: rounding-matches? ( input expected quot: ( input -- output ) -- ? )
    input class-of :> type
    expected underlying>> :> bytes
    input quot call underlying>> bytes =
    input type 1array quot '[ _ declare @ ] compile-call underlying>> bytes = and ; inline

{ t } [
    float-4{ 1/0. -1/0. -0.0 -0.25 }
    float-4{ 1/0. -1/0. -0.0 -0.0 }
    [ vround-to-even ] rounding-matches?
] unit-test

{ t } [
    float-4{ -0.0 -0.25 -0.5 0.5 }
    float-4{ -0.0 -0.0 -1.0 1.0 }
    [ vround ] rounding-matches?
] unit-test

{ t } [
    double-2{ 4503599627370497.0 -4503599627370497.0 }
    double-2{ 4503599627370497.0 -4503599627370497.0 }
    [ vround ] rounding-matches?
] unit-test

{ t } [
    double-2{ 0.49999999999999994 -0.49999999999999994 }
    double-2{ 0.0 -0.0 }
    [ vround ] rounding-matches?
] unit-test

{ t } [
    float-4{ 0.5 1.5 -2.5 -3.5 }
    float-4{ 0.0 2.0 -2.0 -4.0 }
    [ vround-to-even ] rounding-matches?
] unit-test

{ t } [
    half-8{ -0.0 -0.25 -0.5 0.5 1.5 -2.5 1/0. -1/0. }
    half-8{ -0.0 -0.0 -0.0 0.0 2.0 -2.0 1/0. -1/0. }
    [ vround-to-even ] rounding-matches?
] unit-test

:: reduction-matches? ( input expected quot: ( input -- output ) -- ? )
    input class-of :> type
    input quot call expected fp-bitwise=
    input type 1array quot '[ _ declare @ ] compile-call expected fp-bitwise= and ; inline

{ t } [ float-4{ 3.0 1.0 2.0 0/0. } 1.0 [ vmin-element ] reduction-matches? ] unit-test
{ t } [ float-4{ 3.0 1.0 2.0 0/0. } 3.0 [ vmax-element ] reduction-matches? ] unit-test
{ t } [ double-2{ -0.0 0.0 } -0.0 [ vmin-element ] reduction-matches? ] unit-test
{ t } [ double-2{ 0.0 -0.0 } 0.0 [ vmax-element ] reduction-matches? ] unit-test

:: extrema-match? ( a b expected quot: ( a b -- result ) -- ? )
    a class-of b class-of 2array :> types
    expected underlying>> :> bytes
    a b quot call underlying>> bytes =
    a b types quot '[ _ declare @ ] compile-call underlying>> bytes = and ; inline

{ t } [
    float-4{ -0.0 0.0 0/0. 3.0 } float-4{ 0.0 -0.0 2.0 0/0. }
    float-4{ -0.0 -0.0 2.0 3.0 } [ vmin ] extrema-match?
] unit-test
{ t } [
    float-4{ -0.0 0.0 0/0. 3.0 } float-4{ 0.0 -0.0 2.0 0/0. }
    float-4{ 0.0 0.0 2.0 3.0 } [ vmax ] extrema-match?
] unit-test
{ t } [
    double-2{ -0.0 0.0 } double-2{ 0.0 -0.0 }
    double-2{ -0.0 -0.0 } [ vmin ] extrema-match?
] unit-test
{ t } [
    double-2{ -0.0 0.0 } double-2{ 0.0 -0.0 }
    double-2{ 0.0 0.0 } [ vmax ] extrema-match?
] unit-test
{ t } [
    double-2{ 0/0. -1/0. } double-2{ 1/0. 0/0. }
    double-2{ 1/0. -1/0. } [ vmin ] extrema-match?
] unit-test
{ t } [
    double-2{ 0/0. -1/0. } double-2{ 1/0. 0/0. }
    double-2{ 1/0. -1/0. } [ vmax ] extrema-match?
] unit-test
