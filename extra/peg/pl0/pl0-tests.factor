! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.pl0 ;
IN: temporary

{ "abc" } [
  "abc" 'ident' parse parse-result-ast 
] unit-test

{ 55 } [
  "55abc" 'number' parse parse-result-ast 
] unit-test
