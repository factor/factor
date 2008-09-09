IN: xml.writer.tests
USING: xml.data xml.writer tools.test ;

[ "foo" ] [ T{ name { main "foo" } } name>string ] unit-test
[ "ns:foo" ] [ T{ name { space "ns" } { main "foo" } } name>string ] unit-test
