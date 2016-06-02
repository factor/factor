USING: accessors alien alien.c-types alien.data alien.strings
calendar combinators combinators.short-circuit destructors io
io.encodings.utf8 io.ports io.sockets.private io.sockets.secure
io.sockets.secure.openssl io.sockets.windows kernel libc locals
math math.order openssl openssl.libcrypto openssl.libssl system
windows.crypt32 windows.errors windows.time windows.winsock ;
IN: io.sockets.secure.windows

M: openssl ssl-supported? t ;
M: openssl ssl-certificate-verification-supported? f ;

: close-windows-cert-store ( HCERTSTORE -- )
    0 CertCloseStore win32-error=0/f ;

: load-windows-cert-store ( string -- HCERTSTORE )
    [ f ] dip CertOpenSystemStore
    [ win32-error-string throw ] when-zero ;

: X509-NAME. ( X509_NAME -- )
    f 0 X509_NAME_oneline
    [ utf8 alien>string print ] [ (free) ] bi ;

: X509. ( X509 -- )
    {
        [ X509_get_subject_name "subject: " write X509-NAME. ]
        [ X509_get_issuer_name "issuer: " write X509-NAME. ]
    } cleave ;

: add-cert-to-store ( cert-store cert -- )
    X509_STORE_add_cert ssl-error ;

:: set-windows-certs-for ( name -- )
    [
        name load-windows-cert-store :> cs
        X509_STORE_new :> x509-store
        f :> ctx!
        [ ctx ]
        [
            cs ctx CertEnumCertificatesInStore ctx!
            ctx [
                f ctx [ pbCertEncoded>> void* <ref> ]
                [ cbCertEncoded>> ] bi d2i_X509
                {
                    [ ssl-error ]
                    ! [ X509. ]
                    [ x509-store swap X509_STORE_add_cert ssl-error ]
                } cleave
            ] when
        ] do while
    ] with-destructors ;

! XXX: the MSFT cert is in "CA" twice, and throws an error
! when loading the second time.
: set-windows-certs ( -- )
    ! "CA" set-windows-certs-for
    "ROOT" set-windows-certs-for ;

M: windows socket-handle handle>> alien-address ;

M: secure remote>handle ( addrspec -- handle )
    [ addrspec>> remote>handle ] [ hostname>> ] bi <ssl-socket> ;

GENERIC: windows-socket-handle ( obj -- handle )
M: ssl-handle windows-socket-handle file>> ;
M: win32-socket windows-socket-handle ;

M: secure (get-local-address) ( handle remote -- sockaddr )
    [ windows-socket-handle ] [ addrspec>> ] bi* (get-local-address) ;

M: secure parse-sockaddr addrspec>> parse-sockaddr f <secure> ;

M:: secure establish-connection ( client-out addrspec -- )
    client-out handle>> file>> :> socket
    socket FIONBIO 1 set-ioctl-socket
    socket <output-port> addrspec addrspec>> establish-connection
    client-out addrspec secure-connection
    socket FIONBIO 0 set-ioctl-socket ;

M: windows non-ssl-socket? win32-socket? ;
