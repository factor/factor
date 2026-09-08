! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax combinators io io.pathnames
kernel math system tools.test ;
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

ffi_test_small_floats_available 0 > cpu arm.64? and [
    "resource:basis/compiler/tests/small-floats/cases.factor" run-test-file
] [
    "Scalar half/BF16 C fixtures unavailable on this toolchain; skipped." print
] if
