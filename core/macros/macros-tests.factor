USING: tools.test macros math kernel arrays
vectors io.streams.string prettyprint parser eval see
stack-checker compiler.units definitions vocabs ;
IN: macros.tests

MACRO: see-test ( a b -- quot ) + ;

{ t } [ \ see-test macro? ] unit-test

{ "USING: math ;\nIN: macros.tests\nMACRO: see-test ( a b -- quot ) + ;\n" }
[ [ \ see-test see ] with-string-writer ]
unit-test

{ t } [ \ see-test macro? ] unit-test

{ t } [
    "USING: math ;\nIN: macros.tests\n: see-test ( a b -- c ) - ;\n" dup eval( -- )
    [ \ see-test see ] with-string-writer =
] unit-test

{ f } [ \ see-test macro? ] unit-test

{ } [ "USING: stack-checker kernel ; IN: hanging-macro MACRO: c ( quot -- quot ) infer drop [ ] ;" eval( -- ) ] unit-test
{ } [ "USING: kernel ; IN: hanging-macro : a ( -- ) [ a ] c ;" eval( -- ) ] unit-test

{ } [ [ "hanging-macro" forget-vocab ] with-compilation-unit ] unit-test

{ } [ "IN: macros.tests MACRO: foo ( -- x ) [ ] ;" eval( -- ) ] unit-test
    [ "IN: macros.tests MACRO: foo ( -- x ) [ ] ; inline" eval( -- ) ] must-fail

! The macro expander code should infer
MACRO: bad-macro ( a -- b ) 1 2 3 [ ] ;

! Must fail twice, and not memoize a bad result
[ [ 0 bad-macro ] call ] must-fail
[ [ 0 bad-macro ] call ] must-fail

[ [ 0 bad-macro ] infer ] must-fail

{ } [ [ \ bad-macro forget ] with-compilation-unit ] unit-test
