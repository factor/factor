USING: accessors http.client kernel tools.test ;
IN: io.sockets.secure.openssl.tests

[ 200 ] [ "https://www.google.se" http-get drop code>> ] unit-test
