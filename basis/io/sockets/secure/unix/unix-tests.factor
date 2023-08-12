USING: accessors bootstrap.image.download calendar classes
concurrency.conditions concurrency.mailboxes
concurrency.promises continuations destructors io
io.backend.unix io.encodings.ascii io.files.temp io.sockets
io.sockets.secure io.sockets.secure.debug io.streams.duplex
io.timeouts kernel namespaces sequences system threads
tools.test ;
QUALIFIED-WITH: concurrency.messaging qm
IN: io.sockets.secure.tests

{ 1 0 } [ [ ] with-secure-context ] must-infer-as

:: server-test ( quot: ( remote -- ) -- )
    [
        [
            "127.0.0.1" 0 <inet4> f <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept quot curry with-stream
            ] with-disposal
        ] with-test-context
    ] "SSL server test" spawn drop ;

: ?promise-test ( mailbox -- obj )
    500 milliseconds ?promise-timeout ;

: client-test ( -- string )
    <secure-config> [
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

