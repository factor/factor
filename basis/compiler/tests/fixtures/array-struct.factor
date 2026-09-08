USING: accessors alien alien.c-types alien.libraries alien.syntax
classes.struct environment io.pathnames kernel sequences specialized-arrays
system tools.test ;
FROM: alien.c-types => float ;
IN: compiler.tests.alien-linux-regressions
<< "linux-regressions" "FACTOR_REPRO_LIBRARY" os-env [ ] [
    "resource:" absolute-path
    os macos? [ "libfactor-ffi-test.dylib" ] [ "libfactor-ffi-test.so" ] if append-path
] if* cdecl add-library >>
LIBRARY: linux-regressions
SPECIALIZED-ARRAY: float
STRUCT: float-array-struct { values float[3] } ;
FUNCTION: float-array-struct ffi_array_struct ( float-array-struct x )
{ 11.0 22.0 33.0 } [
    float-array-struct <struct> float-array{ 1.0 2.0 3.0 } >>values
    ffi_array_struct values>> first3
] unit-test
