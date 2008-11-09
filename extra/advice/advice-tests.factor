! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math tools.test advice parser namespaces ;
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
 
: bar ( a -- b ) 1+ ;
\ bar make-advised

  { 11 } [
     [ 2 * ] "double" \ bar advise-before
     5 bar
  ] unit-test 

  { 11/3 } [
      [ 3 / ] "third" \ bar advise-after
      5 bar
  ] unit-test

  { -2 } [
      [ -1 * ad-do-it 3 + ] "frobnobicate" \ bar advise-around
      5 bar
  ] unit-test
 
 ] with-scope