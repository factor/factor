IN: io.sockets.tests
USING: io.sockets sequences math tools.test ;

[ t ] [ "localhost" 80 f resolve-host length 1 >= ] unit-test
