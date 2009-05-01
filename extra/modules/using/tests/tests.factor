USING: modules.using ;
IN: modules.using.tests
USING: tools.test localhost::modules.test-server ;
[ "hello world" ] [ rpc-hello ] unit-test