! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays alien.c-types kernel continuations
destructors sequences io openssl openssl.libcrypto checksums
checksums.stream ;
IN: checksums.openssl

ERROR: unknown-digest name ;

TUPLE: openssl-checksum name ;

CONSTANT: openssl-md5 T{ openssl-checksum f "md5" }

CONSTANT: openssl-sha1 T{ openssl-checksum f "sha1" }

INSTANCE: openssl-checksum stream-checksum

C: <openssl-checksum> openssl-checksum

<PRIVATE

TUPLE: evp-md-context < disposable handle ;

: <evp-md-context> ( -- ctx )
    evp-md-context new-disposable
    "EVP_MD_CTX" <c-object> dup EVP_MD_CTX_init >>handle ;

M: evp-md-context dispose*
    handle>> EVP_MD_CTX_cleanup drop ;

: with-evp-md-context ( quot -- )
    maybe-init-ssl [ <evp-md-context> ] dip with-disposal ; inline

: digest-named ( name -- md )
    dup EVP_get_digestbyname
    [ ] [ unknown-digest ] ?if ;

: set-digest ( name ctx -- )
    handle>> swap digest-named f EVP_DigestInit_ex ssl-error ;

: checksum-loop ( ctx -- )
    dup handle>>
    4096 read-partial dup [
        dup length EVP_DigestUpdate ssl-error
        checksum-loop
    ] [ 3drop ] if ;

: digest-value ( ctx -- value )
    handle>>
    EVP_MAX_MD_SIZE <byte-array> 0 <int>
    [ EVP_DigestFinal_ex ssl-error ] 2keep
    *int memory>byte-array ;

PRIVATE>

M: openssl-checksum checksum-stream
    name>> swap [
        [
            [ set-digest ]
            [ checksum-loop ]
            [ digest-value ]
            tri
        ] with-evp-md-context
    ] with-input-stream ;
