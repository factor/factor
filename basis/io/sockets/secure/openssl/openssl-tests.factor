USING: accessors alien continuations http.client http.server io.servers
io.sockets io.sockets.private io.sockets.secure io.sockets.secure.openssl
kernel openssl.libcrypto openssl.libssl sequences system tools.test urls
unix.ffi ;
IN: io.sockets.secure.openssl.tests

: new-ssl ( -- ssl )
    SSLv23_client_method SSL_CTX_new SSL_new ;

! This word creates blocking sockets for testing purposes. Factor by
! default prefers to use non-blocking ones.
: inet-socket ( -- socket )
    AF_INET SOCK_STREAM IPPROTO_TCP socket ;

: socket-connect ( remote -- socket )
    inet-socket swap dupd make-sockaddr/size connect drop ;

: ssl-socket-connect ( remote -- ssl-socket )
    socket-connect os windows? [ alien-address ] when
    BIO_NOCLOSE BIO_new_socket ;

: remote ( -- remote )
    URL" https://www.google.com" url-addr addrspec>> resolve-host first ;

[ 200 ] [ "https://www.google.se" http-get drop code>> ] unit-test

[ "www.google.com" ] [
    new-ssl dup remote ssl-socket-connect dup SSL_set_bio
    dup SSL_connect drop SSL_get_peer_certificate subject-name
] unit-test

[ t ] [
    <http-server> 8887 >>insecure f >>secure [
        [
            "https://localhost:8887" http-get
        ] [ certificate-missing-error? ] recover
    ] with-threaded-server
] unit-test

[ t ] [
    [
        "test" 33 <ssl-handle> handle>> check-subject-name
    ] [ certificate-missing-error? ] recover
] unit-test
