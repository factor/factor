USING: continuations destructors io.sockets kernel ping
tools.test ;
IN: ping.tests

[ ] [ "localhost" ping drop ] unit-test
[ t ] [ "localhost" alive? ] unit-test
[ t ] [ "127.0.0.1" alive? ] unit-test
[ f ] [ "0.0.0.0" alive? ] unit-test
