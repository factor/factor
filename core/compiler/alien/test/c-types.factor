IN: temporary
USING: alien kernel test sequences ;

C-UNION: foo
    int
    int ;

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

C-STRUCT: bar
    { "int" "x" }
    { { "int" 8 } "y" } ;

[ 36 ] [ "bar" heap-size ] unit-test
[ t ] [ \ <displaced-alien> "bar" c-type c-type-getter memq? ] unit-test

TYPEDEF: char* MyString

[ t ] [ "char*" c-type "MyString" c-type eq? ] unit-test
[ t ] [ "void*" c-type "MyString*" c-type eq? ] unit-test

TYPEDEF: int* MyIntArray

[ t ] [ "void*" c-type "MyIntArray" c-type eq? ] unit-test

TYPEDEF: uchar* MyLPBYTE

[ t ] [ "char*" c-type "MyLPBYTE" c-type eq? ] unit-test

C-STRUCT: align-test
    { "int" "x" }
    { "double" "y" } ;

[ 16 ] [ "align-test" heap-size ] unit-test

cell 4 = [
    C-STRUCT: one
    { "long" "a" } { "double" "b" } { "int" "c" } ;

    [ 24 ] [ "one" heap-size ] unit-test
] when
