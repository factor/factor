! Copyright (C) 2007, 2008, Slava Pestov, Elie CHAFTARI.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays kernel sequences namespaces math
math.order combinators init alien alien.c-types alien.data
alien.strings libc continuations destructors summary splitting
assocs random math.parser locals unicode.case openssl
openssl.libcrypto openssl.libssl io.backend io.ports io.pathnames
io.encodings.8-bit.latin1 io.timeouts io.sockets.secure ;
IN: io.sockets.secure.openssl

GENERIC: ssl-method ( symbol -- method )

M: SSLv2  ssl-method drop SSLv2_client_method ;
M: SSLv23 ssl-method drop SSLv23_method ;
M: SSLv3  ssl-method drop SSLv3_method ;
M: TLSv1  ssl-method drop TLSv1_method ;

TUPLE: openssl-context < secure-context aliens sessions ;

: set-session-cache ( ctx -- )
    handle>>
    [ SSL_SESS_CACHE_BOTH SSL_CTX_set_session_cache_mode ssl-error ]
    [ 32 random-bits >hex dup length SSL_CTX_set_session_id_context ssl-error ]
    bi ;

: load-certificate-chain ( ctx -- )
    dup config>> key-file>> [
        [ handle>> ] [ config>> key-file>> absolute-path ] bi
        SSL_CTX_use_certificate_chain_file
        ssl-error
    ] [ drop ] if ;

: password-callback ( -- alien )
    int { void* int bool void* } cdecl
    [| buf size rwflag password! |
        password [ B{ 0 } password! ] unless

        password strlen :> len
        buf password len 1 + size min memcpy
        len
    ] alien-callback ;

: default-pasword ( ctx -- alien )
    [ config>> password>> latin1 malloc-string ] [ aliens>> ] bi
    [ push ] [ drop ] 2bi ;

: set-default-password ( ctx -- )
    dup config>> password>> [
        [ handle>> password-callback SSL_CTX_set_default_passwd_cb ]
        [
            [ handle>> ] [ default-pasword ] bi
            SSL_CTX_set_default_passwd_cb_userdata
        ] bi
    ] [ drop ] if ;

: use-private-key-file ( ctx -- )
    dup config>> key-file>> [
        [ handle>> ] [ config>> key-file>> absolute-path ] bi
        SSL_FILETYPE_PEM SSL_CTX_use_PrivateKey_file
        ssl-error
    ] [ drop ] if ;

: load-verify-locations ( ctx -- )
    dup config>> [ ca-file>> ] [ ca-path>> ] bi or [
        [ handle>> ]
        [
            config>>
            [ ca-file>> dup [ absolute-path ] when ]
            [ ca-path>> dup [ absolute-path ] when ] bi
        ] bi
        SSL_CTX_load_verify_locations
    ] [ handle>> SSL_CTX_set_default_verify_paths ] if ssl-error ;

: set-verify-depth ( ctx -- )
    dup config>> verify-depth>> [
        [ handle>> ] [ config>> verify-depth>> ] bi
        SSL_CTX_set_verify_depth
    ] [ drop ] if ;

TUPLE: bio < disposable handle ;

: <bio> ( handle -- bio ) bio new-disposable swap >>handle ;

M: bio dispose* handle>> BIO_free ssl-error ;

: <file-bio> ( path -- bio )
    normalize-path "r" BIO_new_file dup ssl-error <bio> ;

: load-dh-params ( ctx -- )
    dup config>> dh-file>> [
        [ handle>> ] [ config>> dh-file>> ] bi <file-bio> &dispose
        handle>> f f f PEM_read_bio_DHparams dup ssl-error
        SSL_CTX_set_tmp_dh ssl-error
    ] [ drop ] if ;

TUPLE: rsa < disposable handle ;

: <rsa> ( handle -- rsa ) rsa new-disposable swap >>handle ;

M: rsa dispose* handle>> RSA_free ;

: generate-eph-rsa-key ( ctx -- )
    [ handle>> ]
    [
        config>> ephemeral-key-bits>> RSA_F4 f f RSA_generate_key
        dup ssl-error <rsa> &dispose handle>>
    ] bi
    SSL_CTX_set_tmp_rsa ssl-error ;

: <openssl-context> ( config ctx -- context )
    openssl-context new-disposable
        swap >>handle
        swap >>config
        V{ } clone >>aliens
        H{ } clone >>sessions ;

M: openssl <secure-context> ( config -- context )
    maybe-init-ssl
    [
        dup method>> ssl-method SSL_CTX_new
        dup ssl-error <openssl-context> |dispose
        {
            [ set-session-cache ]
            [ load-certificate-chain ]
            [ set-default-password ]
            [ use-private-key-file ]
            [ load-verify-locations ]
            [ set-verify-depth ]
            [ load-dh-params ]
            [ generate-eph-rsa-key ]
            [ ]
        } cleave
    ] with-destructors ;

M: openssl-context dispose*
    [
        [ aliens>> [ &free drop ] each ]
        [ sessions>> values [ SSL_SESSION_free ] each ]
        [ handle>> SSL_CTX_free ]
        tri
    ] with-destructors ;

TUPLE: ssl-handle < disposable file handle connected ;

SYMBOL: default-secure-context

: current-secure-context ( -- ctx )
    secure-context get [
        default-secure-context [
            <secure-config> <secure-context>
        ] initialize-alien
    ] unless* ;

: <ssl-handle> ( fd -- ssl )
    [
        ssl-handle new-disposable |dispose
        current-secure-context handle>> SSL_new
        dup ssl-error >>handle
        swap >>file
    ] with-destructors ;

M: ssl-handle dispose*
    [
        ! Free file>> after SSL_free
        [ file>> &dispose drop ]
        [ handle>> SSL_free ] bi
    ] with-destructors ;

: check-verify-result ( ssl-handle -- )
    SSL_get_verify_result dup X509_V_OK =
    [ drop ] [ verify-message certificate-verify-error ] if ;

: common-name ( certificate -- host )
    X509_get_subject_name
    NID_commonName 256 <byte-array>
    [ 256 X509_NAME_get_text_by_NID ] keep
    swap -1 = [ drop f ] [ latin1 alien>string ] if ;

: common-names-match? ( expected actual -- ? )
    [ >lower ] bi@ "*." ?head [ tail? ] [ = ] if ;

: check-common-name ( host ssl-handle -- )
    SSL_get_peer_certificate common-name
    2dup common-names-match?
    [ 2drop ] [ common-name-verify-error ] if ;

M: openssl check-certificate ( host ssl -- )
    current-secure-context config>> verify>> [
        handle>>
        [ nip check-verify-result ]
        [ check-common-name ]
        2bi
    ] [ 2drop ] if ;

: get-session ( addrspec -- session/f )
    current-secure-context sessions>> at ;

: save-session ( session addrspec -- )
    current-secure-context sessions>> set-at ;

openssl secure-socket-backend set-global
