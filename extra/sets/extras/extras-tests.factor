! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test sets.extras ;
IN: sets.extras.tests

{ { } }
[ { } { } setwise-xor ] unit-test

{ { 1 } }
[ { 1 } { } setwise-xor ] unit-test

{ { 1 } }
[ { } { 1 } setwise-xor ] unit-test

{ { } }
[ { 1 } { 1 } setwise-xor ] unit-test

{ { 1 4 5 7 } }
[ { 1 2 3 2 4 } { 2 3 5 7 5 } setwise-xor ] unit-test
