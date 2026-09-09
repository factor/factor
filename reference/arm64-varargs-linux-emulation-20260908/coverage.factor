! Required native fixtures fail closed; unsupported toolchains are explicit lanes.
USING: alien alien.c-types alien.libraries alien.syntax combinators
io io.pathnames kernel namespaces system ;
IN: arm64-varargs-ci

<<
"varargs-ci" "resource:" absolute-path os {
    { windows [ "libfactor-ffi-test.dll" ] }
    { macos [ "libfactor-ffi-test.dylib" ] }
    [ drop "libfactor-ffi-test.so" ]
} case append-path cdecl add-library
>>
LIBRARY: varargs-ci
FUNCTION: int va_c_controls ( )
FUNCTION: int va_small_available ( )
FUNCTION: int va_small_controls ( )
FUNCTION: int ffi_test_small_floats_available ( )

cpu arm.64? [ "Varargs qualification requires a native ARM64 VM" throw ] unless
va_c_controls 255 assert=
"require-varargs-small" get [
    va_small_available 1 assert=
    ffi_test_small_floats_available 1 assert=
    va_small_controls 1 assert=
    "ARM64 half/BF16 varargs coverage required and available" print
] when
"ARM64 C varargs controls passed: 0xff" print

"expect-varargs-small-unavailable" get [
    va_small_available 0 assert=
    ffi_test_small_floats_available 0 assert=
    "ARM64 half/BF16 fixture capability explicitly unavailable in this compiler lane" print
] when
