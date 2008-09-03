USING: tools.test tuple-syntax ;
IN: tuple-syntax.tests

TUPLE: foo bar baz ;

[ T{ foo } ] [ TUPLE{ foo } ] unit-test
[ T{ foo f { 2 3 } { 4 { 5 } } } ]
[ TUPLE{ foo bar: { 2 3 } baz: { 4 { 5 } } } ] unit-test
