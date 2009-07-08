! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.inline alien.inline.private io.directories io.files
kernel namespaces tools.test alien.c-types ;
IN: alien.inline.tests

C-LIBRARY: test

C-FUNCTION: const-int add ( int a, int b )
    return a + b;
;

C-TYPEDEF: double bigfloat

C-FUNCTION: bigfloat smaller ( bigfloat a )
    return a / 10;
;

;C-LIBRARY

{ 2 1 } [ add ] must-infer-as
[ 5 ] [ 2 3 add ] unit-test

{ 1 1 } [ smaller ] must-infer-as
[ 1.0 ] [ 10 smaller ] unit-test

[ t ] [ "double" "bigfloat" [ resolve-typedef ] bi@ = ] unit-test

DELETE-C-LIBRARY: const


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

DELETE-C-LIBRARY: cpplib


C-LIBRARY: compile-error

C-FUNCTION: char* breakme ( )
    return not a string;
;

<< [ compile-c-library ] must-fail >>

DELETE-C-LIBRARY: compile-error
