IN: macros.tests
USING: tools.test macros math kernel arrays
vectors io.streams.string prettyprint parser ;

MACRO: see-test ( a b -- c ) + ;

[ "USING: macros math ;\nIN: macros.tests\nMACRO: see-test ( a b -- c ) + ;\n" ]
[ [ \ see-test see ] with-string-writer ]
unit-test

[ t ] [
    "USING: math ;\nIN: macros.tests\n: see-test ( a b -- c ) - ;\n" dup eval
    [ \ see-test see ] with-string-writer =
] unit-test

[ ] [ "USING: macros inference kernel ; IN: hanging-macro MACRO: c ( quot -- ) infer drop [ ] ; : a ( -- ) [ a ] c ;" eval ] unit-test

