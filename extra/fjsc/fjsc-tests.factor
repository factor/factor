! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel tools.test peg fjsc ;

{ T{ ast-expression f V{ T{ ast-number f 55 } T{ ast-identifier f "2abc1" } T{ ast-number f 100 } } } } [
  "55 2abc1 100" expression-parser parse
] unit-test

{ T{ ast-quotation f V{ T{ ast-number f 55 } T{ ast-identifier f "2abc1" } T{ ast-number f 100 } } } } [
  "[ 55 2abc1 100 ]" quotation-parser parse
] unit-test

{ T{ ast-array f V{ T{ ast-number f 55 } T{ ast-identifier f "2abc1" } T{ ast-number f 100 } } } } [
  "{ 55 2abc1 100 }" array-parser parse
] unit-test

{ T{ ast-stack-effect f V{ } V{ "d" "e" "f" } } } [
  "( -- d e f )" stack-effect-parser parse
] unit-test

{ T{ ast-stack-effect f V{ "a" "b" "c" } V{ "d" "e" "f" } } } [
  "( a b c -- d e f )" stack-effect-parser parse
] unit-test

{ T{ ast-stack-effect f V{ "a" "b" "c" } V{ } } } [
  "( a b c -- )" stack-effect-parser parse
] unit-test

{ T{ ast-stack-effect f V{ } V{ } } } [
  "( -- )" stack-effect-parser parse
] unit-test

{ f } [
  ": foo ( a b -- c d ) abcdefghijklmn 123 ;" expression-parser parse not
] unit-test


{ T{ ast-expression f V{ T{ ast-string f "abcd" } } } } [
  "\"abcd\"" statement-parser parse
] unit-test

{ T{ ast-expression f V{ T{ ast-use f "foo" } } } } [
  "USE: foo" statement-parser parse
] unit-test

{ T{ ast-expression f V{ T{ ast-in f "foo" } } } } [
  "IN: foo" statement-parser parse
] unit-test

{ T{ ast-expression f V{ T{ ast-using f V{ "foo" "bar" }  } } } } [
  "USING: foo bar ;" statement-parser parse
] unit-test
