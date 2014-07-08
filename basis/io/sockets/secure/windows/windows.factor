USING: accessors alien io.ports io.sockets.private io.sockets.secure
io.sockets.secure.openssl io.sockets.windows kernel locals openssl
openssl.libcrypto openssl.libssl windows.winsock ;
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

M:: secure establish-connection ( client-out addrspec -- )
    client-out handle>> file>> :> socket
    socket FIONBIO 1 set-ioctl-socket
    socket <output-port> addrspec addrspec>> establish-connection
    client-out addrspec secure-connection
    socket FIONBIO 0 set-ioctl-socket ;

M: windows non-ssl-socket? win32-socket? ;
