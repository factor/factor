! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.inline alien.inline.syntax io.directories io.files
kernel namespaces tools.test alien.c-types alien.data alien.structs ;
IN: alien.inline.syntax.tests

DELETE-C-LIBRARY: test
C-LIBRARY: test

C-FUNCTION: const-int add ( int a, int b )
    return a + b;
;

C-TYPEDEF: double bigfloat

C-FUNCTION: bigfloat smaller ( bigfloat a )
    return a / 10;
;

C-STRUCTURE: rectangle
    { "int" "width" }
    { "int" "height" } ;

C-FUNCTION: int area ( rectangle c )
    return c.width * c.height;
;

;C-LIBRARY

{ 2 1 } [ add ] must-infer-as
[ 5 ] [ 2 3 add ] unit-test

[ t ] [ "double" "bigfloat" [ resolve-typedef ] same? ] unit-test
{ 1 1 } [ smaller ] must-infer-as
[ 1.0 ] [ 10 smaller ] unit-test

[ t ] [ "rectangle" resolve-typedef struct-type? ] unit-test
{ 1 1 } [ area ] must-infer-as
[ 20 ] [
    "rectangle" <c-object>
    4 over set-rectangle-width
    5 over set-rectangle-height
    area
] unit-test


DELETE-C-LIBRARY: cpplib
C-LIBRARY: cpplib

COMPILE-AS-C++

C-INCLUDE: <string>

C-FUNCTION: const-char* hello ( )
    std::string s("hello world");
    return s.c_str();
;

;C-LIBRARY

{ 0 1 } [ hello ] must-infer-as
[ "hello world" ] [ hello ] unit-test


DELETE-C-LIBRARY: compile-error
C-LIBRARY: compile-error

C-FUNCTION: char* breakme ( )
    return not a string;
;

<< [ compile-c-library ] must-fail >>
