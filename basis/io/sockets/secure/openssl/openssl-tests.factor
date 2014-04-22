USING: accessors http.client http.server io.servers
io.sockets.secure io.sockets.secure.openssl kernel tools.test ;
IN: io.sockets.secure.openssl.tests

{ 200 } [ "https://www.google.se" http-get drop code>> ] unit-test

[
    <http-server> 8887 >>insecure f >>secure [
        "https://localhost:8887" http-get
    ] with-threaded-server
] [ certificate-missing-error? ] must-fail-with

[ "test" 33 <ssl-handle> handle>> check-subject-name ]
[ certificate-missing-error? ] must-fail-with
