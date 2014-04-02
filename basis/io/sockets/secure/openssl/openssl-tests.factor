USING: accessors alien continuations http.client http.server io.files.temp
io.servers io.sockets io.sockets.private io.sockets.secure
io.sockets.secure.openssl kernel logging.server openssl.libcrypto openssl.libssl
sequences system tools.test urls vocabs.parser ;
IN: io.sockets.secure.openssl.tests

<< os windows? [ "windows.winsock" ] [ "unix.ffi" ] if use-vocab >>

: new-ssl ( -- ssl )
    SSLv23_client_method SSL_CTX_new SSL_new ;

: socket-connect ( remote -- socket )
    AF_INET SOCK_STREAM IPPROTO_TCP socket swap dupd
    make-sockaddr/size connect drop ;

: ssl-socket-connect ( remote -- ssl-socket )
    socket-connect alien-address BIO_NOCLOSE BIO_new_socket ;

: remote ( -- remote )
    URL" https://www.google.com" url-addr addrspec>> resolve-host first ;

[ 200 ] [ "https://www.google.se" http-get drop code>> ] unit-test

[ "www.google.com" ] [
    new-ssl dup remote ssl-socket-connect dup SSL_set_bio
    dup SSL_connect drop SSL_get_peer_certificate subject-name
] unit-test

[ t ] [
    temp-directory [
        <http-server> 8887 >>insecure f >>secure [
            [ "https://localhost:8887" http-get ] [ drop t ] recover
        ] with-threaded-server
    ] with-log-root
] unit-test

[ t ] [
    [ "test" 33 <ssl-handle> handle>> check-subject-name ] [ drop t ] recover
] unit-test
