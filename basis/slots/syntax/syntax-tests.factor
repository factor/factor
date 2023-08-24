! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel tools.test slots.syntax ;
IN: slots.syntax.tests

TUPLE: slot-test1 a b c ;

{ 1 2 3 } [ T{ slot-test1 f 1 2 3 } slots[ a b c ] ] unit-test
{ 3 } [ T{ slot-test1 f 1 2 3 } slots[ c ] ] unit-test
{ } [ T{ slot-test1 f 1 2 3 } slots[ ] ] unit-test

{ { 1 2 3 } } [ T{ slot-test1 f 1 2 3 } slots{ a b c } ] unit-test
{ { 3 } } [ T{ slot-test1 f 1 2 3 } slots{ c } ] unit-test
{ { } } [ T{ slot-test1 f 1 2 3 } slots{ } ] unit-test

TUPLE: slot-test2 a b c d ;

{ T{ slot-test2 f 1 2 33 44 } }
[ 1 2 3 slot-test1 boa 11 22 33 44 slot-test2 boa copy-slots{ a b } ] unit-test
