USING: accessors alien http.client io.sockets io.sockets.private
io.sockets.secure.openssl kernel openssl.libcrypto openssl.libssl
sequences tools.test urls unix.ffi ;
IN: io.sockets.secure.openssl.tests

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

[ "www.google.com" ] [
    new-ssl
    [
        remote (client) drop nip handle>> handle>>
        alien-address BIO_NOCLOSE BIO_new_socket dup SSL_set_bio
    ]
    [ SSL_connect drop ]
    [ SSL_get_peer_certificate ] tri
    subject-name
] unit-test

[ "google.com" ] [
    URL" https://www.google.se" url-addr resolve-host first
    [ ((client)) ] keep [ <ports> ] dip establish-connection
    handle>> handle>> SSL_get_peer_certificate subject-name
] unit-test
