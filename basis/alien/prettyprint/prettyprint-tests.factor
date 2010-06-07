USING: alien.c-types alien.prettyprint alien.syntax
io.streams.string see tools.test prettyprint ;
IN: alien.prettyprint.tests

CONSTANT: FOO 10

FUNCTION: int function_test ( float x, int[4][FOO] y, char* z, ushort *w ) ;

[ "USING: alien.c-types alien.syntax ;
IN: alien.prettyprint.tests
FUNCTION: int function_test
    ( float x, int[4][FOO] y, char* z, ushort* w ) ;
" ] [
    [ \ function_test see ] with-string-writer
] unit-test

FUNCTION-ALIAS: function-test int function_test
    ( float x, int[4][FOO] y, char* z, ushort *w ) ;

[ "USING: alien.c-types alien.syntax ;
IN: alien.prettyprint.tests
FUNCTION-ALIAS: function-test int function_test
    ( float x, int[4][FOO] y, char* z, ushort* w ) ;
" ] [
    [ \ function-test see ] with-string-writer
] unit-test

C-TYPE: opaque-c-type

[ "USING: alien.syntax ;
IN: alien.prettyprint.tests
C-TYPE: opaque-c-type
" ] [
    [ \ opaque-c-type see ] with-string-writer
] unit-test

TYPEDEF: pointer: int pint

[ "USING: alien.c-types alien.syntax ;
IN: alien.prettyprint.tests
TYPEDEF: int* pint
" ] [
    [ \ pint see ] with-string-writer
] unit-test

[ "pointer: int" ] [ pointer: int unparse ] unit-test

CALLBACK: void callback-test ( int x, float[4] y ) ;

[ "USING: alien.c-types alien.syntax ;
IN: alien.prettyprint.tests
CALLBACK: void callback-test ( int x, float[4] y ) ;
" ] [
    [ \ callback-test see ] with-string-writer
] unit-test
