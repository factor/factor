USING: accessors alien continuations http.client http.server io.servers
io.sockets io.sockets.private io.sockets.secure io.sockets.secure.openssl
kernel openssl.libcrypto openssl.libssl sequences system tools.test urls
vocabs.parser ;
IN: io.sockets.secure.openssl.tests

<< os windows? [ "windows.winsock" ] [ "unix.ffi" ] if use-vocab >>

: new-ssl ( -- ssl )
    SSLv23_client_method SSL_CTX_new SSL_new ;

! This word creates blocking sockets for testing purposes. Factor by
! default prefers to use non-blocking ones.
: inet-socket ( -- socket )
    AF_INET SOCK_STREAM IPPROTO_TCP socket ;

: socket-connect ( remote -- socket )
    inet-socket swap dupd make-sockaddr/size connect 0 assert= ;

: ssl-socket-connect ( remote -- ssl-socket )
    socket-connect os windows? [ alien-address ] when
    BIO_NOCLOSE BIO_new_socket ;

: remote ( url -- remote )
    url-addr addrspec>> resolve-host first ;

! These tests break if any of the sites change their certs or go
! down. But that should never ever happen. :)
[ "www.google.com" ] [
    new-ssl dup URL" https://www.google.com" remote
    ssl-socket-connect dup SSL_set_bio
    dup do-ssl-connect-once f assert=
    SSL_get_peer_certificate subject-name
] unit-test

[ "*.facebook.com" ] [
    new-ssl dup URL" https://www.facebook.com" remote
    ssl-socket-connect dup SSL_set_bio
    dup do-ssl-connect-once f assert=
    SSL_get_peer_certificate subject-name
] unit-test

[ "github.com" ] [
    new-ssl dup URL" https://www.github.com" remote
    ssl-socket-connect dup SSL_set_bio
    dup do-ssl-connect-once f assert=
    SSL_get_peer_certificate subject-name
] unit-test

{ 200 } [ "https://www.google.se" http-get drop code>> ] unit-test

[
    <http-server> 8887 >>insecure f >>secure [
        "https://localhost:8887" http-get
    ] with-threaded-server
] [ certificate-missing-error? ] must-fail-with

[ "test" 33 <ssl-handle> handle>> check-subject-name ]
[ certificate-missing-error? ] must-fail-with
