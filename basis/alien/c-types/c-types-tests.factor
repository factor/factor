USING: alien alien.syntax alien.c-types alien.parser
eval kernel tools.test sequences system libc alien.strings
io.encodings.utf8 math.constants classes.struct classes ;
IN: alien.c-types.tests

CONSTANT: xyz 123

[ 492 ] [ { int xyz } heap-size ] unit-test

[ -1 ] [ -1 <char> *char ] unit-test
[ -1 ] [ -1 <short> *short ] unit-test
[ -1 ] [ -1 <int> *int ] unit-test

UNION-STRUCT: foo
    { a int }
    { b int } ;

[ f ] [ char  resolve-pointer-type c-type void* c-type eq? ] unit-test
[ t ] [ char* resolve-pointer-type c-type void* c-type eq? ] unit-test

[ t ] [ foo heap-size int heap-size = ] unit-test

TYPEDEF: int MyInt

[ t ] [ int   c-type MyInt                      c-type eq? ] unit-test
[ t ] [ void* c-type MyInt resolve-pointer-type c-type eq? ] unit-test

TYPEDEF: char MyChar

[ t ] [ char  c-type MyChar                      c-type eq? ] unit-test
[ f ] [ void* c-type MyChar resolve-pointer-type c-type eq? ] unit-test
[ t ] [ char* c-type MyChar resolve-pointer-type c-type eq? ] unit-test

[ 32 ] [ { int 8 } heap-size ] unit-test

TYPEDEF: char* MyString

[ t ] [ char* c-type MyString                      c-type eq? ] unit-test
[ t ] [ void* c-type MyString resolve-pointer-type c-type eq? ] unit-test

TYPEDEF: int* MyIntArray

[ t ] [ void* c-type MyIntArray c-type eq? ] unit-test

TYPEDEF: uchar* MyLPBYTE

[ t ] [ { char* utf8 } c-type MyLPBYTE c-type = ] unit-test

[
    0 B{ 1 2 3 4 } <displaced-alien> <void*>
] must-fail

os windows? cpu x86.64? and [
    [ -2147467259 ] [ 2147500037 <long> *long ] unit-test
] when

[ 0 ] [ -10 uchar c-type-clamp ] unit-test
[ 12 ] [ 12 uchar c-type-clamp ] unit-test
[ -10 ] [ -10 char c-type-clamp ] unit-test
[ 127 ] [ 230 char c-type-clamp ] unit-test
[ t ] [ pi dup float c-type-clamp = ] unit-test

C-TYPE: opaque

[ t ] [ void* c-type opaque resolve-pointer-type c-type eq? ] unit-test
[ opaque c-type ] [ no-c-type? ] must-fail-with

[ """
    USING: alien.syntax ;
    IN: alien.c-types.tests
    FUNCTION: opaque return_opaque ( ) ;
""" eval( -- ) ] [ no-c-type? ] must-fail-with

C-TYPE: forward
STRUCT: backward { x forward* } ;
STRUCT: forward { x backward* } ;

[ t ] [ forward c-type struct-c-type? ] unit-test
[ t ] [ backward c-type struct-c-type? ] unit-test

DEFER: struct-redefined

[ f ]
[

    """
    USING: alien.c-types classes.struct ;
    IN: alien.c-types.tests

    STRUCT: struct-redefined { x int } ;
    """ eval( -- )

    """
    USING: alien.syntax ;
    IN: alien.c-types.tests

    C-TYPE: struct-redefined
    """ eval( -- )

    \ struct-redefined class?
] unit-test

