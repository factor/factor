! Copyright (C) 2008, 2010, 2016 Slava Pestov, Alexander Ilin
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data checksums
checksums.stream destructors fry io kernel openssl openssl.libcrypto
sequences ;
IN: checksums.openssl

ERROR: unknown-digest name ;

TUPLE: openssl-checksum name ;

CONSTANT: openssl-md5 T{ openssl-checksum f "md5" }

CONSTANT: openssl-sha1 T{ openssl-checksum f "sha1" }

INSTANCE: openssl-checksum stream-checksum

C: <openssl-checksum> openssl-checksum

TUPLE: evp-md-context < disposable handle ;

: <evp-md-context> ( -- ctx )
    evp-md-context new-disposable
    EVP_MD_CTX_create >>handle ;

M: evp-md-context dispose*
    handle>> EVP_MD_CTX_destroy ;

<PRIVATE

: digest-named ( name -- md )
    dup EVP_get_digestbyname
    [ ] [ unknown-digest ] ?if ;

: set-digest ( name ctx -- )
    handle>> swap digest-named f EVP_DigestInit_ex ssl-error ;

: checksum-method ( data checksum method: ( ctx data -- ctx' ) -- value )
    [ initialize-checksum-state ] dip '[ swap @ get-checksum ] with-disposal ; inline

PRIVATE>

M: openssl-checksum initialize-checksum-state ( checksum -- evp-md-context )
    maybe-init-ssl name>> <evp-md-context> [ set-digest ] keep ;

M: evp-md-context add-checksum-bytes ( ctx bytes -- ctx' )
    [ dup handle>> ] dip dup length EVP_DigestUpdate ssl-error ;

M: evp-md-context get-checksum ( ctx -- value )
    handle>>
    { { int EVP_MAX_MD_SIZE } int }
    [ EVP_DigestFinal_ex ssl-error ] with-out-parameters
    memory>byte-array ;

M: openssl-checksum checksum-bytes ( bytes checksum -- value )
    [ add-checksum-bytes ] checksum-method ;

M: openssl-checksum checksum-stream ( stream checksum -- value )
    [ add-checksum-stream ] checksum-method ;
