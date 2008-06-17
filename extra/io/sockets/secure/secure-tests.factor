IN: io.sockets.secure.tests
USING: io.sockets.secure tools.test ;

[ "hello" 24 ] [ "hello" 24 <inet> <secure> [ host>> ] [ port>> ] bi ] unit-test
