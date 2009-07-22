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

CM-FUNCTION: std::string* new_string ( const-char* s )
    return new std::string(s);
;

;C-LIBRARY

{ 1 1 } [ new_string ] must-infer-as
