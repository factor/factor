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

{ "factor.words[\"alert\"]();" } [
  "alert" 'identifier' parse car parse-result-parsed fjsc-compile 
] unit-test

{ "factor.data_stack.push(123);factor.words[\"alert\"]();" } [
  "123 alert" 'expression' parse car parse-result-parsed fjsc-compile 
] unit-test

{ "factor.data_stack.push(123);factor.data_stack.push('hello');factor.words[\"alert\"]();" } [
  "123 \"hello\" alert" 'expression' parse car parse-result-parsed fjsc-compile 
] unit-test
 
{ "factor.words[\"foo\"]=function() { factor.data_stack.push(123);factor.data_stack.push('hello')}" } [
  ": foo 123 \"hello\" ;" 'define' parse car parse-result-parsed fjsc-compile 
] unit-test

{ "factor.words[\"foo\"]=function() { factor.data_stack.push(123);factor.data_stack.push('hello')}" } [
  ": foo 123 \"hello\" ;" 'expression' parse car parse-result-parsed fjsc-compile 
] unit-test

