USING: accessors alien alien.accessors alien.c-types alien.libraries alien.syntax alien.varargs alien.varargs.private classes.struct
compiler.tests.alien-varargs-outgoing continuations kernel libc locals math math.vectors.simd sequences system tools.test ;
IN: compiler.tests.alien-varargs-outgoing
LIBRARY: varargs-outgoing
STRUCT: align-prior { a longlong } { b longlong } { c longlong } ;
STRUCT: align-hva { a float-4 } { b float-4 } ;
FUNCTION: ulonglong varout_hva_alignment ( align-prior p, align-hva h, int tag, ... )
{ 0 } [ 1 2 3 align-prior boa float-4{ 1 2 3 4 } float-4{ 5 6 7 8 } align-hva boa 1 varout_hva_alignment ] unit-test
: indirect-alignment ( p h tag ptr -- n )
    ulonglong { align-prior align-hva int } cdecl 3 alien-indirect-varargs ;
{ 0 } [ 1 2 3 align-prior boa float-4{ 1 2 3 4 } float-4{ 5 6 7 8 } align-hva boa 1 "varout_hva_alignment" "varargs-outgoing" library-dll dlsym indirect-alignment ] unit-test

STRUCT: align-result { alignment ulonglong } { value float-4 } ;
FUNCTION: align-result varout_return_alignment ( align-prior p, int tag, ... )
{ 0 } [ 1 2 3 align-prior boa 1 varout_return_alignment alignment>> ] unit-test

STRUCT: align-vector-first { value float-4 } { tail ulonglong } ;
UNION-STRUCT: align-vector-union { value float-4 } { integer longlong } ;
FUNCTION: ulonglong varout_vector_first_size ( )
FUNCTION: ulonglong varout_vector_first_align ( )
FUNCTION: ulonglong varout_vector_union_align ( )
FUNCTION: double varout_vector_first_after_int ( int tag, ... int prefix, align-vector-first value )
FUNCTION: double varout_vector_union_after_int ( int tag, ... int prefix, align-vector-union value, double tail )
{ t } [ align-vector-first heap-size varout_vector_first_size = ] unit-test
{ t } [ align-vector-first c-type-align varout_vector_first_align = ] unit-test
{ t } [ align-vector-union c-type-align varout_vector_union_align = ] unit-test
{ 36.0 } [ 1 2 float-4{ 1 2 3 4 } 3 align-vector-first boa varout_vector_first_after_int ] unit-test
{ 36.0 } [ 1 2 align-vector-union <struct> float-4{ 1 2 3 4 } >>value 3 varout_vector_union_after_int ] unit-test
! The preceding promoted int occupies eight bytes; the union starts at 16.
{ 2 30.0 } [ [let
    64 malloc :> mem
    [
        [
            2 mem 0 set-alien-signed-4
            1.0 mem 16 set-alien-float 2.0 mem 20 set-alien-float
            3.0 mem 24 set-alien-float 4.0 mem 28 set-alien-float
            mem f f 0 0 macos <platform-va-cursor> :> cursor
            cursor int va-arg
            cursor align-vector-union va-arg value>>
            { 1 2 3 4 } [ * ] 2map sum
        ] with-va-scope
    ] [ mem free ] finally
] ] unit-test
