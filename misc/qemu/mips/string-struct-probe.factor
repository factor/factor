! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.arrays alien.c-types alien.libraries alien.syntax
arrays classes.struct compiler.units cpu.architecture cpu.mips.abi io io.pathnames
kernel math sequences system ;
IN: mips.string-struct-validation
<< "mips-string-struct" "resource:libfactor-ffi-test.so" absolute-path cdecl add-library >>
LIBRARY: mips-string-struct
STRUCT: string-bool-field { name c-string } { on bool } { parents short } ;
STRUCT: string-double-array { names c-string[2] } { values double[2] } ;
FUNCTION: short ffi_test_48 ( string-bool-field x )
: call-string-struct ( -- n ) string-bool-field <struct> 123 >>parents ffi_test_48 ;
{ ffi_test_48 call-string-struct } compile
c-string lookup-c-type double-offsets empty? [ ] [ "C string is not a double field" throw ] if
c-string lookup-c-type abi-members not [ ] [ "C string is not an FP return aggregate" throw ] if
string-bool-field lookup-c-type double-offsets empty? [ ] [ "string-only struct has no doubles" throw ] if
string-double-array lookup-c-type double-offsets
cpu mips32? { 8 16 } { 16 24 } ? = [ ] [ "nested array double offsets failed" throw ] if
call-string-struct 123 = [ ] [ "native string-field struct argument failed" throw ] if
"MIPS C-string fields, nested arrays and native struct FFI PASS" print flush
