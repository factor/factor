USING: accessors bootstrap.image.download calendar classes
concurrency.conditions concurrency.mailboxes
concurrency.promises continuations destructors io
io.backend.unix io.encodings.ascii io.files.temp io.sockets
io.sockets.secure io.sockets.secure.debug io.sockets.secure.openssl
io.streams.duplex io.timeouts io.ports kernel namespaces sequences sets
openssl.libcrypto openssl.libssl strings system threads tools.test ;
FROM: namespaces => set ;
QUALIFIED-WITH: concurrency.messaging qm
USE: io.sockets.secure.openssl.private
IN: io.sockets.secure.tests

{ 1 0 } [ [ ] with-secure-context ] must-infer-as

! A queued OpenSSL error must retain its native diagnostic.
[
    [
        ERR_clear_error
        "missing/file.pem" "r" BIO_new_file drop
        ssl-handle new ssl-error-syscall
    ] with-test-directory
] [ string? ] must-fail-with

! SNI setup can fail after allocating SSL and its socket BIO.
! The failed constructor must release both the SSL handle and the fd.
{ t } [
    <secure-config> [
        disposables get cardinality
        [
            [
                "127.0.0.1" 0 <inet4> <datagram> &dispose
                handle>> 256 CHAR: x <string> <ssl-socket> dispose
            ] with-destructors
        ] must-fail
        disposables get cardinality =
    ] with-secure-context
] unit-test

:: server-test-with-config ( quot: ( remote -- ) config -- )
    [
        config [
            "127.0.0.1" 0 <inet4> f <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept quot curry with-stream
            ] with-disposal
        ] with-secure-context
    ] "SSL server test" spawn drop ;

: server-test ( quot: ( remote -- ) -- )
    <test-secure-config> server-test-with-config ;

: ?promise-test ( mailbox -- obj )
    500 milliseconds ?promise-timeout ;

: client-test ( -- string )
    <secure-config> f >>verify [
        "127.0.0.1" "port" get ?promise-test <inet4> f <secure> ascii <client> drop
        1 seconds
        [ stream-contents ] with-timeout*
    ] with-secure-context ;

! Simple test, write/read
{ "secure" } [
    <promise> "port" set
    [ class-of name>> write ] server-test
    client-test
] unit-test

! Now, see what happens if the server closes the connection prematurely
! [
!     <promise> "port" set
!     [
!         drop
!         input-stream get stream>> handle>> f >>connected drop
!     ] server-test
!     client-test
! ] [
!     os linux? [
!         ! XXX: we should throw premature-close-error here
!         "unexpected eof" subseq-index
!     ] [
!         premature-close-error?
!     ] if
! ] must-fail-with

! Now, try validating the certificate. This should fail because its
! actually an invalid certificate
[
    <promise> "port" set
    [ drop "hi" write ] server-test
    <secure-config> [
        "localhost" "port" get ?promise-test <inet> f <secure> ascii
        <client> drop dispose
    ] with-secure-context
] [ certificate-verify-error? ] must-fail-with

! Client-side handshake timeout
[
    <promise> "port" set
    [ 5 seconds sleep ] server-test
    1 seconds secure-socket-timeout [
        client-test
    ] with-variable
] [ io-timeout? ] must-fail-with

! Server-side handshake timeout
[
    <promise> "port" set

    [
        [
            "127.0.0.1" "port" get ?promise-test
            <inet4> ascii <client> drop &dispose 5 seconds sleep
        ] with-destructors
    ] "Silly client" spawn drop

    1 seconds secure-socket-timeout [
        [
            [
                "127.0.0.1" 0 <inet4> f <secure> ascii <server> [
                    dup addr>> addrspec>> port>> "port" get fulfill
                    accept drop &dispose dup stream-read1 drop
                ] with-disposal
            ] with-destructors
        ] with-test-context
    ] with-variable
] [ io-timeout? ] must-fail-with

{ } [
    [ download-my-image ] with-temp-directory
] unit-test

! Numeric endpoints must validate certificates too.
[
    <promise> "port" set
    [ drop "hi" write ] server-test
    <secure-config> [
        "127.0.0.1" "port" get ?promise-test <inet4> f <secure> ascii
        <client> drop dispose
    ] with-secure-context
] [ certificate-verify-error? ] must-fail-with

! Exercise server preference and userdata lifetime in a real handshake,
! even when the context owner is disposed before the lazy server handshake.
{ "h2" } [
    <promise> "port" set
    [ drop secure-context get dispose "hi" write ]
    <test-secure-config> { "h2" "http/1.1" } >>alpn-supported-protocols
    server-test-with-config
    <secure-config> f >>verify { "http/1.1" "h2" } >>alpn-supported-protocols [
        "127.0.0.1" "port" get ?promise-test <inet4> f <secure> ascii
        <client> drop [
            in>> underlying-port handle>> handle>> get_alpn_selected_wrapper
        ] with-disposal
    ] with-secure-context
] unit-test

! EOF before any TLS handshake must not produce a connected client stream.
[
    <promise> "port" set
    [ drop ] server-test
    <secure-config> f >>verify [
        "127.0.0.1" "port" get ?promise-test <inet4> f <secure> ascii
        <client> drop [ dispose ] ignore-errors
    ] with-secure-context
] must-fail
