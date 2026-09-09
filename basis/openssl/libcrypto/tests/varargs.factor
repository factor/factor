! A memory BIO avoids the network-dependent legacy libcrypto smoke tests.
USING: accessors alien.c-types alien.libraries alien.syntax byte-arrays
continuations io.encodings.string io.encodings.utf8 kernel locals openssl.libcrypto sequences
tools.test words ;
IN: openssl.libcrypto.varargs.tests

{ 2 } [ \ BIO_printf def>> 4 swap nth ] unit-test

LIBRARY: libcrypto
FUNCTION: void* BIO_s_mem ( )

:: format-memory-bio ( -- written text )
    BIO_s_mem BIO_new :> bio
    [
        bio "plain BIO text" BIO_printf
        64 <byte-array> :> buffer
        bio buffer 64 BIO_read :> count
        buffer count head utf8 decode
    ] [ bio BIO_free drop ] finally ;
{ 14 "plain BIO text" } [ format-memory-bio ] unit-test
