USING: accessors calendar concurrency.promises continuations
destructors io io.encodings.binary io.ports io.sockets
io.sockets.secure io.sockets.secure.debug io.streams.duplex
io.timeouts kernel locals namespaces sequences threads tools.test ;
IN: io.sockets.secure.windows.tests

! Exercise both client and accepted socket handshakes, partial transfers,
! and reads whose peer can only send after the scheduler runs another thread.
{ t t } [| |
    [
        [
            "127.0.0.1" 0 <inet4> f <secure> binary <server> &dispose :> server
            1048576 90 <repetition> B{ } like :> contents
            <promise> :> done
            [
                [
                    server accept drop [
                        5 seconds input-stream get set-timeout
                        5 seconds output-stream get set-timeout
                        contents length read contents assert=
                        20 milliseconds sleep
                        contents write flush
                    ] with-stream t
                ] [ ] recover done fulfill
            ] "Windows TLS echo" spawn drop
            server addr>> binary [
                5 seconds input-stream get set-timeout
                5 seconds output-stream get set-timeout
                contents write flush contents length read contents =
            ] with-client
            done 5 seconds ?promise-timeout t =
        ] with-destructors
    ] with-test-context
] unit-test

! A TLS handshake against a silent TCP peer must release the readiness wait.
{ t } [| |
    [
        "127.0.0.1" 0 <inet4> binary <server> &dispose :> server
        <promise> :> finish
        <promise> :> done
        [
            [ server accept drop [ finish ?promise drop ] with-stream t ]
            [ ] recover done fulfill
        ] "Windows TLS silent peer" spawn drop
        [
            30 milliseconds secure-socket-timeout [
                [ server addr>> f <secure> binary [ ] with-client f ]
                [ drop t ] recover
            ] with-variable
        ] [ t finish fulfill done 5 seconds ?promise-timeout drop ] finally
    ] with-destructors
] unit-test
