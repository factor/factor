! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel test parser-combinators lazy-lists fjsc ;
IN: temporary

{ "factor.data_stack.push(123)" } [
  "123" 'number' parse car parse-result-parsed fjsc-compile 
] unit-test

{ "factor.words[\"alert\"]()" } [
  "alert" 'identifier' parse car parse-result-parsed fjsc-compile 
] unit-test

{ "factor.data_stack.push(123); factor.words[\"alert\"](); " } [
  "123 alert" 'expression' parse car parse-result-parsed fjsc-compile 
] unit-test

{ "factor.data_stack.push(123); factor.data_stack.push('hello'); factor.words[\"alert\"](); " } [
  "123 \"hello\" alert" 'expression' parse car parse-result-parsed fjsc-compile 
] unit-test
 