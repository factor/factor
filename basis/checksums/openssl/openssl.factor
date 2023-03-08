! Copyright (C) 2008, 2010, 2016 Slava Pestov, Alexander Ilin
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data checksums checksums.common
destructors kernel namespaces openssl openssl.libcrypto sequences ;
IN: checksums.openssl

ERROR: unknown-digest name ;

TUPLE: openssl-checksum name ;

INSTANCE: openssl-checksum block-checksum

CONSTANT: openssl-md5 T{ openssl-checksum f "md5" }

CONSTANT: openssl-sha1 T{ openssl-checksum f "sha1" }

CONSTANT: openssl-sha256 T{ openssl-checksum f "sha256" }

C: <openssl-checksum> openssl-checksum

<PRIVATE

TUPLE: evp-md-context < disposable handle ;

: evp-md-ctx-new ( -- ctx )
    ssl-new-api? get-global [ EVP_MD_CTX_new ] [ EVP_MD_CTX_create ] if ;

: evp-md-ctx-free ( ctx -- )
    ssl-new-api? get-global [ EVP_MD_CTX_free ] [ EVP_MD_CTX_destroy ] if ;

: <evp-md-context> ( -- ctx )
    evp-md-context new-disposable evp-md-ctx-new >>handle ;

M: evp-md-context dispose*
    handle>> evp-md-ctx-free ;

: digest-named ( name -- md )
    [ EVP_get_digestbyname ] [ unknown-digest ] ?unless ;

: set-digest ( name ctx -- )
    handle>> swap digest-named f EVP_DigestInit_ex ssl-error ;

M: openssl-checksum initialize-checksum-state
    maybe-init-ssl name>> <evp-md-context> [ set-digest ] keep ;

M: evp-md-context add-checksum-bytes
    [ dup handle>> ] dip dup length EVP_DigestUpdate ssl-error ;

M: evp-md-context get-checksum
    handle>>
    { { int EVP_MAX_MD_SIZE } int }
    [ EVP_DigestFinal_ex ssl-error ] with-out-parameters
    memory>byte-array ;

PRIVATE>
