IN: xml.utilities.tests
USING: xml xml.utilities tools.test ;

[ "bar" ] [ "<foo>bar</foo>" string>xml children>string ] unit-test

[ "" ] [ "<foo></foo>" string>xml children>string ] unit-test

[ "" ] [ "<foo/>" string>xml children>string ] unit-test
