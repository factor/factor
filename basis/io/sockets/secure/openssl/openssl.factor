! Copyright (C) 2007, 2008, Slava Pestov, Elie CHAFTARI.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.enums
alien.libraries.finder alien.strings assocs byte-arrays
classes.struct combinators combinators.short-circuit continuations destructors
endian io io.backend io.buffers io.encodings.latin1
io.encodings.string io.encodings.utf8 io.files io.pathnames
io.ports io.sockets io.sockets.secure io.timeouts kernel libc
math math.functions math.order math.parser namespaces openssl
openssl.libcrypto openssl.libssl random sequences sets splitting
system unicode ;
IN: io.sockets.secure.openssl

GENERIC: ssl-method ( symbol -- method )
M: TLS ssl-method drop TLS_method ;
M: TLSv1 ssl-method drop TLSv1_method ;
M: TLSv1.1 ssl-method drop TLSv1_1_method ;
M: TLSv1.2 ssl-method drop TLSv1_2_method ;

CONSTANT: weak-ciphers-for-compatibility
    {
        ! Weak 12/28/2021, included for compatibility for now
        "ECDHE-ECDSA-AES256-SHA384"
        "ECDHE-ECDSA-AES128-SHA256"
        "ECDHE-RSA-AES256-GCM-SHA384"
        "ECDHE-RSA-AES256-SHA384"
        "ECDHE-RSA-AES128-SHA256"
        "ECDHE-RSA-CAMELLIA256-SHA384"
        "ECDHE-RSA-CAMELLIA128-SHA256"
        "ECDHE-ECDSA-CAMELLIA256-SHA384"
        "ECDHE-ECDSA-CAMELLIA128-SHA256"
        "AES256-SHA"
        "AES128-SHA256"
        "AES128-SHA"
        "CAMELLIA256-SHA"
        "CAMELLIA128-SHA"
        "IDEA-CBC-SHA"
        "DES-CBC3-SHA"
    }

MEMO: make-cipher-list ( -- string )
    {
        ! https://ciphersuite.info/cs/?security=recommended&software=openssl&singlepage=true
        ! Recommended 2/16/2023
        "ECDHE-ECDSA-AES256-GCM-SHA384"
        "ECDHE-ECDSA-AES128-GCM-SHA256"
        "ECDHE-ECDSA-CHACHA20-POLY1305"
        "ECDHE-PSK-CHACHA20-POLY1305"
        "DHE-DSS-AES256-GCM-SHA384"
        "DHE-DSS-AES128-GCM-SHA256"
        "DHE-PSK-AES256-GCM-SHA384"
        "DHE-PSK-AES128-GCM-SHA256"
        "DHE-PSK-CHACHA20-POLY1305"
        "TLS_AES_128_GCM_SHA256"
        "TLS_AES_256_GCM_SHA384"

        ! Secure 12/28/2021
        "ECDHE-RSA-AES128-GCM-SHA256"
        "ECDHE-RSA-CHACHA20-POLY1305"
        "ECDHE-ECDSA-AES256-CCM8"
        "ECDHE-ECDSA-AES256-CCM"
        "ECDHE-ECDSA-AES128-CCM8"
        "ECDHE-ECDSA-AES128-CCM"
    }
    ! XXX: Weak ciphers
    weak-ciphers-for-compatibility append
    ":" join ;

TUPLE: openssl-context < secure-context aliens sessions
    { users integer initial: 0 } ;

<PRIVATE

: bn-bytes-needed ( num -- bytes-required )
    log2 1 + 8 / ceiling ;

PRIVATE>

: number>bn ( num -- bn )
    dup bn-bytes-needed >be
    dup length
    f BN_bin2bn ; inline

: add-ctx-flag ( ctx flag -- )
    [ handle>> ] dip
    over SSL_CTX_get_options bitor
    SSL_CTX_set_options ssl-error ;

: clear-ctx-flag ( ctx flag -- )
    [ handle>> ] dip
    over SSL_CTX_get_options bitnot bitand
    SSL_CTX_set_options ssl-error ;

: disable-old-tls ( ctx -- )
    SSL_OP_NO_TLSv1 SSL_OP_NO_TLSv1_1 bitor add-ctx-flag ;

: ignore-unexpected-eof ( ctx -- )
    SSL_OP_IGNORE_UNEXPECTED_EOF add-ctx-flag ;

: set-session-cache ( ctx -- )
    handle>>
    [ SSL_SESS_CACHE_BOTH SSL_CTX_set_session_cache_mode ssl-error ]
    [ 32 random-bits >hex dup length SSL_CTX_set_session_id_context ssl-error ]
    bi ;

ERROR: file-expected path ;

: ensure-exists ( path -- path )
    [ file-exists? ] 1check [ file-expected ] unless ; inline

: ssl-file-path ( path -- path' )
    absolute-path ensure-exists ;

: load-certificate-chain ( ctx -- )
    [ config>> key-file>> ] 1check
    [
        [ handle>> ] [ config>> key-file>> ssl-file-path ] bi
        SSL_CTX_use_certificate_chain_file
        ssl-error
    ] [ drop ] if ;

: password-callback ( -- alien )
    int { void* int bool void* } cdecl
    [| buf size rwflag password! |
        password [ B{ 0 } password! ] unless

        password strlen size 0 max min :> len
        buf password len memcpy
        len
    ] alien-callback ;

: default-pasword ( ctx -- alien )
    [ config>> password>> latin1 malloc-string ] [ aliens>> ] bi
    [ push ] keepd ;

: set-default-password ( ctx -- )
    [ config>> password>> ] 1check
    [
        [ handle>> password-callback SSL_CTX_set_default_passwd_cb ]
        [
            [ handle>> ] [ default-pasword ] bi
            SSL_CTX_set_default_passwd_cb_userdata
        ] bi
    ] [ drop ] if ;

: use-private-key-file ( ctx -- )
    [ config>> key-file>> ] 1check
    [
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
            [ ca-file>> [ ssl-file-path ] ?call ]
            [ ca-path>> [ ssl-file-path ] ?call ] bi
        ] bi
        SSL_CTX_load_verify_locations
    ] [ handle>> SSL_CTX_set_default_verify_paths ] if ssl-error ;

: set-verify-depth ( ctx -- )
    [ config>> verify-depth>> ]
    [
        [ handle>> ] [ config>> verify-depth>> ] bi
        SSL_CTX_set_verify_depth
    ] [ drop ] 1if ;

TUPLE: bio < disposable handle ;

: <bio> ( handle -- bio ) bio new-disposable swap >>handle ;

M: bio dispose* handle>> BIO_free ssl-error ;

: <file-bio> ( path -- bio )
    normalize-path "r" BIO_new_file dup ssl-error <bio> ;

: load-dh-params ( ctx -- )
    [ config>> dh-file>> ]
    [
        [ handle>> ] [ config>> dh-file>> ] bi <file-bio> &dispose
        handle>> f f f PEM_read_bio_DHparams dup ssl-error
        dup '[ _ DH_free ] [ SSL_CTX_set_tmp_dh ssl-error ] swap finally
    ] [ drop ] 1if ;

! Attempt to set ecdh. If it fails, ignore...?
: set-ecdh-params ( ctx -- )
    handle>> SSL_CTRL_SET_ECDH_AUTO 1 f SSL_CTX_ctrl drop ;

: <openssl-context> ( config ctx -- context )
    openssl-context new-disposable
        swap >>handle
        swap >>config
        V{ } clone >>aliens
        H{ } clone >>sessions ;

DEFER: configure-alpn

M: openssl <secure-context>
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
            [ configure-alpn ]
            [ os macos? [ drop ] [ ignore-unexpected-eof ] if ]
            [ ]
        } cleave
    ] with-destructors ;

: free-context ( ctx -- )
    [
        [ aliens>> [ &free drop ] each ]
        [ sessions>> values [ SSL_SESSION_free ] each ]
        [ handle>> SSL_CTX_free ]
        tri
    ] with-destructors ;

M: openssl-context dispose*
    dup users>> zero? [ free-context ] [ drop ] if ;

: release-context ( ctx -- )
    [ 1 - ] change-users
    dup [ disposed>> ] [ users>> zero? ] bi and
    [ free-context ] [ drop ] if ;

TUPLE: ssl-handle < disposable file handle connected terminated context ;

SYMBOL: default-secure-context

: current-secure-context ( -- ctx )
    secure-context get [
        default-secure-context [
            <secure-config> <secure-context>
        ] initialize-alien
    ] unless* ;

: get-session ( addrspec -- session/f )
    current-secure-context sessions>> at ;

! Limit retained native session references for clients visiting many hosts.
CONSTANT: max-cached-sessions 256

:: save-session ( session addrspec -- )
    current-secure-context sessions>> :> sessions
    addrspec sessions delete-at* [ SSL_SESSION_free ] [ drop ] if
    session [
        ! Bound the cache and release the reference replaced by a racing connect.
        sessions assoc-size max-cached-sessions >= [
            sessions keys first sessions delete-at* drop SSL_SESSION_free
        ] when
        session addrspec sessions set-at
    ] when ;

: set-secure-cipher-list-only ( ssl -- ssl )
    dup handle>> make-cipher-list SSL_set_cipher_list ssl-error ;

: <ssl-handle> ( fd -- ssl )
    [
        ssl-handle new-disposable swap >>file |dispose
        current-secure-context check-disposed [ 1 + ] change-users
        >>context dup context>> handle>> SSL_new
        dup ssl-error >>handle
        set-secure-cipher-list-only
    ] with-destructors ;

<PRIVATE

ERROR: invalid-alpn-protocol protocol ;

: alpn-wire-format ( protocols -- bytes )
    [
        utf8 encode dup length dup 1 255 between?
        [ prefix ] [ drop invalid-alpn-protocol ] if
    ] map B{ } concat-as ;

STRUCT: alpn-protocols
    { data void* }
    { length uint } ;

: alpn_select_cb_func ( -- alien )
    [| ssl out outlen in inlen arg |
        ! Preserve server preference. Both candidate buffers are native;
        ! context userdata stays alive until the last SSL is freed.
        out outlen
        arg alpn-protocols memory>struct [ data>> ] [ length>> ] bi
        in inlen
        SSL_select_next_proto OPENSSL_NPN_NEGOTIATED =
        [ SSL_TLSEXT_ERR_OK ] [ SSL_TLSEXT_ERR_ALERT_FATAL ] if
    ] SSL_CTX_alpn_select_cb_func ;

: get_alpn_selected_wrapper ( ssl* -- alpn_string/f )
    { void* uint } [ SSL_get0_alpn_selected ] with-out-parameters
    dup zero? [ 2drop f ] [ memory>byte-array utf8 decode ] if ;

PRIVATE>

:: configure-alpn ( ctx -- )
    ctx config>> alpn-supported-protocols>> dup empty? [ drop ] [
        alpn-wire-format :> wire
        ctx handle>> wire dup length SSL_CTX_set_alpn_protos
        zero? [ throw-ssl-error ] unless
        wire malloc-byte-array dup ctx aliens>> push :> data
        alpn-protocols malloc-struct dup ctx aliens>> push
        data >>data wire length >>length :> protocols
        ctx handle>> alpn_select_cb_func protocols SSL_CTX_set_alpn_select_cb
    ] if ;

DEFER: ip-host?

:: <ssl-socket> ( winsock hostname -- ssl )
    [
        winsock |dispose <ssl-handle> |dispose :> handle
        handle handle>> :> native-handle
        winsock socket-handle BIO_NOCLOSE BIO_new_socket dup ssl-error :> bio
        ! Transfer the BIO to SSL before any further fallible setup.
        native-handle bio bio SSL_set_bio
        hostname [
            dup ip-host? [ drop ] [
                utf8 string>alien
                native-handle swap SSL_set_tlsext_host_name ssl-error
            ] if
        ] when*
        handle
    ] with-destructors ;

:: (ssl-error-syscall) ( ssl-handle ret system-error -- event/f )
    ssl-handle f >>connected t >>terminated drop
    ERR_get_error dup zero? [
        drop ret zero? [ f ] [
            system-error dup ECONNRESET = [ drop premature-close-error ]
            [ dup zero? [ drop premature-close-error ] [ (throw-errno) ] if ] if
        ] if
    ] [ (ssl-error-string) throw ] if ;

: ssl-error-syscall ( ssl-handle -- event/f )
    -1 errno (ssl-error-syscall) ;

:: check-ssl-error ( ssl-handle ret -- event/f )
    errno :> system-error
    ssl-handle handle>> ret SSL_get_error {
        { SSL_ERROR_NONE [ f ] }
        { SSL_ERROR_WANT_READ [ +input+ ] }
        { SSL_ERROR_WANT_WRITE [ +output+ ] }
        { SSL_ERROR_SYSCALL [ ssl-handle ret system-error (ssl-error-syscall) ] }
        { SSL_ERROR_SSL [
            ssl-handle f >>connected t >>terminated drop throw-ssl-error
        ] }
        { SSL_ERROR_ZERO_RETURN [ f ] }
        { SSL_ERROR_WANT_ACCEPT [ +input+ ] }
        { SSL_ERROR_WANT_CONNECT [ +output+ ] }
    } case ;

! Accept
: check-handshake-result ( ssl-handle ret -- event/f )
    over [ check-ssl-error ] dip over [ drop ] [
        f >>connected t >>terminated drop
        premature-close-error
    ] if ;

: do-ssl-accept-once ( ssl-handle -- event/f )
    dup handle>> ERR_clear_error SSL_accept
    dup 1 = [ 2drop f ] [ check-handshake-result ] if ;

: do-ssl-accept ( ssl-handle -- )
    dup do-ssl-accept-once
    [ [ dup file>> ] dip wait-for-fd do-ssl-accept ] [ drop ] if* ;

: maybe-handshake ( ssl-handle -- ssl-handle )
    dup [ connected>> ] [ terminated>> ] bi or [
        [ [ do-ssl-accept ] with-timeout ]
        [ t >>connected ] bi
    ] unless ;

! Input ports
: do-ssl-read ( buffer ssl-handle -- event/f )
    2dup handle>> swap [ buffer-end ] [ buffer-capacity ] bi
    ERR_clear_error SSL_read dup 0 >
    [ nip swap buffer+ f ] [ check-ssl-error nip ] if ;

: throw-if-terminated ( ssl-handle -- ssl-handle )
    dup terminated>> [ premature-close-error ] when ;

M: ssl-handle refill
    throw-if-terminated
    [ buffer>> ] [ maybe-handshake ] bi* do-ssl-read ;

! Output ports
: do-ssl-write ( buffer ssl-handle -- event/f )
    2dup handle>> swap [ buffer@ ] [ buffer-length ] bi
    ERR_clear_error SSL_write dup 0 > [
        nip over buffer-consume buffer-empty? f +output+ ?
    ] [ check-ssl-error nip ] if ;

M: ssl-handle drain
    throw-if-terminated
    [ buffer>> ] [ maybe-handshake ] bi* do-ssl-write ;

! Connect
: do-ssl-connect-once ( ssl-handle -- event/f )
    dup handle>> ERR_clear_error SSL_connect
    dup 1 = [ 2drop f ] [ check-handshake-result ] if ;

: do-ssl-connect ( ssl-handle -- )
    dup do-ssl-connect-once
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
            _
            [ get-session ] [ resume-session ] [ begin-session ] ?if
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
        [
            [ handle>> SSL_free ]
            [ context>> [ release-context ] when* ] bi
        ] bi
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
    [
        [
            name-stack>sequence [ type>> GEN_DNS = ] filter
            [ d>> dNSName>> [ data>> ] [ length>> ] bi
              memory>byte-array utf8 decode ] map
        ] over '[ _ GENERAL_NAMES_free ] finally
    ] [ { } ] if* ;

! A wildcard matches exactly one nonempty DNS label.
: subject-names-match? ( name pattern -- ? )
    [ >lower ] bi@
    "*." ?head [
        {
            [ "." prepend tail? ]
            [ [ [ CHAR: . = ] count ] bi@ - 1 = ]
            [ [ length ] bi@ - 1 > ]
        } 2&&
    ] [
        =
    ] if ;

: ip-host? ( host -- ? )
    dup ":" swap subseq? [ drop t ] [
        [ <ipv4> drop t ] [ 2drop f ] recover
    ] if ;

:: certificate-matches? ( host certificate -- ? )
    CHAR: \0 host member? [ f ] [
        host ip-host? [
            certificate host 0 X509_check_ip_asc
        ] [
            certificate host host utf8 encode length
            X509_CHECK_FLAG_NO_PARTIAL_WILDCARDS f X509_check_host
        ] if 1 =
    ] if ;

:: check-subject-name ( host ssl-handle -- )
    [
        ssl-handle get-ssl-peer-certificate
        [ &X509_free ] [ certificate-missing-error ] if* :> certificate
        host certificate certificate-matches? [
            host certificate subject-name subject-name-verify-error
        ] unless
    ] with-destructors ;

M: openssl check-certificate
    dup context>> config>> verify>> [
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

: (make-input/output-secure) ( input output hostname -- )
    [
        dup handle>> non-ssl-socket? [ upgrade-on-non-socket ] unless
    ] dip
    '[ _ <ssl-socket> ] change-handle
    handle>> >>handle drop ;

: make-input/output-secure ( input output -- )
    f (make-input/output-secure) ;

: (send-secure-handshake) ( output -- )
    remote-address get [ upgrade-on-non-socket ] unless*
    secure-connection ;

M: openssl send-secure-handshake
    input/output-ports
    [ remote-address get secure-hostname (make-input/output-secure) ]
    [ nip (send-secure-handshake) ]
    [
        nip remote-address get secure-hostname dup [
            swap handle>> check-certificate
        ] [ 2drop ] if
    ] 2tri ;

M: openssl accept-secure-handshake
    input/output-ports
    make-input/output-secure ;

openssl secure-socket-backend set-global
