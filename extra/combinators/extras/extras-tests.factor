! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test combinators.extras sequences ;
IN: combinators.extras.tests

{ "a b" }
[ "a" "b" [ " " glue ] once ] unit-test

{ "a b c" }
[ "a" "b" "c" [ " " glue ] twice ] unit-test

{ "a b c d" }
[ "a" "b" "c" "d" [ " " glue ] thrice ] unit-test
