IN: scratchpad
USE: hashtables
USE: namespaces
USE: oop
USE: stack
USE: test

TRAITS: test-traits

[ t ] [ <test-traits> test-traits? ] unit-test
[ f ] [ "hello" test-traits? ] unit-test
[ f ] [ <namespace> test-traits? ] unit-test

GENERIC: foo

M: test-traits foo drop 12 ;M

TRAITS: another-test

M: another-test foo drop 13 ;M

[ 12 ] [ <test-traits> foo ] unit-test
[ 13 ] [ <another-test> foo ] unit-test

TRAITS: quux

M: quux foo "foo" swap hash ;M

[
    "Hi"
] [
    <quux> [
        "Hi" "foo" set
    ] extend foo
] unit-test
