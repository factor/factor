USING: accessors byte-arrays calendar concurrency.promises
continuations destructors io io.buffers io.encodings.ascii io.encodings.binary
io.ports io.sockets io.sockets.secure io.sockets.secure.openssl
io.sockets.secure.schannel
io.sockets.secure.windows
io.streams.duplex io.timeouts kernel locals math namespaces openssl sequences
threads tools.test windows.errors windows.schannel ;
IN: io.sockets.secure.schannel.tests

: <schannel-test-config> ( -- config )
    ! Self-signed localhost certificate, password "password", valid to 2126.
    ! It is a test fixture and is never added to a Windows trust store.
    <secure-config> f >>verify
        "vocab:io/sockets/secure/schannel/server.pfx" >>key-file
        "password" >>password ;

: <tls-server-config> ( -- config )
    secure-socket-backend get schannel = [ <schannel-test-config> ] [
        <secure-config> f >>verify
            "vocab:openssl/test-1.2/server.pem" >>key-file
            "password" >>password
    ] if ;

! Full duplex I/O uses many records and requires the waiting thread to yield.
! Read beyond the last byte to check the native close-notify path as well.
:: tls-echo ( server-backend client-backend method -- ? )
    server-backend secure-socket-backend [
        <tls-server-config> method >>method
        { "h2" "http/1.1" } >>alpn-supported-protocols [
            [
                "127.0.0.1" 0 <inet4> f <secure> binary <server> &dispose :> server
                4096 256 <iota> B{ } like <repetition> B{ } concat-as :> contents
                <promise> :> done
                [
                    [
                        server accept drop [
                            5 seconds input-stream get set-timeout
                            5 seconds output-stream get set-timeout
                            contents length read contents assert=
                            20 milliseconds sleep contents write flush
                        ] with-stream t
                    ] [ ] recover done fulfill
                ] "TLS backend echo" spawn drop
                client-backend secure-socket-backend [
                    <secure-config> f >>verify method >>method
                    { "http/1.1" } >>alpn-supported-protocols [
                        server addr>> binary [
                            5 seconds input-stream get set-timeout
                            5 seconds output-stream get set-timeout
                            contents write flush
                            contents length read contents assert=
                            client-backend schannel = [
                                input-stream get underlying-handle
                                schannel-alpn-protocol "http/1.1" assert=
                            ] when
                            server-backend schannel = [ read1 f assert= ] when
                        ] with-client
                    ] with-secure-context
                ] with-variable
                done 5 seconds ?promise-timeout dup t =
                [ drop t ] [ throw ] if
            ] with-destructors
        ] with-secure-context
    ] with-variable ;

{ t } [ schannel schannel TLS tls-echo ] unit-test
{ t } [ schannel schannel TLSv1.2 tls-echo ] unit-test
{ t } [ openssl schannel TLS tls-echo ] unit-test
{ t } [ schannel openssl TLS tls-echo ] unit-test

! The process default is native TLS, with certificate verification enabled.
{ t TLS t } [
    secure-socket-backend get-global schannel =
    <secure-config> [ method>> ] [ verify>> ] bi
] unit-test

! OpenSSL remains selectable without changing the process default.
{ t t t } [
    [
        secure-socket-backend get openssl =
        ssl-supported?
        <secure-config> method>> TLS =
    ] with-openssl
] unit-test

{ t } [
    secure-socket-backend get
    [ [ "OpenSSL selection test" throw ] with-openssl ] ignore-errors
    secure-socket-backend get =
] unit-test

{ t TLS t } [
    [
        ssl-supported? <secure-config> [ method>> ] [ verify>> ] bi
    ] with-schannel
] unit-test

! Upgrade a plain TCP stream and split TLS records across tiny native buffers.
{ t } [
    [
        <schannel-test-config> [
            [| |
                "127.0.0.1" 0 <inet4> ascii <server> &dispose :> server
                <promise> :> done
                [
                    [
                        server accept drop [
                            "start" print flush accept-secure-handshake
                            input-stream get underlying-handle :> socket
                            socket input>> [ dispose 37 <buffer> ] change-buffer drop
                            socket output>> [ dispose 37 <buffer> ] change-buffer drop
                            readln "hello" assert= "world" print flush
                        ] with-stream t
                    ] [ ] recover done fulfill
                ] "Schannel STARTTLS" spawn drop
                <secure-config> f >>verify [
                    server addr>> ascii [
                        readln "start" assert= send-secure-handshake
                        "hello" print flush readln "world" assert=
                    ] with-client
                ] with-secure-context
                done 5 seconds ?promise-timeout dup t =
                [ drop t ] [ throw ] if
            ] with-destructors
        ] with-secure-context
    ] with-schannel
] unit-test

! Selecting a backend for one scope restores the previous selection.
{ t } [
    secure-socket-backend get [ [ ] with-schannel secure-socket-backend get ]
    dip =
] unit-test

! Unsupported OpenSSL-specific settings must fail explicitly.
[
    [ <secure-config> "ca.pem" >>ca-file <secure-context> dispose ] with-schannel
] [ unsupported-schannel-config? ] must-fail-with

[
    [ f "localhost\0.invalid" <windows-secure-socket> ] with-schannel
] [ invalid-schannel-hostname? ] must-fail-with

[
    [ <secure-config> TLSv1 >>method <secure-context> dispose ] with-schannel
] [ unsupported-schannel-config? ] must-fail-with

! The test certificate is self-signed and is never installed as a trusted root.
{ t } [
    [
        <schannel-test-config> [
            [| |
                "127.0.0.1" 0 <inet4> f <secure> binary <server> &dispose :> server
                <promise> :> done
                [
                    [ server accept drop [ read1 drop ] with-stream ]
                    [ drop ] recover t done fulfill
                ] "TLS untrusted certificate" spawn drop
                <secure-config> [
                    [ server addr>> binary [ ] with-client f ]
                    [
                        dup schannel-error? [ status>> SEC_E_UNTRUSTED_ROOT = ]
                        [ drop f ] if
                    ] recover
                ] with-secure-context
                done 5 seconds ?promise-timeout drop
            ] with-destructors
        ] with-secure-context
    ] with-schannel
] unit-test

! Cancel a handshake while the peer keeps its plain TCP connection open.
{ t } [
    [
        [| |
            "127.0.0.1" 0 <inet4> binary <server> &dispose :> server
            <promise> :> finish
            <promise> :> done
            [
                [ server accept drop [ finish ?promise drop ] with-stream t ]
                [ ] recover done fulfill
            ] "TLS silent peer" spawn drop
            [
                30 milliseconds secure-socket-timeout [
                    [ server addr>> f <secure> binary [ ] with-client f ]
                    [
                        dup windows-error? [ n>> ERROR_OPERATION_ABORTED = ]
                        [ drop f ] if
                    ] recover
                ] with-variable
            ] [ t finish fulfill done 5 seconds ?promise-timeout drop ] finally
        ] with-destructors
    ] with-schannel
] unit-test

! An established TLS socket must also cancel a blocked read promptly.
{ t } [
    [
        <schannel-test-config> [
            [| |
                "127.0.0.1" 0 <inet4> f <secure> binary <server> &dispose :> server
                <promise> :> finish
                <promise> :> done
                [
                    [
                        server accept drop [
                            65 write1 flush finish ?promise drop
                        ] with-stream t
                    ] [ ] recover done fulfill
                ] "TLS blocked read" spawn drop
                [
                    <secure-config> f >>verify [
                        server addr>> binary [
                            read1 65 assert=
                            30 milliseconds input-stream get set-timeout
                            [ read1 drop f ] [
                                dup windows-error?
                                [ n>> ERROR_OPERATION_ABORTED = ] [ drop f ] if
                            ] recover
                        ] with-client
                    ] with-secure-context
                ] [
                    t finish fulfill done 5 seconds ?promise-timeout
                    dup t = [ drop ] [ throw ] if
                ] finally
            ] with-destructors
        ] with-secure-context
    ] with-schannel
] unit-test

! The context can be disposed before its sockets: native credentials remain
! valid until the last socket is released, including temporary private keys.
{ t } [
    [
        [| |
            <schannel-test-config> <secure-context> &dispose :> context
            context secure-context [
                "127.0.0.1" 0 <inet4> f <secure> binary <server> &dispose :> server
                <promise> :> accepted
                <promise> :> done
                [
                    [
                        server accept drop [
                            read1 65 assert= t accepted fulfill
                            20 milliseconds sleep 66 write1 flush
                        ] with-stream t
                    ] [ ] recover done fulfill
                ] "TLS context lifetime" spawn drop
                <secure-config> f >>verify [
                    server addr>> binary [
                        65 write1 flush accepted 5 seconds ?promise-timeout drop
                        context dispose read1 66 assert=
                    ] with-client
                ] with-secure-context
                done 5 seconds ?promise-timeout t =
            ] with-variable
            context dispose
        ] with-destructors
    ] with-schannel
] unit-test
