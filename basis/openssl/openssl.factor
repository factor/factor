! Copyright (C) 2007, 2008, Slava Pestov, Elie CHAFTARI.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.libraries kernel math namespaces openssl.libcrypto
openssl.libssl sequences ;
IN: openssl

! This code is based on https://www.rtfm.com/openssl-examples/

SYMBOLS: ssl-initialized? ssl-new-api? ;

SINGLETON: openssl

: (ssl-error-string) ( n -- string )
    ERR_clear_error f ERR_error_string ;

: ssl-error-string ( -- string )
    ERR_get_error (ssl-error-string) ;

: throw-ssl-error ( -- * )
    ssl-error-string throw ;

: ssl-error ( obj -- )
    { f 0 } member? [ throw-ssl-error ] when ;

: init-old-api ( -- )
    SSL_library_init ssl-error
    SSL_load_error_strings
    OpenSSL_add_all_digests ;

: init-new-api ( -- )
    0 f OPENSSL_init_ssl ssl-error
    OPENSSL_INIT_LOAD_SSL_STRINGS
    OPENSSL_INIT_LOAD_CRYPTO_STRINGS bitand
    f OPENSSL_init_ssl ssl-error
    OPENSSL_INIT_ADD_ALL_DIGESTS f OPENSSL_init_ssl ssl-error ;

: init-ssl ( -- )
    "OPENSSL_init_ssl" "libssl" dlsym? >boolean
    [ ssl-new-api? set-global ]
    [ [ init-new-api ] [ init-old-api ] if ] bi ;

: maybe-init-ssl ( -- )
    ssl-initialized? get-global [
        init-ssl
        t ssl-initialized? set-global
    ] unless ;

STARTUP-HOOK: [ f ssl-initialized? set-global ]
