! Copyright (C) 2005 Chris Double, 2007 Clemens Hofreither, 2008 James Cash.
! See https://factorcode.org/license.txt for BSD license.
IN: coroutines.tests
USING: coroutines kernel sequences prettyprint tools.test math ;

: test1 ( -- co )
  [ drop 1 coyield* 2 coyield* 3 coterminate ] cocreate ;

: test2 ( -- co )
  [ 1 + coyield* ] cocreate ;

test1 dup *coresume . dup *coresume . dup *coresume . dup *coresume 2drop
[ test2 42 over coresume . dup *coresume . drop ] must-fail
{ 43 } [ 42 test2 coresume ] unit-test

: test3 ( -- co )
  [ [ coyield* ] each ] cocreate ;

{ "c" "b" "a" } [ test3 { "a" "b" "c" } over coresume [ dup *coresume [ *coresume ] dip ] dip ] unit-test

{ 4+2/3 } [ [ 1 + coyield 2 * coyield 3 / coreset ] cocreate 1 5 [ over coresume ] times nip ] unit-test
