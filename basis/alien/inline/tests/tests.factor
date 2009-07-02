! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test alien.inline alien.inline.private io.files io.directories kernel ;
IN: alien.inline.tests

C-LIBRARY: const

C-FUNCTION: const-int add ( int a, int b )
    return a + b;
;

;C-LIBRARY

{ 2 1 } [ add ] must-infer-as
[ 5 ] [ 2 3 add ] unit-test

<< library-path dup exists? [ delete-file ] [ drop ] if >>


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

<< library-path dup exists? [ delete-file ] [ drop ] if >>


C-LIBRARY: compile-error

C-FUNCTION: char* breakme ( )
    return not a string;
;

<< [ (;C-LIBRARY) ] must-fail >>

<< library-path dup exists? [ delete-file ] [ drop ] if >>
