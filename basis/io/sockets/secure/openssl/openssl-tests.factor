USING: accessors continuations http.client http.server io.servers
io.sockets.secure io.sockets.secure.openssl io.timeouts kernel
tools.test ;
IN: io.sockets.secure.openssl.tests

{ 200 } [ "https://www.google.se" http-get drop code>> ] unit-test

[
    <http-server> 8887 >>insecure f >>secure [
        "https://localhost:8887" http-get
    ] with-threaded-server
] must-fail
! XXX: Make this fail with certificate-missing-error? on Windows someday.
! ] [ certificate-missing-error? ] must-fail-with

[ "test" 33 <ssl-handle> handle>> check-subject-name ]
[ certificate-missing-error? ] must-fail-with

{ t } [ "badssl.com" "*.badssl.com" subject-names-match? ] unit-test
{ t } [ "www.badssl.com" "*.badssl.com" subject-names-match? ] unit-test
{ f } [ "foo.bar.badssl.com" "*.badssl.com" subject-names-match? ] unit-test
{ f } [ ".com" "*.badssl.com" subject-names-match? ] unit-test

TUPLE: fake-fd fd ;

M: fake-fd cancel-operation ( obj -- ) drop ;

{ f } [
    33 fake-fd boa <ssl-handle> [ maybe-handshake ] ignore-errors connected>>
] unit-test
