! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.
!
! Tested with OpenSSL 0.9.8a_0 on Mac OS X 10.4.9 PowerPC

USING: alien alien.c-types assocs kernel libc namespaces
openssl.libcrypto openssl.libssl sequences unix ;

IN: openssl

SYMBOL: bio
SYMBOL: ssl-bio

SYMBOL: ctx
SYMBOL: dh
SYMBOL: rsa

! =========================================================
! Callback routines
! =========================================================

: password-cb ( -- alien )
    "int" { "char*" "int" "int" "void*" } "cdecl"
    [ 3drop "password" string>char-alien 1023 memcpy
    "password" length ] alien-callback ;

! =========================================================
! Error-handling routines
! =========================================================

: get-error ( -- num )
    ERR_get_error ;

: error-string ( num -- str )
    f ERR_error_string ;

: check-result ( result -- )
    1 = [  ] [
        get-error error-string throw
    ] if ;

: ssl-get-error ( ssl ret -- )
    SSL_get_error error-messages at throw ;

! Write errors to a file
: bio-new-file ( path mode -- )
    BIO_new_file bio set ;

: bio-print ( bio str -- n )
    BIO_printf ;

: bio-free ( bio -- )
    BIO_free check-result ;

! =========================================================
! Initialization routines
! =========================================================

: init ( -- )
    SSL_library_init drop ; ! always returns 1

: load-error-strings ( -- )
    SSL_load_error_strings ;

: ssl-v23 ( -- method )
    SSLv23_method ;

: new-ctx ( method -- )
    SSL_CTX_new ctx set ;

: use-cert-chain ( ctx file -- )
    SSL_CTX_use_certificate_chain_file check-result ;

: set-default-passwd ( ctx cb -- )
    SSL_CTX_set_default_passwd_cb ;

: set-default-passwd-userdata ( ctx passwd -- )
    SSL_CTX_set_default_passwd_cb_userdata ;

: use-private-key ( ctx file type -- )
    SSL_CTX_use_PrivateKey_file check-result ;

: verify-load-locations ( ctx file path -- )
    SSL_CTX_load_verify_locations check-result ;

: set-verify-depth ( ctx depth -- )
    SSL_CTX_set_verify_depth ;

: read-pem-dh-params ( bio x cb u -- )
    PEM_read_bio_DHparams dh set ;

: set-tmp-dh-callback ( ctx dh -- )
    SSL_CTX_set_tmp_dh_callback ;

: set-ctx-ctrl ( ctx cmd larg parg -- )
    SSL_CTX_ctrl check-result ;

: generate-rsa-key ( n e cb cbarg -- )
    RSA_generate_key rsa set ;

: set-tmp-rsa-callback ( ctx rsa -- )
    SSL_CTX_set_tmp_rsa_callback ;

: free-rsa ( rsa -- )
    RSA_free ;

: bio-new-socket ( fd flag -- sbio )
    BIO_new_socket ;

: new-ssl ( ctx -- ssl )
    SSL_new ;

: set-ssl-bio ( ssl bio bio -- )
    SSL_set_bio ;

: set-ssl-fd ( ssl fd -- )
    SSL_set_fd check-result ;

: ssl-accept ( ssl -- result )
    SSL_accept ;

! =========================================================
! Clean-up and termination routines
! =========================================================

: destroy-ctx ( ctx -- )
    SSL_CTX_free ;

! =========================================================
! Public routines
! =========================================================

: get-bio ( -- bio )
    bio get ;

: get-ssl-bio ( -- bio )
    ssl-bio get ;

: get-ctx ( -- ctx )
    ctx get ;

: get-dh ( -- dh )
    dh get ;

: get-rsa ( -- rsa )
    rsa get ;

: >md5 ( str -- byte-array )
    dup length 16 "uchar" <c-array> [ MD5 ] keep nip ;

: >sha1 ( str -- byte-array )
    dup length 20 "uchar" <c-array> [ SHA1 ] keep nip ;

