! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.cxx alien.cxx.parser ;
IN: alien.cxx.syntax

SYNTAX: C++-CLASS:
    parse-c++-class-definition define-c++-class ;

SYNTAX: C++-METHOD:
    parse-c++-method-definition f define-c++-method ;

SYNTAX: C++-VIRTUAL:
    parse-c++-method-definition t define-c++-method ;
