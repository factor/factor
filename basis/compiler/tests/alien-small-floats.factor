! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax combinators io io.pathnames
kernel math namespaces system tools.test tools.test.ffi ;
IN: compiler.tests.alien-small-floats-driver

<<
"small-floats-capability" "resource:" absolute-path
os {
    { windows [ "libfactor-ffi-test.dll" ] }
    { macos [ "libfactor-ffi-test.dylib" ] }
    [ drop "libfactor-ffi-test.so" ]
} case append-path cdecl add-library
>>
LIBRARY: small-floats-capability
FUNCTION: int ffi_test_small_floats_available ( )

0 small-abi-cases set-global
ffi_test_small_floats_available 0 > cpu arm.64? and [
    "resource:basis/compiler/tests/small-floats/cases.factor" run-test-file
] [
    "FFI-SKIP small reason=unsupported-toolchain-or-cpu" print
    required-small-floats? [ "Required half/BF16 fixtures unavailable" throw ] when
] if

"small" small-abi-cases get report-ffi-coverage
required-small-floats? [
    small-abi-cases get os linux? [ 26 ] [ 24 ] if >= [ "Reduced-type coverage incomplete" throw ] unless
] when
