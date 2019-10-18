! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test slots.syntax ;
IN: slots.syntax.tests

TUPLE: slot-test a b c ;

[ 1 2 3 ] [ T{ slot-test f 1 2 3 } slots[ a b c ] ] unit-test
[ 3 ] [ T{ slot-test f 1 2 3 } slots[ c ] ] unit-test
[ ] [ T{ slot-test f 1 2 3 } slots[ ] ] unit-test

[ { 1 2 3 } ] [ T{ slot-test f 1 2 3 } slots{ a b c } ] unit-test
[ { 3 } ] [ T{ slot-test f 1 2 3 } slots{ c } ] unit-test
[ { } ] [ T{ slot-test f 1 2 3 } slots{ } ] unit-test
