! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel test parser-combinators lazy-lists fjsc ;
IN: temporary

{ "data_stack.push(123)" } [
  "123" 'number' parse car parse-result-parsed compile 
] unit-test

{ "fjsc_alert()" } [
  "alert" 'identifier' parse car parse-result-parsed compile 
] unit-test

{ "data_stack.push(123); fjsc_alert(); " } [
  "123 alert" 'expression' parse car parse-result-parsed compile 
] unit-test

{ "data_stack.push(123); data_stack.push('hello'); fjsc_alert(); " } [
  "123 \"hello\" alert" 'expression' parse car parse-result-parsed compile 
] unit-test
 