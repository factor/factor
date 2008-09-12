! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel math math.parser arrays tools.test peg peg.parsers
peg.search ;
IN: peg.search.tests

{ V{ 123 456 } } [
  "abc 123 def 456" 'integer' search
] unit-test

{ V{ 123 "hello" 456 } } [
  "one 123 \"hello\" two 456" 'integer' 'string' 2array choice search
] unit-test

{ "abc 246 def 912" } [
  "abc 123 def 456" 'integer' [ 2 * number>string ] action replace
] unit-test

