IN: scratchpad
USE: test
USE: namespaces
USE: oop
USE: stack

TRAITS: test-traits

[ t ] [ <test-traits> test-traits? ] unit-test
[ f ] [ "hello" test-traits? ] unit-test
[ f ] [ <namespace> test-traits? ] unit-test

GENERIC: foo

M: test-traits foo 12 ;M

TRAITS: another-test

M: another-test foo 13 ;M

[ 12 ] [ <test-traits> foo ] unit-test
[ 13 ] [ <another-test> foo ] unit-test
