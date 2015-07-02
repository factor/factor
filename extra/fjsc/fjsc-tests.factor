! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test peg fjsc ;
IN: fjsc.tests

{ T{ ast-expression f V{ T{ ast-number f 55 } T{ ast-identifier f "2abc1" } T{ ast-number f 100 } } } } [
  "55 2abc1 100" 'expression' parse
] unit-test

{ T{ ast-quotation f V{ T{ ast-number f 55 } T{ ast-identifier f "2abc1" } T{ ast-number f 100 } } } } [
  "[ 55 2abc1 100 ]" 'quotation' parse
] unit-test

{ T{ ast-array f V{ T{ ast-number f 55 } T{ ast-identifier f "2abc1" } T{ ast-number f 100 } } } } [
  "{ 55 2abc1 100 }" 'array' parse
] unit-test

{ T{ ast-stack-effect f V{ } V{ "d" "e" "f" } } } [
  "( -- d e f )" 'stack-effect' parse
] unit-test

{ T{ ast-stack-effect f V{ "a" "b" "c" } V{ "d" "e" "f" } } } [
  "( a b c -- d e f )" 'stack-effect' parse
] unit-test

{ T{ ast-stack-effect f V{ "a" "b" "c" } V{ } } } [
  "( a b c -- )" 'stack-effect' parse
] unit-test

{ T{ ast-stack-effect f V{ } V{ } } } [
  "( -- )" 'stack-effect' parse
] unit-test

{ f } [
  ": foo ( a b -- c d ) abcdefghijklmn 123 ;" 'expression' parse not
] unit-test


{ T{ ast-expression f V{ T{ ast-string f "abcd" } } } } [
  "\"abcd\"" 'statement' parse
] unit-test

{ T{ ast-expression f V{ T{ ast-use f "foo" } } } } [
  "USE: foo" 'statement' parse
] unit-test

{ T{ ast-expression f V{ T{ ast-in f "foo" } } } } [
  "IN: foo" 'statement' parse
] unit-test

{ T{ ast-expression f V{ T{ ast-using f V{ "foo" "bar" }  } } } } [
  "USING: foo bar ;" 'statement' parse
] unit-test
