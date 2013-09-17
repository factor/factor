USING:
    byte-arrays
    kernel
    openssl.libcrypto
    sequences
    splitting
    strings
    tools.test ;
IN: openssl.libcrypto.tests

[ t ] [ "factorcode.org:80" BIO_new_connect bio_st? ] unit-test

[ 1 ] [
    "factorcode.org:80" BIO_new_connect BIO_C_DO_STATE_MACHINE 0 f BIO_ctrl
] unit-test

[ "HTTP/1.1 200 Document follows" ] [
    "factorcode.org:80" BIO_new_connect
    [ BIO_C_DO_STATE_MACHINE 0 f BIO_ctrl drop ]
    [
        [ "GET / HTTP/1.1\r\nHost: factorcode.org\r\n\r\n" BIO_puts drop ]
        [ 1024 <byte-array> dup swapd 1023 BIO_read drop ] bi
    ] bi >string "\r\n" split first
] unit-test
