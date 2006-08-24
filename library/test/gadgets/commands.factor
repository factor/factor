IN: temporary
USING: gadgets test ;

[ "A+a" ] [ T{ key-down f { A+ } "a" } gesture>string ] unit-test
[ "b" ] [ T{ key-down f f "b" } gesture>string ] unit-test
[ "Mouse Down 2" ] [ T{ button-down f 2 } gesture>string ] unit-test
[ "Test (Mouse Down 2)" ]
[ T{ command f f "Test" T{ button-down f 2 } [ ] } command-string ] unit-test
