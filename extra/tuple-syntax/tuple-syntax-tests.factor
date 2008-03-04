USING: tools.test tuple-syntax ;
IN: tuple-syntax.tests

TUPLE: foo bar baz ;

[ T{ foo } ] [ TUPLE{ foo } ] unit-test
[ T{ foo 1 { 2 3 } { 4 { 5 } } } ]
[ TUPLE{ foo bar: { 2 3 } delegate: 1 baz: { 4 { 5 } } } ] unit-test
