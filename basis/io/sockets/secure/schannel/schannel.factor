! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings arrays
byte-arrays classes.struct combinators combinators.short-circuit
continuations destructors endian io io.buffers io.encodings.binary
io.encodings.string io.encodings.utf16 io.encodings.utf8 io.files
io.ports io.sockets io.sockets.private
io.sockets.secure io.sockets.secure.openssl io.sockets.secure.windows
io.timeouts kernel libc literals locals math math.bitwise math.order
namespaces sequences specialized-arrays summary
windows.crypt32 windows.errors windows.schannel windows.types ;
FROM: io.sockets.secure.openssl.private => alpn-wire-format ;
IN: io.sockets.secure.schannel

SPECIALIZED-ARRAY: SecBuffer

SINGLETON: schannel
M: schannel ssl-supported? t ;
M: schannel ssl-certificate-verification-supported? t ;
M: schannel default-tls-method TLS ;

ERROR: schannel-error status ;
ERROR: unsupported-schannel-config option ;
ERROR: schannel-hostname-required ;
ERROR: invalid-schannel-hostname hostname ;
ERROR: schannel-handshake-too-large ;

M: schannel-error summary status>> n>win32-error-string ;
M: unsupported-schannel-config summary
    option>> "Schannel does not support " prepend ;

: check-schannel ( status -- )
    32 bits dup SEC_E_OK = [ drop ] [ schannel-error ] if ;

! Keep native handles out of the moving heap, including across socket waits.
: <security-handle> ( -- handle )
    SecHandle malloc-struct -1 >>lower -1 >>upper ;

: security-handle-valid? ( handle -- ? )
    lower>> ULONG_PTR heap-size 8 * bits
    ULONG_PTR heap-size 8 * 2^ 1 - = not ;

TUPLE: schannel-context < secure-context outbound inbound store certificate keys
    { users integer initial: 0 } ;

:: free-schannel-context ( context -- )
    context outbound>> [ [ FreeCredentialsHandle drop ] [ free ] bi ] when*
    context inbound>> [ [ FreeCredentialsHandle drop ] [ free ] bi ] when*
    context certificate>> [ CertFreeCertificateContext drop ] when*
    context keys>> [ 0 NCryptDeleteKey drop ] each
    context store>> [ 0 CertCloseStore drop ] when* ;

M: schannel-context dispose*
    dup users>> zero? [ free-schannel-context ] [ drop ] if ;

: release-schannel-context ( context -- )
    [ 1 - ] change-users
    dup [ users>> zero? ] [ disposed>> ] bi and
    [ free-schannel-context ] [ drop ] if ;

:: save-schannel-key ( certificate context -- )
    certificate CERT_KEY_PROV_INFO_PROP_ID f 0 DWORD <ref>
    CertGetCertificateContextProperty zero? [ ] [
        certificate CRYPT_ACQUIRE_SILENT_FLAG
        CRYPT_ACQUIRE_ONLY_NCRYPT_KEY_FLAG bitor f
        { ULONG_PTR DWORD BOOL } [
            CryptAcquireCertificatePrivateKey win32-error=0/f
        ] with-out-parameters 2drop :> key
        key context keys>> push
        context certificate>> [ ] [
            certificate CertDuplicateCertificateContext
            dup win32-error=0/f context certificate<<
        ] if
    ] if ;

:: load-schannel-certificate ( context -- )
    context config>> :> config
    config key-file>> [| path |
        [
            path binary file-contents :> bytes
            bytes malloc-byte-array &free :> data
            CRYPTOAPI_BLOB malloc-struct &free
                bytes length >>cbData data >>pbData
            config password>> "" or utf16n malloc-string &free
            ! Schannel obtains private keys through LSASS, which cannot use
            ! process-local ephemeral keys. Delete imported key containers
            ! when the last socket releases this context.
            PKCS12_ALWAYS_CNG_KSP PFXImportCertStore
            dup win32-error=0/f context store<<
            f :> certificate!
            [
                [
                    context store>> certificate CertEnumCertificatesInStore
                    certificate! certificate
                ] [ certificate context save-schannel-key ] while
            ] [ certificate [ CertFreeCertificateContext drop ] when* ] finally
            context certificate>>
            [ ] [ "key-file (private key missing)" unsupported-schannel-config ] if
        ] with-destructors
    ] when* ;

M: schannel <secure-context>
    [
        dup method>> { TLS TLSv1.2 } member?
        [ "method" unsupported-schannel-config ] unless
        dup ca-file>> [ "ca-file" unsupported-schannel-config ] when
        dup ca-path>> [ "ca-path" unsupported-schannel-config ] when
        schannel-context new-disposable swap >>config V{ } clone >>keys |dispose
        dup load-schannel-certificate
    ] with-destructors ;

SYMBOL: default-schannel-context

: current-schannel-context ( -- context )
    secure-context get [
        default-schannel-context [
            <secure-config> <secure-context>
        ] initialize-alien
    ] unless*
    dup schannel-context? [ "context" unsupported-schannel-config ] unless
    check-disposed ;

! Defaults to TLS 1.2 and newer; Windows chooses enabled cipher suites.
:: acquire-schannel-credential ( context server? -- credential )
    [
        <security-handle> |free :> credential
        TLS_PARAMETERS malloc-struct &free
            context config>> method>> TLSv1.2 = 0x33ff 0x03ff ?
            >>grbitDisabledProtocols :> protocols
        SCH_CREDENTIALS malloc-struct &free
            SCH_CREDENTIALS_VERSION >>dwVersion
            SCH_USE_STRONG_CRYPTO SCH_CRED_NO_DEFAULT_CREDS bitor
            context config>> verify>>
            SCH_CRED_AUTO_CRED_VALIDATION SCH_CRED_MANUAL_CRED_VALIDATION ?
            bitor >>dwFlags
            1 >>cTlsParameters protocols >>pTlsParameters :> auth
        context certificate>> [| certificate |
            certificate void* <ref> malloc-byte-array &free
            auth swap >>paCred 1 >>cCreds drop
        ] when*
        f "Microsoft Unified Security Protocol Provider" utf16n malloc-string &free
        server? SECPKG_CRED_INBOUND SECPKG_CRED_OUTBOUND ?
        f auth f f credential f AcquireCredentialsHandleW check-schannel
        credential
    ] with-destructors ;

:: schannel-credential ( context server? -- credential )
    server? [ context inbound>> ] [ context outbound>> ] if
    [
        server? context certificate>> not and
        [ "key-file (PKCS#12)" unsupported-schannel-config ] when
        context server? acquire-schannel-credential
        dup server? [ context inbound<< ] [ context outbound<< ] if
    ] unless* ;

TUPLE: schannel-handle < disposable file context handle input output hostname
    credential server? connected ended encrypted plaintext sizes alpn ;

M: schannel-handle windows-socket-handle file>> ;
M: schannel-handle timeout drop secure-socket-timeout get ;
M: schannel-handle cancel-operation file>> cancel-operation ;

M: schannel-handle dispose*
    [
        {
            [ file>> &dispose drop ]
            [ input>> [ &dispose drop ] when* ]
            [ output>> [
                dup buffer>> 0 swap buffer-reset &dispose drop
            ] when* ]
            [ handle>> [
                dup security-handle-valid? [ dup DeleteSecurityContext drop ] when
                free
            ] when* ]
            [ context>> [ release-schannel-context ] when* ]
        } cleave
    ] with-destructors ;

M: schannel <windows-secure-socket>
    dup [
        dup { [ empty? ] [ CHAR: \0 swap member? ] } 1||
        [ invalid-schannel-hostname ] [ drop ] if
    ] when*
    [
        schannel-handle new-disposable swap >>hostname swap >>file |dispose
        current-schannel-context [ 1 + ] change-users >>context
        <security-handle> >>handle
        dup file>> <input-port> >>input
        dup file>> <output-port> >>output
        B{ } clone >>encrypted B{ } clone >>plaintext
    ] with-destructors ;

! SSPI descriptors and their data are native only during a crypto call.
! Copy returned tokens before suspending for any network operation.
:: <sec-buffers> ( count -- buffers descriptor )
    count SecBuffer malloc-array dup >c-ptr &free drop :> buffers
    buffers SecBufferDesc malloc-struct &free
        count >>cBuffers buffers >c-ptr >>pBuffers ;

:: set-sec-buffer ( data count type index buffers -- )
    index buffers nth data >>pvBuffer count >>cbBuffer type >>BufferType drop ;

: sec-buffer-bytes ( buffer -- bytes )
    [ pvBuffer>> ] [ cbBuffer>> ] bi memory>byte-array ;

:: extra-sec-bytes ( bytes buffers -- extra )
    buffers [ BufferType>> SECBUFFER_EXTRA = ] find nip
    [| buffer |
        buffer pvBuffer>> [ buffer sec-buffer-bytes ] [
            bytes bytes length buffer cbBuffer>> - tail B{ } like
        ] if
    ]
    [ B{ } ] if* ;

! SEC_APPLICATION_PROTOCOLS contains a length, ALPN extension ID, and
! length-prefixed protocol names. Both client and server use this input.
: schannel-alpn ( protocols -- bytes )
    alpn-wire-format dup length 65535 <=
    [ ] [ "alpn-supported-protocols" unsupported-schannel-config ] if
    [ length 2 >le 2 4 >le prepend ] keep append
    dup length 4 >le prepend ;

:: handshake-step ( bytes socket -- status token extra )
    [
        3 <sec-buffers> :> ( inputs input )
        bytes malloc-byte-array &free bytes length SECBUFFER_TOKEN 0 inputs
        set-sec-buffer
        socket handle>> security-handle-valid? not
        socket context>> config>> alpn-supported-protocols>>
        dup empty? not rot and [
            schannel-alpn dup malloc-byte-array &free swap length
            SECBUFFER_APPLICATION_PROTOCOLS 2 inputs set-sec-buffer
        ] [ drop ] if
        1 <sec-buffers> :> ( outputs output )
        f 0 SECBUFFER_TOKEN 0 outputs set-sec-buffer
        0 ULONG <ref> malloc-byte-array &free :> attributes
        socket credential>>
        socket handle>> dup security-handle-valid? [ drop f ] unless
        socket server?>> [
            input ASC_REQ_CONFIDENTIALITY ASC_REQ_ALLOCATE_MEMORY bitor
            ASC_REQ_EXTENDED_ERROR bitor ASC_REQ_STREAM bitor
            0 socket handle>> output attributes f AcceptSecurityContext
        ] [
            socket hostname>> [ utf16n malloc-string &free ] [ f ] if*
            ISC_REQ_CONFIDENTIALITY ISC_REQ_ALLOCATE_MEMORY bitor
            ISC_REQ_EXTENDED_ERROR bitor ISC_REQ_STREAM bitor
            0 0 input 0 socket handle>> output attributes f
            InitializeSecurityContextW
        ] if 32 bits :> status
        outputs first :> token
        status
        [ token sec-buffer-bytes ]
        [ token pvBuffer>> [ FreeContextBuffer drop ] when* ] finally
        status SEC_E_INCOMPLETE_MESSAGE =
        [ bytes ] [ bytes inputs extra-sec-bytes ] if
    ] with-destructors ;

:: read-encrypted ( socket -- )
    65536 socket input>> stream-read-partial
    dup empty? [ drop premature-close-error ] [
        socket encrypted>> prepend socket encrypted<<
    ] if ;

:: write-encrypted ( bytes socket -- )
    bytes empty? [ ] [
        bytes socket output>> stream-write socket output>> stream-flush
    ] if ;

DEFER: query-schannel-alpn

:: schannel-handshake-loop ( socket -- )
    socket encrypted>> length 1048576 > [ schannel-handshake-too-large ] when
    socket encrypted>> socket handshake-step :> ( status token extra )
    extra socket encrypted<<
    status { $ SEC_E_OK $ SEC_I_CONTINUE_NEEDED $ SEC_E_INCOMPLETE_MESSAGE } member?
    [ ] [ status check-schannel ] if
    token socket write-encrypted
    status SEC_E_OK = [
        SecPkgContext_StreamSizes new :> sizes
        socket handle>> SECPKG_ATTR_STREAM_SIZES sizes
        QueryContextAttributesW check-schannel
        socket connected>> [ ] [
            socket query-schannel-alpn socket alpn<<
        ] if
        sizes socket sizes<< t socket connected<<
    ] [
        status SEC_E_INCOMPLETE_MESSAGE = extra empty? or
        [ socket read-encrypted ] when
        socket schannel-handshake-loop
    ] if ;

:: begin-schannel ( socket server? -- )
    server? socket server?<<
    server? not socket context>> config>> verify>> and
    socket hostname>> not and [ schannel-hostname-required ] when
    socket context>> server? schannel-credential socket credential<<
    socket [
        server? [ dup read-encrypted ] when schannel-handshake-loop
    ] with-timeout ;

: ensure-schannel-handshake ( socket -- )
    check-disposed
    dup connected>> [ drop ] [ t begin-schannel ] if ;

:: query-schannel-alpn ( socket -- protocol/f )
    SecPkgContext_ApplicationProtocol new :> protocol
    socket handle>> SECPKG_ATTR_APPLICATION_PROTOCOL protocol
    QueryContextAttributesW check-schannel
    protocol ProtoNegoStatus>> 1 = [
        protocol ProtocolId>> protocol ProtocolIdSize>> head
        B{ } like utf8 decode
    ] [ f ] if ;

! TLS 1.3 post-handshake processing can clear SSPI's ALPN attribute.
! The protocol selected by the initial handshake remains the connection's
! protocol, so retain it independently of subsequent context updates.
: schannel-alpn-protocol ( socket -- protocol/f )
    check-disposed alpn>> ;

M: schannel establish-secure-connection
    drop handle>> f begin-schannel ;

! Verification is performed by Schannel during the handshake, including
! the peer name passed to InitializeSecurityContextW.
M: schannel check-certificate 2drop ;

:: decrypt-step ( socket -- status plain extra )
    [
        socket encrypted>> :> bytes
        bytes malloc-byte-array &free :> data
        4 <sec-buffers> :> ( buffers descriptor )
        data bytes length SECBUFFER_DATA 0 buffers set-sec-buffer
        socket handle>> descriptor 0 f DecryptMessage 32 bits :> status
        status
        buffers [ BufferType>> SECBUFFER_DATA = ] find nip
        status { $ SEC_E_OK $ SEC_I_RENEGOTIATE } member?
        [ [ sec-buffer-bytes ] [ B{ } ] if* ] [ drop B{ } ] if
        status SEC_E_INCOMPLETE_MESSAGE =
        [ bytes ] [ bytes buffers extra-sec-bytes ] if
    ] with-destructors ;

:: schannel-read ( socket -- )
    socket plaintext>> empty? socket ended>> not and [
        socket encrypted>> empty? [ socket read-encrypted ] when
        socket decrypt-step :> ( status plain extra )
        plain socket plaintext<< extra socket encrypted<<
        status {
            { $ SEC_E_OK [ ] }
            { $ SEC_E_INCOMPLETE_MESSAGE [ socket read-encrypted ] }
            { $ SEC_I_CONTEXT_EXPIRED [ t socket ended<< ] }
            { $ SEC_I_RENEGOTIATE [ socket schannel-handshake-loop ] }
            [ check-schannel ]
        } case
        socket schannel-read
    ] when ;

M:: schannel-handle refill ( port socket -- event/f )
    socket ensure-schannel-handshake
    port [ drop socket schannel-read ] with-timeout
    port check-disposed drop
    socket plaintext>> :> bytes
    bytes length port buffer>> buffer-capacity min :> count
    bytes count port buffer>> buffer-write
    bytes count tail B{ } like socket plaintext<< f ;

:: encrypt-step ( bytes socket -- encrypted )
    [
        socket sizes>> :> sizes
        sizes cbHeader>> :> header
        sizes cbTrailer>> :> trailer
        header bytes length + trailer + malloc &free :> data
        header data <displaced-alien> bytes bytes length memcpy
        4 <sec-buffers> :> ( buffers descriptor )
        data header SECBUFFER_STREAM_HEADER 0 buffers set-sec-buffer
        header data <displaced-alien> bytes length SECBUFFER_DATA 1 buffers
        set-sec-buffer
        header bytes length + data <displaced-alien>
        trailer SECBUFFER_STREAM_TRAILER 2 buffers set-sec-buffer
        socket handle>> 0 descriptor 0 EncryptMessage check-schannel
        buffers [ sec-buffer-bytes ] { } map-as B{ } concat-as
    ] with-destructors ;

M:: schannel-handle drain ( port socket -- event/f )
    socket ensure-schannel-handshake
    port [| port |
        port buffer>> :> buffer
        buffer buffer-length socket sizes>> cbMaximumMessage>> min :> count
        buffer buffer@ count memory>byte-array socket encrypt-step
        socket write-encrypted
        count buffer buffer-consume
    ] with-timeout f ;

M:: schannel-handle shutdown ( socket -- )
    socket disposed>> not socket connected>> and socket ended>> not and [
        socket [| socket |
            [
                1 <sec-buffers> :> ( buffers descriptor )
                SCHANNEL_SHUTDOWN ULONG <ref> malloc-byte-array &free
                ULONG heap-size SECBUFFER_TOKEN 0 buffers set-sec-buffer
                socket handle>> descriptor ApplyControlToken check-schannel
            ] with-destructors
            B{ } socket handshake-step :> ( status token extra )
            status check-schannel token socket write-encrypted
            t socket ended<<
        ] with-timeout
    ] when ;

M: schannel send-secure-handshake
    input/output-ports
    dup handle>> non-ssl-socket? [ upgrade-on-non-socket ] unless
    [
        remote-address get secure-hostname <windows-secure-socket>
    ] change-handle handle>> >>handle drop
    output-stream get underlying-port handle>> f begin-schannel ;

M: schannel accept-secure-handshake
    input/output-ports
    dup handle>> non-ssl-socket? [ upgrade-on-non-socket ] unless
    [ f <windows-secure-socket> ] change-handle handle>> >>handle drop ;

! Dynamic selection keeps existing sockets bound to their original backend.
: with-schannel ( quot -- )
    schannel secure-socket-backend rot with-variable ; inline

secure-socket-backend [ schannel ] initialize
