IN: temporary
USING: gadgets test ;

[ "A+a" ] [ T{ key-down f { A+ } "a" } gesture>string ] unit-test
[ "b" ] [ T{ key-down f f "b" } gesture>string ] unit-test
[ "Press Button 2" ] [ T{ button-down f f 2 } gesture>string ] unit-test
