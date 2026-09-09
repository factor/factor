USING: accessors alien alien.c-types alien.libraries alien.syntax
classes.struct io.pathnames kernel tools.test ;
FROM: alien.c-types => float ;
IN: windows-varargs.oracle
<< "windows-varargs-oracle" "resource:reference/arm64-varargs-outgoing-20260908/windows-oracle.dylib" absolute-path cdecl add-library >>
LIBRARY: windows-varargs-oracle
STRUCT: win-pair { x double } { y double } ;
STRUCT: win-hfa { x double } { y double } { z double } ;
STRUCT: win-small-hfa { x float } { y float } ;
FUNCTION: double win_varout_mixed ( float first, double second, int tag, ... int i, double d, longlong l, double e, int j, double f )
{ 285.0 } [ 1 2 3 4 5 6 7 8 9 win_varout_mixed ] unit-test
