USING: alien alien.syntax alien.c-types alien.parser
eval kernel tools.test sequences system libc alien.strings
io.encodings.ascii io.encodings.utf8 math.constants classes.struct classes
accessors compiler.units ;
FROM: alien.c-types => short ;
IN: alien.c-types.tests

CONSTANT: xyz 123

[ 492 ] [ { int xyz } heap-size ] unit-test

UNION-STRUCT: foo
    { a int }
    { b int } ;

[ t ] [ pointer: void c-type void* c-type = ] unit-test
[ t ] [ pointer: int  c-type void* c-type = ] unit-test
[ t ] [ pointer: int* c-type void* c-type = ] unit-test
[ f ] [ pointer: foo  c-type void* c-type = ] unit-test
[ t ] [ pointer: foo* c-type void* c-type = ] unit-test

[ t ] [ c-string c-type c-string c-type = ] unit-test

[ t ] [ foo heap-size int heap-size = ] unit-test

TYPEDEF: int MyInt

[ t ] [ int   c-type          MyInt c-type = ] unit-test
[ t ] [ void* c-type pointer: MyInt c-type = ] unit-test

[ 32 ] [ { int 8 } heap-size ] unit-test

[ ] [ pointer: { int 8 } heap-size pointer: void heap-size assert= ] unit-test

TYPEDEF: char MyChar

[ t ] [ pointer: void c-type pointer: MyChar c-type = ] unit-test

TYPEDEF: { c-string ascii } MyFunkyString

[ { c-string ascii } ] [ MyFunkyString c-type ] unit-test

TYPEDEF: c-string MyString

[ t ] [ c-string c-type MyString          c-type = ] unit-test
[ t ] [ void* c-type pointer: MyString c-type = ] unit-test

TYPEDEF: int* MyIntArray

[ t ] [ void* c-type MyIntArray c-type = ] unit-test

[ 0 ] [ -10 uchar c-type-clamp ] unit-test
[ 12 ] [ 12 uchar c-type-clamp ] unit-test
[ -10 ] [ -10 char c-type-clamp ] unit-test
[ 127 ] [ 230 char c-type-clamp ] unit-test
[ t ] [ pi dup float c-type-clamp = ] unit-test

C-TYPE: opaque

[ t ] [ void* c-type pointer: opaque c-type = ] unit-test
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

[
    "IN: alien.c-types.tests
    USE: alien.syntax
    USE: alien.c-types
    TYPEDEF: int type-redefinition-test
    TYPEDEF: int type-redefinition-test" eval( -- )
]
[ error>> error>> redefine-error? ]
must-fail-with
