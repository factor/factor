USING: arrays assocs combinators continuations cpu.arm.64.features
cpu.arm.64.features.windows definitions generic hashtables kernel
locals math namespaces sequences compiler.units system tools.test ;
IN: windows-feature-dispatch-regression
SYMBOL: replies

: mock-windows-query ( id -- present )
    replies get at {
        { 0 [ 0 ] } { 1 [ 7 ] } { 2 [ "query failed" throw ] }
    } case ;

! Isolate the host API from the actual Windows probe method. No optional
! opcodes execute; this test is valid on every host OS.
M: macos windows-processor-feature mock-windows-query ;
M: linux windows-processor-feature mock-windows-query ;
M: windows windows-processor-feature mock-windows-query ;

! The baseline had no Windows method. Removing only that newly added method
! recreates its precise dispatch while retaining the injection/test harness.
"legacy-windows-probe" get [
    [ windows \ probe-arm64-features lookup-method forget ] with-compilation-unit
] when

: windows-probe-under-test ( -- features )
    windows \ probe-arm64-features ?lookup-method
    [ object \ probe-arm64-features lookup-method ] unless*
    execute( -- features ) ;

:: check-dispatch ( states -- ? )
    { 43 67 68 66 } states zip >hashtable replies [
        windows-probe-under-test
    ] with-variable
    { "dotprod" "fp16" "bf16" "i8mm" } states zip
    [ second 1 = ] filter [ first ] map = ;

{ 81 } [
    81 <iota> [
        { [ 3 mod ] [ 3 /i 3 mod ] [ 9 /i 3 mod ] [ 27 /i 3 mod ] }
        cleave 4array check-dispatch
    ] count
] unit-test
