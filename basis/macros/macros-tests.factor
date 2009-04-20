IN: macros.tests
USING: tools.test macros math kernel arrays
vectors io.streams.string prettyprint parser eval see ;

MACRO: see-test ( a b -- quot ) + ;

[ t ] [ \ see-test macro? ] unit-test

[ "USING: macros math ;\nIN: macros.tests\nMACRO: see-test ( a b -- quot ) + ;\n" ]
[ [ \ see-test see ] with-string-writer ]
unit-test

[ t ] [ \ see-test macro? ] unit-test

[ t ] [
    "USING: math ;\nIN: macros.tests\n: see-test ( a b -- c ) - ;\n" dup eval( -- )
    [ \ see-test see ] with-string-writer =
] unit-test

[ f ] [ \ see-test macro? ] unit-test

[ ] [ "USING: macros stack-checker kernel ; IN: hanging-macro MACRO: c ( quot -- ) infer drop [ ] ; : a ( -- ) [ a ] c ;" eval( -- ) ] unit-test

