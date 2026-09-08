USING: arrays assocs combinators continuations cpu.arm.64.features
cpu.arm.64.features.windows generic hashtables init kernel literals locals math
memoize namespaces sequences system tools.test
vocabs words ;
IN: cpu.arm.64.features.windows.tests

! Expectations are literal SDK feature IDs, independently of the constants
! consumed by the implementation. SVE features never establish NEON support.
{ { 43 67 68 66 } } [
    { $ PF_ARM_V82_DP_INSTRUCTIONS_AVAILABLE
      $ PF_ARM_V82_FP16_INSTRUCTIONS_AVAILABLE
      $ PF_ARM_V86_BF16_INSTRUCTIONS_AVAILABLE
      $ PF_ARM_V82_I8MM_INSTRUCTIONS_AVAILABLE }
] unit-test
{ { } } [ [ drop 0 ] windows-query>arm64-features ] unit-test
{ { "dotprod" "fp16" "bf16" "i8mm" } } [
    [ drop 1 ] windows-query>arm64-features
] unit-test
{ { "dotprod" "fp16" "bf16" "i8mm" } } [
    [ drop -1 ] windows-query>arm64-features
] unit-test
{ { } } [
    [ { 29 30 31 34 44 45 46 47 52 57 69 } member? 1 0 ? ]
    windows-query>arm64-features
] unit-test
{ { } } [ [ "query failed" throw ] windows-query>arm64-features ] unit-test

! Exhaust all 3^4 absent/present/error combinations. The expected list comes
! from the input states, never from the implementation's mapping constants.
:: check-windows-responses ( states -- ? )
    { 43 67 68 66 } states zip >hashtable :> replies
    [ replies at {
        { 0 [ 0 ] } { 1 [ 7 ] } { 2 [ "query failed" throw ] }
    } case ] windows-query>arm64-features
    { "dotprod" "fp16" "bf16" "i8mm" } states zip
    [ second 1 = ] filter [ first ] map = ;

{ t } [
    81 <iota> [
        { [ 3 mod ] [ 3 /i 3 mod ] [ 9 /i 3 mod ] [ 27 /i 3 mod ] } cleave
        4array check-windows-responses
    ] all?
] unit-test

! Exact query sequence guards against querying SVE, generic v8, or a mask.
{ { 43 67 68 66 } } [
    V{ } clone [ '[ _ push 0 ] windows-query>arm64-features drop ] keep
    >array
] unit-test

! This vocabulary is deliberately portable; only the native adapter loads
! Kernel32. The platform method remains available for metadata inspection.
{ t } [ windows \ probe-arm64-features ?lookup-method >boolean ] unit-test
{ t } [
    "cpu.arm.64.features.windows.kernel32" lookup-vocab >boolean os windows? =
] unit-test

! Reusing an image cannot turn a cached capability into a permanent claim.
! Exercise the actual registered startup hook and leave the cache invalidated.
{ t } [
    [
        \ detected-arm64-features "memoize" word-prop
        [ t over set-first { "saved-image-only" } swap set-second ] keep
        startup-hooks get "cpu.arm.64.features" of call( -- )
        first not
    ] [ \ detected-arm64-features reset-memoized ] finally
] unit-test
