USING: accessors continuations destructors io.sockets io.sockets.windows
kernel sequences tools.test urls windows.winsock ;
USING: alien alien.data byte-arrays calendar concurrency.promises io
io.encodings.binary io.ports io.sockets.private io.timeouts locals
namespaces threads ;
IN: io.sockets.windows.tests

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
