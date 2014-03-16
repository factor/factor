! Copyright (C) 2007, 2008, Slava Pestov, Elie CHAFTARI.
! See http://factorcode.org/license.txt for BSD license.
USING: init io kernel namespaces openssl.libcrypto openssl.libssl
sequences ;
IN: openssl

! This code is based on http://www.rtfm.com/openssl-examples/

SINGLETON: openssl

: (ssl-error-string) ( n -- string )
    ERR_clear_error f ERR_error_string ;

: ssl-error-string ( -- string )
    ERR_get_error (ssl-error-string) ;

: (ssl-error) ( -- * )
    ssl-error-string throw ;

: ssl-error ( obj -- )
    { f 0 } member? [ (ssl-error) ] when ;

: init-ssl ( -- )
    SSL_library_init ssl-error
    SSL_load_error_strings
    OpenSSL_add_all_digests
    OpenSSL_add_all_ciphers ;

[ init-ssl ] "openssl" add-startup-hook
