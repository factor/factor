! Copyright (C) 2005 Chris Double, 2007 Clemens Hofreither.
! See http://factorcode.org/license.txt for BSD license.
IN: temporary
USING: coroutines kernel sequences prettyprint tools.test math ;

: test1 ( -- co )
  [ drop 1 coyield* 2 coyield* 3 coterminate ] cocreate ;

: test2 ( -- co )
  [ 1+ coyield* ] cocreate ;

test1 dup *coresume . dup *coresume . dup *coresume . dup *coresume 2drop
[ test2 42 over coresume . dup *coresume . drop ] unit-test-fails
{ 43 } [ 42 test2 coresume ] unit-test

: test3 ( -- co )
  [ [ coyield* ] each ] cocreate ;

{ "c" "b" "a" } [ test3 { "a" "b" "c" } over coresume >r dup *coresume >r *coresume r> r> ] unit-test
