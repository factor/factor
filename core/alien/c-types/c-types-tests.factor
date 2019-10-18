IN: temporary
USING: alien alien.syntax alien.c-types kernel tools.test
sequences system libc ;

[ "\u00ff" ]
[ "\u00ff" string>char-alien alien>char-string ]
unit-test

[ "hello world" ]
[ "hello world" string>char-alien alien>char-string ]
unit-test

[ "hello\uabcdworld" ]
[ "hello\uabcdworld" string>u16-alien alien>u16-string ]
unit-test

[ t ] [ f expired? ] unit-test

[ "hello world" ] [
    "hello world" malloc-char-string
    dup alien>char-string swap free
] unit-test

[ "hello world" ] [
    "hello world" malloc-u16-string
    dup alien>u16-string swap free
] unit-test

: foo ( -- n ) "fdafd" f dlsym [ 123 ] unless* ;

[ 123 ] [ foo ] unit-test

[ -1 ] [ -1 <char> *char ] unit-test
[ -1 ] [ -1 <short> *short ] unit-test
[ -1 ] [ -1 <int> *int ] unit-test

C-UNION: foo
    "int"
    "int" ;

[ f ] [ "char*" c-type "void*" c-type eq? ] unit-test
[ t ] [ "char**" c-type "void*" c-type eq? ] unit-test

[ t ] [ "foo" heap-size "int" heap-size = ] unit-test

TYPEDEF: int MyInt

[ t ] [ "int" c-type "MyInt" c-type eq? ] unit-test
[ t ] [ "void*" c-type "MyInt*" c-type eq? ] unit-test

TYPEDEF: char MyChar

[ t ] [ "char" c-type "MyChar" c-type eq? ] unit-test
[ f ] [ "void*" c-type "MyChar*" c-type eq? ] unit-test
[ t ] [ "char*" c-type "MyChar*" c-type eq? ] unit-test

[ 32 ] [ { "int" 8 } heap-size ] unit-test

TYPEDEF: char* MyString

[ t ] [ "char*" c-type "MyString" c-type eq? ] unit-test
[ t ] [ "void*" c-type "MyString*" c-type eq? ] unit-test

TYPEDEF: int* MyIntArray

[ t ] [ "void*" c-type "MyIntArray" c-type eq? ] unit-test

TYPEDEF: uchar* MyLPBYTE

[ t ] [ "char*" c-type "MyLPBYTE" c-type eq? ] unit-test

[
    0 B{ 1 2 3 4 } <displaced-alien> <void*>
] unit-test-fails
