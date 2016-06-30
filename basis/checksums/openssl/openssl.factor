! Copyright (C) 2008, 2010, 2016 Slava Pestov, Alexander Ilin
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data checksums destructors
io kernel openssl openssl.libcrypto sequences ;
IN: checksums.openssl

ERROR: unknown-digest name ;

TUPLE: openssl-checksum name ;

INSTANCE: openssl-checksum checksum

CONSTANT: openssl-md5 T{ openssl-checksum f "md5" }

CONSTANT: openssl-sha1 T{ openssl-checksum f "sha1" }

C: <openssl-checksum> openssl-checksum

<PRIVATE

TUPLE: evp-md-context < disposable handle ;

: <evp-md-context> ( -- ctx )
    evp-md-context new-disposable
    EVP_MD_CTX_create >>handle ;

M: evp-md-context dispose*
    handle>> EVP_MD_CTX_destroy ;

: digest-named ( name -- md )
    dup EVP_get_digestbyname [ ] [ unknown-digest ] ?if ;

: set-digest ( name ctx -- )
    handle>> swap digest-named f EVP_DigestInit_ex ssl-error ;

: with-evp-md-context ( ... checksum quot: ( ... ctx -- ... ) -- ... )
    [
        maybe-init-ssl name>> <evp-md-context>
        [ set-digest ] keep
    ] dip with-disposal ; inline

: digest-value ( ctx -- value )
    handle>>
    { { int EVP_MAX_MD_SIZE } int }
    [ EVP_DigestFinal_ex ssl-error ] with-out-parameters
    memory>byte-array ;

: digest-update ( ctx bytes -- ctx )
    [ dup handle>> ] dip dup length EVP_DigestUpdate ssl-error ;

PRIVATE>

M: openssl-checksum checksum-bytes
    [ swap digest-update digest-value ] with-evp-md-context ;

M: openssl-checksum checksum-stream
    [
        swap
        [ [ digest-update ] each-block ] with-input-stream
        digest-value
    ] with-evp-md-context ;
