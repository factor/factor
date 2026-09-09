USING: accessors alien alien.c-types alien.libraries alien.syntax classes.struct
kernel math.vectors.simd tools.test ;
IN: varargs-alignment.oracle
<< "alignment-oracle" "/Users/erg/factor.worktrees/arm64-varargs-outgoing/reference/arm64-varargs-alignment-20260908/probe.dylib" cdecl add-library >>
LIBRARY: alignment-oracle
STRUCT: align-prior { a longlong } { b longlong } { c longlong } ;
STRUCT: align-hva { a float-4 } { b float-4 } ;
FUNCTION: ulonglong align_named ( align-prior p, align-hva h, int tag, ... )
{ 0 } [ 1 2 3 align-prior boa float-4{ 1 2 3 4 } float-4{ 5 6 7 8 } align-hva boa 1 align_named ] unit-test
: indirect-alignment ( p h tag ptr -- n )
    ulonglong { align-prior align-hva int } cdecl 3 alien-indirect-varargs ;
{ 0 } [ 1 2 3 align-prior boa float-4{ 1 2 3 4 } float-4{ 5 6 7 8 } align-hva boa 1 "align_named" "alignment-oracle" library-dll dlsym indirect-alignment ] unit-test

STRUCT: align-result { alignment ulonglong } { value float-4 } ;
FUNCTION: align-result align_return ( align-prior p, int tag, ... )
{ 0 } [ 1 2 3 align-prior boa 1 align_return alignment>> ] unit-test
