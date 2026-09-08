USING: accessors calendar concurrency.futures continuations
http.client http.server io.servers io.sockets
io.sockets.secure io.sockets.secure.openssl io.timeouts kernel
math math.parser sequences strings tools.test ;
IN: io.sockets.secure.openssl.tests

{ 200 } [ "https://www.google.se" http-get drop code>> ] unit-test

[ "https://factorcode.org:80" http-get ] must-fail

: tls-request-error ( url -- error/f )
    [ http-get 2drop f ] [ nip ] recover ;

! TLS on a plain HTTP socket must fail promptly, including on Windows.
! Use an assigned port so concurrent test processes cannot collide.
10 [
    [
        <http-server> "127.0.0.1" 0 <inet4> >>insecure f >>secure [
            "https://127.0.0.1:" insecure-addr port>> number>string
            append [ tls-request-error ] curry future
            5 seconds ?future-timeout [ rethrow ] when*
        ] with-threaded-server
    ] [
        dup string? [ "SSL routines" swap subseq? ] [ drop f ] if
    ] must-fail-with
] times

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
