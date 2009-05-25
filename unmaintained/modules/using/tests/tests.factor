QUALIFIED-WITH: modules.using m
IN: modules.using.tests
m:USING: tools.test localhost::modules.test-server ;
[ "hello world" ] [ rpc-hello ] unit-test