USING: accessors alien alien.c-types alien.data byte-arrays calendar
concurrency.promises continuations destructors io io.backend
io.encodings.binary io.files io.files.windows io.ports io.sockets
io.sockets.private io.sockets.windows io.streams.duplex io.timeouts
kernel libc locals math namespaces sequences threads tools.test urls
windows.errors windows.types windows.winsock ;
IN: io.sockets.windows.tests

:: with-readiness-sockets ( quot -- )
    [
        "127.0.0.1" 0 <inet4> binary <server> &dispose :> server
        <promise> :> client
        <promise> :> finish
        <promise> :> done
        [
            [
                server addr>> binary [
                    input-stream get underlying-handle client fulfill
                    finish ?promise drop
                ] with-client t
            ] [ ] recover done fulfill
        ] "Windows readiness peer" spawn drop
        server accept drop &dispose :> peer
        client 5 seconds ?promise-timeout :> socket
        [ socket peer quot call ]
        [ t finish fulfill done 5 seconds ?promise-timeout t assert= ] finally
    ] with-destructors ; inline

{ } [
    [| socket peer |
        socket +output+ wait-for-fd
    ] with-readiness-sockets
] unit-test

! The scheduler can run the sender while the reader waits, repeatedly.
{ B{ 7 7 } } [
    [| socket peer |
        2 malloc &free :> bytes
        2 [| i |
            [
                20 milliseconds sleep
                B{ 7 } peer out>> stream-write peer out>> stream-flush
            ] "Windows readiness sender" spawn drop
            socket +input+ wait-for-fd
            socket handle>> i bytes <displaced-alien> 1 0 recv 1 assert=
        ] each-integer
        bytes 2 memory>byte-array
    ] with-readiness-sockets
] unit-test

! Socket cancellation must wake readiness waiters, not only overlapped I/O.
{ t } [
    [| socket peer |
        [ 20 milliseconds sleep socket cancel-operation ]
        "Windows readiness cancellation" spawn drop
        [ socket +input+ wait-for-fd f ]
        [ windows-error? ] recover
    ] with-readiness-sockets
] unit-test

{ } [
    [| socket peer |
        [ 20 milliseconds sleep peer dispose ]
        "Windows readiness close" spawn drop
        socket +input+ wait-for-fd
    ] with-readiness-sockets
] unit-test

! Accepted addresses must own their bytes after the AcceptEx buffer is freed.
! Both sides must support getpeername after their context update.
{ t t t } [
    [| |
        "127.0.0.1" 0 <inet4> binary <server> &dispose :> server
        <promise> :> client-address
        <promise> :> finished
        [
            [
                server addr>> binary [
                    5 seconds input-stream get set-timeout
                    local-address get client-address fulfill
                    1 read drop
                ] with-client
                t finished fulfill
            ] [ finished fulfill ] recover
        ] "Windows socket context test" spawn drop
        5 seconds server set-timeout
        server server addr>> (accept) :> ( handle sockaddr )
        handle <output-port> &dispose :> output
        sockaddr >c-ptr byte-array?
        handle server addr>> get-remote-address
        client-address 5 seconds ?promise-timeout =
        B{ 1 } output stream-write output stream-flush
        finished 5 seconds ?promise-timeout
    ] with-destructors
] unit-test

: google-socket ( -- socket )
    URL" http://www.google.com" url-addr resolve-host first
    SOCK_STREAM open-socket ;

{ } [
    { FIONBIO FIONREAD } [
        google-socket [
            swap execute( -- x )
            [ 1 set-ioctl-socket ] [ 0 set-ioctl-socket ] 2bi
        ] with-disposal
    ] each
] unit-test

{ t } [
    google-socket [
        [ 1337 -8 set-ioctl-socket ]
        [ nip [ winsock-exception? ] [ n>> 10045 = ] bi and ] recover
    ] with-disposal
] unit-test
