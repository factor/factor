! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel test parser-combinators lazy-lists fjsc ;
IN: temporary

{ T{ ast-expression f { T{ ast-number f 55 } T{ ast-identifier f "2abc1" } T{ ast-number f 100 } } } } [
  "55 2abc1 100" 'expression' parse car parse-result-parsed
] unit-test

{ T{ ast-quotation f T{ ast-expression f { T{ ast-number f 55 } T{ ast-identifier f "2abc1" } T{ ast-number f 100 } } } } } [
  "[ 55 2abc1 100 ]" 'quotation' parse car parse-result-parsed
] unit-test

{ T{ ast-array f T{ ast-expression f { T{ ast-number f 55 } T{ ast-identifier f "2abc1" } T{ ast-number f 100 } } } } } [
  "{ 55 2abc1 100 }" 'array' parse car parse-result-parsed
] unit-test

{ T{ ast-stack-effect f { } { "d" "e" "f" } } } [
  "( -- d e f )" 'stack-effect' parse car parse-result-parsed 
] unit-test

{ T{ ast-stack-effect f { "a" "b" "c" } { "d" "e" "f" } } } [
  "( a b c -- d e f )" 'stack-effect' parse car parse-result-parsed 
] unit-test

{ T{ ast-stack-effect f { "a" "b" "c" } { } } } [
  "( a b c -- )" 'stack-effect' parse car parse-result-parsed 
] unit-test

{ T{ ast-stack-effect f { } { } } } [
  "( -- )" 'stack-effect' parse car parse-result-parsed 
] unit-test

{ } [
  ": foo ( a b -- c d ) abcdefghijklmn 123 ;" 'expression' parse car drop
] unit-test