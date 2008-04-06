IN: io.windows.launcher.tests
USING: tools.test io.windows.launcher ;

[ "hello world" ] [ { "hello" "world" } join-arguments ] unit-test

[ "bob \"mac arthur\"" ] [ { "bob" "mac arthur" } join-arguments ] unit-test

[ "bob mac\\\\arthur" ] [ { "bob" "mac\\\\arthur" } join-arguments ] unit-test

[ "bob \"mac arthur\\\\\"" ] [ { "bob" "mac arthur\\" } join-arguments ] unit-test
