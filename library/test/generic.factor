IN: scratchpad
USE: hashtables
USE: namespaces
USE: generic
USE: test
USE: kernel

TRAITS: test-traits
C: test-traits ;

[ t ] [ <test-traits> test-traits? ] unit-test
[ f ] [ "hello" test-traits? ] unit-test
[ f ] [ <namespace> test-traits? ] unit-test

GENERIC: foo

M: test-traits foo drop 12 ;

TRAITS: another-test
C: another-test ;

M: another-test foo drop 13 ;

[ 12 ] [ <test-traits> foo ] unit-test
[ 13 ] [ <another-test> foo ] unit-test

TRAITS: quux
C: quux ;

M: quux foo "foo" swap hash ;

[
    "Hi"
] [
    <quux> [
        "Hi" "foo" set
    ] extend foo
] unit-test

TRAITS: ctr-test
C: ctr-test [ 5 "x" set ] extend ;

[
    5
] [
    <ctr-test> [ "x" get ] bind
] unit-test

TRAITS: del1
C: del1 ;

GENERIC: super
M: del1 super drop 5 ;

TRAITS: del2
C: del2 ( delegate -- del2 ) [ delegate set ] extend ;

[ 5 ] [ <del1> <del2> super ] unit-test
