! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data arrays byte-arrays classes
classes.algebra compiler.cfg.instructions compiler.test cpu.architecture fry kernel kernel.private math
math.floats.small.c-types math.vectors.simd.intrinsics math.vectors.simd.intrinsics.private
math.vectors math.vectors.simd namespaces sequences specialized-arrays tools.test ;
IN: math.vectors.simd.intrinsics.tests

CONSTANT: all-simd-classes {
    char-16 uchar-16 short-8 ushort-8 int-4 uint-4 longlong-2 ulonglong-2
    float-4 double-2 half-8 bfloat-8
}

! #665: compare byte shifts with an independent byte-index reference. Counts
! are bytes even for floating lanes, and oversized counts clear the register.
:: horizontal-shift-matches? ( class n op: ( v n -- w ) left? -- ? )
    B{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 } :> bytes
    bytes clone class boa :> input
    16 <iota> [ n left? [ - ] [ + ] if bytes ?nth 0 or ] B{ } map-as :> expected
    input n op call underlying>> expected =
    input n class n class-of 2array op '[ _ declare @ ]
    compile-call underlying>> expected = and
    input class 1array n op '[ _ declare _ @ ]
    compile-call underlying>> expected = and
    input t "always-inline-simd-intrinsics" [
        class 1array n op '[ _ declare _ @ ] compile-call
    ] with-variable underlying>> expected = and ; inline

all-simd-classes [
    '[
        { 0 1 3 7 15 16 17 255 256 1000 0x10000000000000000000000000 } [
            _ swap [
                [ hlshift ] t horizontal-shift-matches?
            ] [
                [ hrshift ] f horizontal-shift-matches?
            ] 2bi and
        ] all?
    ] { t } swap unit-test
] each

! SSE lane shifts encode literal counts in one byte. Oversized counts must
! saturate the shift, not wrap modulo 256. Check literal and register paths.
:: lane-shift-matches? ( input n op: ( v n -- w ) -- ? )
    input class-of 1array :> declaration
    input t "always-inline-simd-intrinsics" [
        declaration n op '[ _ declare _ @ ]
        [ compile-call ] call( v quot -- w )
    ] with-variable underlying>> :> expected
    input declaration n op '[ _ declare _ @ ]
    [ compile-call ] call( v quot -- w ) underlying>> expected =
    input n input class-of n class-of 2array op '[ _ declare @ ]
    [ compile-call ] call( v n quot -- w ) underlying>> expected = and ; inline

{
    short-8{ -1 -32768 32767 1 -2 2 -3 3 }
    ushort-8{ 1 65535 32768 32767 2 3 4 5 }
    int-4{ -2147483648 2147483647 -1 1 }
    uint-4{ 4294967295 2147483648 1 0 }
    longlong-2{ -9223372036854775808 9223372036854775807 }
    ulonglong-2{ 18446744073709551615 1 }
} [
    '[
        { 0 15 16 31 32 63 64 255 256 257 1000 } [
            _ swap [ [ vlshift ] lane-shift-matches? ]
            [ [ vrshift ] lane-shift-matches? ] 2bi and
        ] all?
    ] { t } swap unit-test
] each

! Dot products accumulate scalar products rather than wrapping integer lanes.
! Compare all representations, including half/bfloat, with exact small sums.
:: dot-matches? ( a b expected -- ? )
    a b vdot expected number=
    a b a class-of b class-of 2array '[ _ declare vdot ]
    [ compile-call ] call( a b quot -- result ) expected number= and
    a b t "always-inline-simd-intrinsics" [
        a class-of b class-of 2array '[ _ declare vdot ]
        [ compile-call ] call( a b quot -- result )
    ] with-variable expected number= and ;

all-simd-classes [
    '[ _ new [ drop 100 ] map dup dup length 10000 * dot-matches? ]
    { t } swap unit-test
] each

{ t } [
    longlong-2{ -9223372036854775808 9223372036854775807 } dup
    170141183460469231713240559642174554113 dot-matches?
] unit-test

{ t } [
    ulonglong-2{ 18446744073709551615 18446744073709551615 } dup
    680564733841876926852962238568698216450 dot-matches?
] unit-test

! #283: the SSE2 add/sub fallback must preserve NaN signs as well as zeros.
:: add-sub-matches? ( a b -- ? )
    a b v+- underlying>>
    a b a class-of b class-of 2array '[ _ declare v+- ]
    [ compile-call ] call( a b quot -- result ) underlying>> = ;

{ t } [ double-2{ 1 2 } double-2{ 0/0. 1 } add-sub-matches? ] unit-test
{ t } [
    float-4{ 1 2 3 4 } float-4{ 0/0. 1 0/0. 1 } add-sub-matches?
] unit-test
{ t } [ double-2{ -0.0 -0.0 } double-2{ 0.0 -0.0 } add-sub-matches? ] unit-test
{ t } [
    float-4{ -0.0 -0.0 0.0 0.0 } float-4{ 0.0 -0.0 -0.0 0.0 } add-sub-matches?
] unit-test

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

! Keep signaling NaNs in raw storage: scalar float conversion may quiet them.
{ t } [
    uint-4{ 0x7f800001 0x3f800000 0xff800001 0x40000000 } float-4-cast
    uint-4{ 0x40000000 0x7f800001 0x40400000 0xff800001 } float-4-cast
    float-4{ 2.0 1.0 3.0 2.0 } [ vmin ] extrema-match?
] unit-test
{ t } [
    uint-4{ 0x7f800001 0x3f800000 0xff800001 0x40000000 } float-4-cast
    uint-4{ 0x40000000 0x7f800001 0x40400000 0xff800001 } float-4-cast
    float-4{ 2.0 1.0 3.0 2.0 } [ vmax ] extrema-match?
] unit-test
{ t } [
    ulonglong-2{ 0x7ff0000000000001 0x3ff0000000000000 } double-2-cast
    ulonglong-2{ 0x4000000000000000 0xfff0000000000001 } double-2-cast
    double-2{ 2.0 1.0 } [ vmin ] extrema-match?
] unit-test
{ t } [
    ulonglong-2{ 0x7ff0000000000001 0x3ff0000000000000 } double-2-cast
    ulonglong-2{ 0x4000000000000000 0xfff0000000000001 } double-2-cast
    double-2{ 2.0 1.0 } [ vmax ] extrema-match?
] unit-test
{ t } [
    uint-4{ 0x7f800001 0x3f800000 0xff800001 0x40000000 } float-4-cast
    1.0 [ vmin-element ] reduction-matches?
] unit-test
{ t } [
    uint-4{ 0x7f800001 0x40000000 0xff800001 0x3f800000 } float-4-cast
    2.0 [ vmax-element ] reduction-matches?
] unit-test
{ t } [
    ulonglong-2{ 0x3ff0000000000000 0x7ff0000000000001 } double-2-cast
    1.0 [ vmin-element ] reduction-matches?
] unit-test
{ t } [
    ulonglong-2{ 0x7ff0000000000001 0x3ff0000000000000 } double-2-cast
    1.0 [ vmax-element ] reduction-matches?
] unit-test

! Matching fallback results must not conceal failed native SIMD lowering.
{ t } [
    [ float-4-rep (simd-vmin) ] [ ##compare-vector? ] contains-insn?
] unit-test
{ t } [
    [ double-2-rep (simd-vmax) ] [ ##compare-vector? ] contains-insn?
] unit-test
