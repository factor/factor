USING:
    accessors
    alien
    io.ports
    io.sockets.private io.sockets.secure io.sockets.secure.openssl
    kernel
    openssl openssl.libcrypto openssl.libssl ;
IN: io.sockets.secure.windows

M: openssl ssl-supported? t ;
M: openssl ssl-certificate-verification-supported? f ;

: <ssl-socket> ( winsock -- ssl )
    [
        handle>> alien-address BIO_NOCLOSE BIO_new_socket dup ssl-error
    ] keep <ssl-handle>
    [ handle>> swap dup SSL_set_bio ] keep ;

M: secure ((client)) ( addrspec -- handle )
    addrspec>> ((client)) <ssl-socket> ;

M: secure (get-local-address) ( handle remote -- sockaddr )
    [ file>> ] [ addrspec>> ] bi* (get-local-address) ;

M: secure parse-sockaddr addrspec>> parse-sockaddr <secure> ;

M: secure establish-connection ( client-out remote -- )
    [
        [ handle>> file>> <output-port> ] [ addrspec>> ] bi* establish-connection
    ]
    [ secure-connection ] 2bi ;
