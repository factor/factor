IN: io.launcher.windows.tests
USING: tools.test io.launcher.windows ;

[ "hello world" ] [ { "hello" "world" } join-arguments ] unit-test

[ "bob \"mac arthur\"" ] [ { "bob" "mac arthur" } join-arguments ] unit-test

[ "bob mac\\\\arthur" ] [ { "bob" "mac\\\\arthur" } join-arguments ] unit-test

[ "bob \"mac arthur\\\\\"" ] [ { "bob" "mac arthur\\" } join-arguments ] unit-test
