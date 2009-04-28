IN: io.sockets.secure.tests
USING: accessors kernel namespaces io io.sockets
io.sockets.secure io.encodings.ascii io.streams.duplex
io.backend.unix classes words destructors threads tools.test
concurrency.promises byte-arrays locals calendar io.timeouts
io.sockets.secure.unix.debug ;

{ 1 0 } [ [ ] with-secure-context ] must-infer-as

[ ] [ <promise> "port" set ] unit-test

:: server-test ( quot -- )
    [
        [
            "127.0.0.1" 0 <inet4> <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept [
                    quot call
                ] curry with-stream
            ] with-disposal
        ] with-test-context
    ] "SSL server test" spawn drop ;

: client-test ( -- string )
    <secure-config> [
        "127.0.0.1" "port" get ?promise <inet4> <secure> ascii <client> drop contents
    ] with-secure-context ;

[ ] [ [ class name>> write ] server-test ] unit-test

[ "secure" ] [ client-test ] unit-test

! Now, see what happens if the server closes the connection prematurely
[ ] [ <promise> "port" set ] unit-test

[ ] [
    [
        drop
        "hello" write flush
        input-stream get stream>> handle>> f >>connected drop
    ] server-test
] unit-test

[ client-test ] [ premature-close? ] must-fail-with

! Now, try validating the certificate. This should fail because its
! actually an invalid certificate
[ ] [ <promise> "port" set ] unit-test

[ ] [ [ drop "hi" write ] server-test ] unit-test

[
    <secure-config> [
        "localhost" "port" get ?promise <inet> <secure> ascii
        <client> drop dispose
    ] with-secure-context
] [ certificate-verify-error? ] must-fail-with

! Client-side handshake timeout
[ ] [ <promise> "port" set ] unit-test

[ ] [
    [
        "127.0.0.1" 0 <inet4> ascii <server> [
            dup addr>> port>> "port" get fulfill
            accept drop 1 minutes sleep dispose
        ] with-disposal
    ] "Silly server" spawn drop
] unit-test

[
    1 seconds secure-socket-timeout [
        client-test
    ] with-variable
] [ io-timeout? ] must-fail-with

! Server-side handshake timeout
[ ] [ <promise> "port" set ] unit-test

[ ] [
    [
        "127.0.0.1" "port" get ?promise
        <inet4> ascii <client> drop 1 minutes sleep dispose
    ] "Silly client" spawn drop
] unit-test

[
    1 seconds secure-socket-timeout [
        [
            "127.0.0.1" 0 <inet4> <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept drop dup stream-read1 drop dispose
            ] with-disposal
        ] with-test-context
    ] with-variable
] [ io-timeout? ] must-fail-with

! Client socket shutdown timeout

! Until I sort out two-stage handshaking, I can't do much here
[
    [ ] [ <promise> "port" set ] unit-test
    
    [ ] [
        [
            [
                "127.0.0.1" 0 <inet4> <secure> ascii <server> [
                    dup addr>> addrspec>> port>> "port" get fulfill
                    accept drop 1 minutes sleep dispose
                ] with-disposal
            ] with-test-context
        ] "Silly server" spawn drop
    ] unit-test
    
    [
        1 seconds secure-socket-timeout [
            <secure-config> [
                "127.0.0.1" "port" get ?promise <inet4> <secure>
                ascii <client> drop dispose
            ] with-secure-context
        ] with-variable
    ] [ io-timeout? ] must-fail-with
    
    ! Server socket shutdown timeout
    [ ] [ <promise> "port" set ] unit-test
    
    [ ] [
        [
            [
                "127.0.0.1" "port" get ?promise
                <inet4> <secure> ascii <client> drop 1 minutes sleep dispose
            ] with-test-context
        ] "Silly client" spawn drop
    ] unit-test
    
    [
        1 seconds secure-socket-timeout [
            [
                "127.0.0.1" 0 <inet4> <secure> ascii <server> [
                    dup addr>> addrspec>> port>> "port" get fulfill
                    accept drop dispose
                ] with-disposal
            ] with-test-context
        ] with-variable
    ] [ io-timeout? ] must-fail-with
] drop
