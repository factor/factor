! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences tools.test advice parser ;
IN: advice.tests

[
: foo "foo" ; 
\ foo make-advised
 
 { "bar" "foo" } [
     [ "bar" ] "barify" \ foo advise-before
     foo ] unit-test
 
 { "bar" "foo" "baz" } [
      [ "baz" ] "bazify" \ foo advise-after
      foo ] unit-test
 
 { "foo" "baz" } [
     "barify" \ foo before remove-advice
     foo ] unit-test
 
 ] with-interactive-vocabs