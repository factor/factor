USING: accessors alien alien.c-types alien.libraries alien.syntax
classes.struct combinators kernel tools.test windows-varargs.oracle ;
IN: windows-varargs.oracle
LIBRARY: windows-varargs-oracle
FUNCTION: double win_varout_hfas ( win-small-hfa named, int tag, ... win-pair p, win-hfa h, double d )
FUNCTION: double win_varout_split ( int a, int b, int c, int d, int e, int f, int g, ... win-pair p, double tail )
FUNCTION: win-hfa win_varout_return ( int tag, ... win-hfa h )
{ 285.0 } [ 1 2 win-small-hfa boa 3 4 5 win-pair boa 6 7 8 win-hfa boa 9 win_varout_hfas ] unit-test
{ 317.0 } [ 1 2 3 4 5 6 7 4 5 win-pair boa 10 win_varout_split ] unit-test
{ 16.0 27.0 38.0 } [ 10 6 7 8 win-hfa boa win_varout_return [ x>> ] [ y>> ] [ z>> ] tri ] unit-test
: indirect-win-mixed ( first second tag i d l e j f ptr -- result )
    double { float double int int double longlong double int double } cdecl 3 alien-indirect-varargs ;
{ 285.0 } [ 1 2 3 4 5 6 7 8 9 "win_varout_mixed" "windows-varargs-oracle" library-dll dlsym indirect-win-mixed ] unit-test

USING: math.floats.small.c-types math.vectors.simd ;
FUNCTION: ulonglong win_varout_half_bits ( half named, int count, ... half a, half b, half c, half d, half e, half f, half g, half h )
FUNCTION: ulonglong win_varout_bfloat_bits ( bfloat named, int count, ... bfloat a, bfloat b, bfloat c, bfloat d, bfloat e, bfloat f, bfloat g, bfloat h )
{ 806016 } [ 1 8 2 3 4 5 6 7 8 9 win_varout_half_bits ] unit-test
{ 745872 } [ 1 8 2 3 4 5 6 7 8 9 win_varout_bfloat_bits ] unit-test
STRUCT: win-hva { a float-4 } { b float-4 } ;
FUNCTION: double win_varout_vector_args ( int tag, ... float-4 a, win-hva h, double tail )
{ 212.0 } [
    1 float-4{ 1 2 3 4 }
    float-4{ 5 6 7 8 } float-4{ 9 10 11 12 } win-hva boa 1
    win_varout_vector_args
] unit-test
