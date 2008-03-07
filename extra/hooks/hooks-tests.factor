USING: hooks kernel tools.test ;
IN: hooks.tests

SYMBOL: test-hook
test-hook reset-hook
: add-test-hook test-hook add-hook ;
[ ] [ test-hook call-hook ] unit-test
[ "op called" ] [ "op" [ "op called" ] add-test-hook test-hook call-hook ] unit-test
[ "first called" "second called" ] [
    test-hook reset-hook
    "second op" [ "second called" ] add-test-hook
    "first op" [ "first called" ] add-test-hook
    test-hook call-hook
] unit-test
