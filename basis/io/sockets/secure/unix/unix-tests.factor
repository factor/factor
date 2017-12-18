USING: accessors calendar classes concurrency.conditions
concurrency.mailboxes concurrency.promises continuations
destructors io io.backend.unix io.encodings.ascii io.sockets
io.sockets.secure io.sockets.secure.debug io.streams.duplex
io.timeouts kernel locals namespaces threads tools.test ;
QUALIFIED-WITH: concurrency.messaging qm
IN: io.sockets.secure.tests

{ 1 0 } [ [ ] with-secure-context ] must-infer-as

{ } [ <promise> "port" set ] unit-test

:: server-test ( quot -- )
    [
        [
            "127.0.0.1" 0 <inet4> f <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept [
                    quot call
                ] curry with-stream
            ] with-disposal
        ] with-test-context
    ] "SSL server test" qm:spawn-linked drop
    ! This is hideous.
    ! If we fail with a timeout, the test is passing.
    ! If we fail with something besides a timeout, rethrow it and fail the test.
    [ qm:my-mailbox 200 milliseconds mailbox-get-timeout drop ]
    [ dup timed-out-error? [ drop ] [ rethrow ] if ] recover ;

: ?promise-test ( mailbox -- obj )
    340 milliseconds ?promise-timeout ;

: client-test ( -- string )
    <secure-config> [
        "127.0.0.1" "port" get ?promise-test <inet4> f <secure> ascii <client> drop
        1 seconds
        [ stream-contents ] with-timeout*
    ] with-secure-context ;

! { } [ [ class-of name>> write "done" my-mailbox mailbox-put ] server-test ] unit-test
{ } [ [ class-of name>> write ] server-test ] unit-test

{ "secure" } [ client-test ] unit-test

! Now, see what happens if the server closes the connection prematurely
{ } [ <promise> "port" set ] unit-test

{ } [
    [
        drop
        "hello" write flush
        input-stream get stream>> handle>> f >>connected drop
    ] server-test
] unit-test

! Actually, this should not be an error since many HTTPS servers
! (eg, google.com) do this.

! [ client-test ] [ premature-close? ] must-fail-with
{ "hello" } [ client-test ] unit-test

! Now, try validating the certificate. This should fail because its
! actually an invalid certificate
{ } [ <promise> "port" set ] unit-test

{ } [ [ drop "hi" write ] server-test ] unit-test

[
    <secure-config> [
        "localhost" "port" get ?promise-test <inet> f <secure> ascii
        <client> drop dispose
    ] with-secure-context
] [ certificate-verify-error? ] must-fail-with

! Client-side handshake timeout
{ } [ <promise> "port" set ] unit-test

{ } [
    [
        [
            "127.0.0.1" 0 <inet4> ascii <server> &dispose
                dup addr>> port>> "port" get fulfill
                accept drop &dispose 1 minutes sleep
        ] with-destructors
    ] "Silly server" spawn drop
] unit-test

[
    1 seconds secure-socket-timeout [
        client-test
    ] with-variable
] [ io-timeout? ] must-fail-with

! Server-side handshake timeout
{ } [ <promise> "port" set ] unit-test

{ } [
    [
        [
            "127.0.0.1" "port" get ?promise-test
            <inet4> ascii <client> drop &dispose 1 minutes sleep
        ] with-destructors
    ] "Silly client" spawn drop
] unit-test

[
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

! Client socket shutdown timeout

! Until I sort out two-stage handshaking, I can't do much here
[
    [ ] [ <promise> "port" set ] unit-test

    [ ] [
        [
            [
                [
                    "127.0.0.1" 0 <inet4> f <secure> ascii <server> [
                        dup addr>> addrspec>> port>> "port" get fulfill
                        accept drop &dispose 1 minutes sleep
                    ] with-disposal
                ] with-test-context
            ] with-destructors
        ] "Silly server" spawn drop
    ] unit-test

    [
        1 seconds secure-socket-timeout [
            <secure-config> [
                "127.0.0.1" "port" get ?promise-test <inet4> f <secure>
                ascii <client> drop dispose
            ] with-secure-context
        ] with-variable
    ] [ io-timeout? ] must-fail-with

    ! Server socket shutdown timeout
    [ ] [ <promise> "port" set ] unit-test

    [ ] [
        [
            [
                [
                    "127.0.0.1" "port" get ?promise-test
                    <inet4> f <secure> ascii <client> drop &dispose 1 minutes sleep
                ] with-test-context
            ] with-destructors
        ] "Silly client" spawn drop
    ] unit-test

    [
        [
            1 seconds secure-socket-timeout [
                [
                    "127.0.0.1" 0 <inet4> f <secure> ascii <server> [
                        dup addr>> addrspec>> port>> "port" get fulfill
                        accept drop &dispose
                    ] with-disposal
                ] with-test-context
            ] with-variable
        ] with-destructors
    ] [ io-timeout? ] must-fail-with
] drop
