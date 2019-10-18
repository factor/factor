USING: triggers kernel tools.test ;
IN: triggers.tests

SYMBOL: test-trigger
test-trigger reset-trigger
: add-test-trigger test-trigger add-trigger ;
[ ] [ test-trigger call-trigger ] unit-test
[ "op called" ] [ "op" [ "op called" ] add-test-trigger test-trigger call-trigger ] unit-test
[ "first called" "second called" ] [
    test-trigger reset-trigger
    "second op" [ "second called" ] add-test-trigger
    "first op" [ "first called" ] add-test-trigger
    test-trigger call-trigger
] unit-test
