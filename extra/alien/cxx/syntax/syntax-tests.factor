! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test alien.cxx.syntax alien.inline.syntax
alien.marshall.syntax alien.marshall ;
IN: alien.cxx.syntax.tests

DELETE-C-LIBRARY: test
C-LIBRARY: test

COMPILE-AS-C++

C-INCLUDE: <string>

C-TYPEDEF: std::string string

C++-CLASS: std::string c++-root

C++-METHOD: std::string const-char* c_str ( )

CM-FUNCTION: std::string* new_string ( const-char* s )
    return new std::string(s);
;

;C-LIBRARY

ALIAS: <std::string> new_string

ALIAS: to-string c_str

{ 1 1 } [ new_string ] must-infer-as
{ 1 1 } [ c_str ] must-infer-as
[ "abc" ] [ "abc" <std::string> to-string ] unit-test
