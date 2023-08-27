! Copyright (C) 2015 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: changer math tools.test ;
IN: changer.tests

TUPLE: changer-tester test-slot ;

{
    T{ changer-tester f 1 }
} [ T{ changer-tester f 0 } [ 1 + ] change: test-slot ] unit-test

: change-test-slot ( obj -- obj )
    [ 1 + ] change: test-slot ;

{
    T{ changer-tester f 1 }
} [ T{ changer-tester f 0 } change-test-slot ] unit-test
