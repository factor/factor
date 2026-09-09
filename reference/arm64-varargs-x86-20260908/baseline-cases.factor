! Original image lacks the new ellipsis parser; use its existing FFI primitive.
USING: alien alien.c-types alien.libraries alien.syntax classes.struct
io.pathnames kernel tools.test ;
IN: x86-varargs.baseline
<< "baseline-varargs" "resource:libfactor-ffi-test.dylib" absolute-path cdecl add-library >>
LIBRARY: baseline-varargs
STRUCT: baseline-pair { x double } { y double } ;
FUNCTION: double varout_split_control ( )
: baseline-split ( a b c d e f g p tail -- n )
    double "baseline-varargs" "varout_split"
    { int int int int int int int baseline-pair double } t alien-invoke ;
{ 317.0 } [ varout_split_control ] unit-test
{ 317.0 } [ 1 2 3 4 5 6 7 4 5 baseline-pair boa 10 baseline-split ] unit-test
