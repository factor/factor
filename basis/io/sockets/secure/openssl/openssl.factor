! Copyright (C) 2007, 2008, Slava Pestov, Elie CHAFTARI.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.enums
alien.strings assocs byte-arrays classes.struct combinators
combinators.short-circuit destructors fry io io.backend
io.binary io.buffers io.encodings.latin1 io.encodings.utf8
io.files io.pathnames io.ports io.sockets io.sockets.secure
io.timeouts kernel libc locals math math.functions math.order
math.parser memoize namespaces openssl openssl.libcrypto
openssl.libssl random sequences sets splitting unicode ;
IN: io.sockets.secure.openssl

GENERIC: ssl-method ( symbol -- method )
M: TLSv1 ssl-method drop TLSv1_method ;
M: TLSv1.1 ssl-method drop TLSv1_1_method ;
M: TLSv1.2 ssl-method drop TLSv1_2_method ;

MEMO: make-cipher-list ( -- string )
    {
        "ECDHE-ECDSA-AES256-GCM-SHA384"
        "ECDHE-ECDSA-AES256-SHA384"
        "ECDHE-ECDSA-AES128-GCM-SHA256"
        "ECDHE-ECDSA-AES128-SHA256"
        "ECDHE-RSA-AES256-GCM-SHA384"
        "ECDHE-RSA-AES256-SHA384"
        "ECDHE-RSA-AES128-GCM-SHA256"
        "ECDHE-RSA-AES128-SHA256"
        "ECDHE-ECDSA-AES256-CCM8"
        "ECDHE-ECDSA-AES256-CCM"
        "ECDHE-ECDSA-AES128-CCM8"
        "ECDHE-ECDSA-AES128-CCM"
        "ECDHE-ECDSA-CAMELLIA256-SHA384"
        "ECDHE-RSA-CAMELLIA256-SHA384"
        "ECDHE-ECDSA-CAMELLIA128-SHA256"
        "ECDHE-RSA-CAMELLIA128-SHA256"
        "ECDHE-RSA-CHACHA20-POLY1305"
        "ECDHE-ECDSA-CHACHA20-POLY1305"
        "ECDHE-PSK-CHACHA20-POLY1305"
        "AES256-SHA"
        "AES128-SHA256"
        "AES128-SHA"
        "CAMELLIA256-SHA"
        "CAMELLIA128-SHA"
        "IDEA-CBC-SHA"
        "DES-CBC3-SHA"
    } ":" join ;

TUPLE: openssl-context < secure-context aliens sessions ;

<PRIVATE

: bn-bytes-needed ( num -- bytes-required )
    log2 1 + 8 / ceiling ;

PRIVATE>

: number>bn ( num -- bn )
    dup bn-bytes-needed >be
    dup length
    f BN_bin2bn ; inline

: set-session-cache ( ctx -- )
    handle>>
    [ SSL_SESS_CACHE_BOTH SSL_CTX_set_session_cache_mode ssl-error ]
    [ 32 random-bits >hex dup length SSL_CTX_set_session_id_context ssl-error ]
    bi ;

ERROR: file-expected path ;

: ensure-exists ( path -- path )
    dup exists? [ file-expected ] unless ; inline

: ssl-file-path ( path -- path' )
    absolute-path ensure-exists ;

: load-certificate-chain ( ctx -- )
    dup config>> key-file>> [
        [ handle>> ] [ config>> key-file>> ssl-file-path ] bi
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
        [ handle>> ]
        [ config>> key-file>> ssl-file-path ] bi
        SSL_FILETYPE_PEM SSL_CTX_use_PrivateKey_file
        ssl-error
    ] [ drop ] if ;

: load-verify-locations ( ctx -- )
    dup config>> [ ca-file>> ] [ ca-path>> ] bi or [
        [ handle>> ]
        [
            config>>
            [ ca-file>> dup [ ssl-file-path ] when ]
            [ ca-path>> dup [ ssl-file-path ] when ] bi
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

! Attempt to set ecdh. If it fails, ignore...?
: set-ecdh-params ( ctx -- )
    handle>> SSL_CTRL_SET_ECDH_AUTO 1 f SSL_CTX_ctrl drop ;

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
            [ set-ecdh-params ]
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

: get-session ( addrspec -- session/f )
    current-secure-context sessions>> at ;

: save-session ( session addrspec -- )
    current-secure-context sessions>> set-at ;

: set-secure-cipher-list-only ( ssl -- ssl )
    dup handle>> make-cipher-list SSL_set_cipher_list ssl-error ;

: <ssl-handle> ( fd -- ssl )
    [
        ssl-handle new-disposable |dispose
        current-secure-context handle>> SSL_new
        dup ssl-error >>handle
        swap >>file
        set-secure-cipher-list-only
    ] with-destructors ;

:: <ssl-socket> ( winsock hostname -- ssl )
    winsock socket-handle BIO_NOCLOSE BIO_new_socket dup ssl-error :> bio
    winsock <ssl-handle> :> handle
    handle handle>> :> native-handle
    hostname [
        utf8 string>alien
        native-handle swap SSL_set_tlsext_host_name ssl-error
    ] when*
    native-handle bio bio SSL_set_bio
    handle ;

! Error handling
: syscall-error ( r -- event )
    ERR_get_error [
        {
            { -1 [
                errno ECONNRESET = [ premature-close ]
                [ throw-errno ] if
            ] }
            ! OpenSSL docs say this it is an error condition for
            ! a server to not send a close notify, but web
            ! servers in the wild don't seem to do this, for
            ! example https://www.google.com.
            { 0 [ f ] }
        } case
    ] [ nip (ssl-error) ] if-zero ;

: check-ssl-error ( ssl ret exra-cases/f -- event/f )
    [ tuck SSL_get_error ] dip
    {
        { SSL_ERROR_NONE [ drop f ] }
        { SSL_ERROR_WANT_READ [ drop +input+ ] }
        { SSL_ERROR_WANT_WRITE [ drop +output+ ] }
        { SSL_ERROR_SYSCALL [ syscall-error ] }
        { SSL_ERROR_SSL [ drop (ssl-error) ] }
    } append [ [ execute( -- n ) ] dip ] assoc-map
    at [ call( x -- y ) ] [ no-cond ] if* ;

! Accept
: do-ssl-accept-once ( ssl -- event/f )
    dup SSL_accept {
        { SSL_ERROR_ZERO_RETURN [ (ssl-error) ] }
        { SSL_ERROR_WANT_ACCEPT [ drop +input+ ] }
    } check-ssl-error ;

: do-ssl-accept ( ssl-handle -- )
    dup handle>> do-ssl-accept-once
    [ [ dup file>> ] dip wait-for-fd do-ssl-accept ] [ drop ] if* ;

: maybe-handshake ( ssl-handle -- )
    dup connected>> [ drop ] [
        [ [ do-ssl-accept ] with-timeout ]
        [ t swap connected<< ] bi
    ] if ;

! Input ports
: do-ssl-read ( buffer ssl -- event/f )
    2dup swap [ buffer-end ] [ buffer-capacity ] bi SSL_read [
        { { SSL_ERROR_ZERO_RETURN [ drop f ] } } check-ssl-error
    ] keep swap [ 2nip ] [ swap buffer+ f ] if* ;

M: ssl-handle refill ( port handle -- event/f )
    dup maybe-handshake [ buffer>> ] [ handle>> ] bi* do-ssl-read ;

! Output ports
: do-ssl-write ( buffer ssl -- event/f )
    2dup swap [ buffer@ ] [ buffer-length ] bi SSL_write
    [ f check-ssl-error ] keep swap [ 2nip ] [ swap buffer-consume f ] if* ;

M: ssl-handle drain ( port handle -- event/f )
    dup maybe-handshake [ buffer>> ] [ handle>> ] bi* do-ssl-write ;

! Connect
: do-ssl-connect-once ( ssl -- event/f )
    dup SSL_connect f check-ssl-error ;

: do-ssl-connect ( ssl-handle -- )
    dup handle>> do-ssl-connect-once
    [ dupd wait-for-fd do-ssl-connect ] [ drop ] if* ;

: resume-session ( ssl-handle ssl-session -- )
    [ [ handle>> ] dip SSL_set_session ssl-error ]
    [ drop do-ssl-connect ]
    2bi ;

: begin-session ( ssl-handle addrspec -- )
    [ drop do-ssl-connect ]
    [ [ handle>> SSL_get1_session ] dip save-session ]
    2bi ;

: secure-connection ( client-out addrspec -- )
    [ handle>> ] dip
    [
        '[
            _ dup get-session
            [ resume-session ] [ begin-session ] ?if
        ] with-timeout
    ] [ drop t >>connected drop ] 2bi ;

M: ssl-handle timeout
    drop secure-socket-timeout get ;

M: ssl-handle cancel-operation
    file>> cancel-operation ;

M: ssl-handle dispose*
    [
        ! Free file>> after SSL_free
        [ file>> &dispose drop ]
        [ handle>> SSL_free ] bi
    ] with-destructors ;

: check-verify-result ( ssl-handle -- )
    SSL_get_verify_result X509_V_ERROR number>enum dup X509_V_ERR_OK =
    [ drop ] [ certificate-verify-error ] if ;

: x509name>string ( x509name -- string )
    NID_commonName 256 <byte-array>
    [ 256 X509_NAME_get_text_by_NID ] keep
    swap -1 = [ drop f ] [ latin1 alien>string ] if ;

: subject-name ( certificate -- host )
    X509_get_subject_name x509name>string ;

: issuer-name ( certificate -- issuer )
    X509_get_issuer_name x509name>string ;

: sk-value ( stack v -- obj )
    ssl-new-api? get-global [ OPENSSL_sk_value ] [ sk_value ] if ;

: sk-num ( stack -- num )
    ssl-new-api? get-global [ OPENSSL_sk_num ] [ sk_num ] if ;

: name-stack>sequence ( name-stack -- seq )
    dup sk-num <iota> [
        sk-value GENERAL_NAME_st memory>struct
    ] with map ;

: alternative-dns-names ( certificate -- dns-names )
    NID_subject_alt_name f f X509_get_ext_d2i
    [ name-stack>sequence ] [ f ] if*
    [ type>> GEN_DNS = ] filter
    [ d>> dNSName>> data>> utf8 alien>string ] map ;

! *.foo.com matches: foo.com, www.foo.com, a.foo.com
! *.bar.foo.com matches: bar.foo.com, www.bar.foo.com, b.bar.foo.com
: subject-names-match? ( name pattern -- ? )
    [ >lower ] bi@
    "*." ?head [
        {
            [ tail? ]
            [ [ [ CHAR: . = ] count ] bi@ - 1 <= ]
        } 2&&
    ] [
        =
    ] if ;

: check-subject-name ( host ssl-handle -- )
    SSL_get_peer_certificate [
        [ alternative-dns-names ]
        [ subject-name ] bi suffix members
        2dup [ subject-names-match? ] with any?
        [ 2drop ] [ subject-name-verify-error ] if
    ] [ certificate-missing-error ] if* ;

M: openssl check-certificate ( host ssl -- )
    current-secure-context config>> verify>> [
        handle>>
        [ nip check-verify-result ]
        [ check-subject-name ]
        2bi
    ] [ 2drop ] if ;

: check-buffer ( port -- port )
    dup buffer>> buffer-empty? [ upgrade-buffers-full ] unless ;

: input/output-ports ( -- input output )
    input-stream output-stream
    [ get underlying-port check-buffer ] bi@
    2dup [ handle>> ] bi@ eq? [ upgrade-on-non-socket ] unless ;

: make-input/output-secure ( input output -- )
    dup handle>> non-ssl-socket? [ upgrade-on-non-socket ] unless
    [ f <ssl-socket> ] change-handle
    handle>> >>handle drop ;

: (send-secure-handshake) ( output -- )
    remote-address get [ upgrade-on-non-socket ] unless*
    secure-connection ;

M: openssl send-secure-handshake
    input/output-ports
    [ make-input/output-secure ] keep
    [ (send-secure-handshake) ] keep
    remote-address get dup inet? [
        host>> swap handle>> check-certificate
    ] [ 2drop ] if ;

M: openssl accept-secure-handshake ( -- )
    input/output-ports
    make-input/output-secure ;

openssl secure-socket-backend set-global
