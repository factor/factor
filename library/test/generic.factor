IN: scratchpad
USE: hashtables
USE: namespaces
USE: generic
USE: test
USE: kernel

TRAITS: test-traits
C: test-traits ;C

[ t ] [ <test-traits> test-traits? ] unit-test
[ f ] [ "hello" test-traits? ] unit-test
[ f ] [ <namespace> test-traits? ] unit-test

GENERIC: foo

M: test-traits foo drop 12 ;M

TRAITS: another-test
C: another-test ;C

M: another-test foo drop 13 ;M

[ 12 ] [ <test-traits> foo ] unit-test
[ 13 ] [ <another-test> foo ] unit-test

TRAITS: quux
C: quux ;C

M: quux foo "foo" swap hash ;M

[
    "Hi"
] [
    <quux> [
        "Hi" "foo" set
    ] extend foo
] unit-test

TRAITS: ctr-test
C: ctr-test [ 5 "x" set ] extend ;C

[
    5
] [
    <ctr-test> [ "x" get ] bind
] unit-test

TRAITS: del1
C: del1 ;C

GENERIC: super
M: del1 super drop 5 ;M

TRAITS: del2
C: del2 ( delegate -- del2 ) [ delegate set ] extend ;C

[ 5 ] [ <del1> <del2> super ] unit-test
