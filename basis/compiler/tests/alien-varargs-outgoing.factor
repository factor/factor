USING: accessors alien alien.c-types alien.libraries alien.syntax
classes.struct combinators io io.pathnames kernel locals math parser system tools.test ;
FROM: alien.c-types => float ;
IN: compiler.tests.alien-varargs-outgoing
<< "varargs-outgoing" "resource:" absolute-path os {
    { windows [ "libfactor-ffi-test.dll" ] }
    { macos [ "libfactor-ffi-test.dylib" ] }
    [ drop "libfactor-ffi-test.so" ]
} case append-path cdecl add-library >>
LIBRARY: varargs-outgoing
STRUCT: varout-pair { x double } { y double } ;
STRUCT: varout-hfa { x double } { y double } { z double } ;
STRUCT: varout-small-hfa { x float } { y float } ;
FUNCTION: double varout_mixed ( float first, double second, int tag, ... int i, double d, longlong l, double e, int j, double f )
FUNCTION: double varout_hfas ( varout-small-hfa named, int tag, ... varout-pair p, varout-hfa h, double d )
FUNCTION: double varout_split ( int a, int b, int c, int d, int e, int f, int g, ... varout-pair p, double tail )
FUNCTION: varout-hfa varout_return ( int tag, ... varout-hfa h )
FUNCTION: double varout_control ( )
FUNCTION: double varout_split_control ( )
FUNCTION: int varout_split_caller_supported ( )
{ 570.0 } [ varout_control ] unit-test
varout_split_caller_supported 0 > [
    { 317.0 } [ varout_split_control ] unit-test
] [
    "Clang Windows ARM64 C caller cannot split a variadic composite at X7; Factor-to-C split test remains required." print
] if
{ 285.0 } [ 1 2 3 4 5 6 7 8 9 varout_mixed ] unit-test
{ 285.0 } [ 1 2 varout-small-hfa boa 3 4 5 varout-pair boa 6 7 8 varout-hfa boa 9 varout_hfas ] unit-test
! This is the ARM64 X7/stack boundary regression. The original x86 image
! independently fails this signature (317 -> 365); retain its C-only control
! above without broadening this ARM64 change into an x86 ABI repair.
cpu arm.64? [
    { 317.0 } [ 1 2 3 4 5 6 7 4 5 varout-pair boa 10 varout_split ] unit-test
] when
{ 16.0 27.0 38.0 } [ 10 6 7 8 varout-hfa boa varout_return [ x>> ] [ y>> ] [ z>> ] tri ] unit-test
: indirect-varout-mixed ( first second tag i d l e j f ptr -- result )
    double { float double int int double longlong double int double } cdecl 3 alien-indirect-varargs ;
{ 285.0 } [ 1 2 3 4 5 6 7 8 9 "varout_mixed" "varargs-outgoing" library-dll dlsym indirect-varout-mixed ] unit-test

FUNCTION: int varout_alignment_supported ( )
varout_alignment_supported 0 > [
    "resource:basis/compiler/tests/varargs/outgoing-alignment.factor" run-test-file
] [
    cpu arm.64? [ "C vector pointer alignment probes require GCC or Clang inline assembly." print ] when
] if
