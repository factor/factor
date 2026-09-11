USING: accessors arrays calendar concurrency.conditions
concurrency.flags concurrency.mailboxes destructors fry io
io.encodings.ascii io.encodings.utf8 io.servers io.servers.private
io.sockets kernel locals namespaces sequences sets threads tools.test ;

! A slot belongs to the live handler, including stream cleanup.
{ t } [
    <mailbox> [| started |
        ascii <threaded-server>
            1 >>max-connections
            "127.0.0.1" 0 <inet4> >>insecure
            [
                t started mailbox-put
                read1 CHAR: x = [ "test handler failure" throw ] when
            ] >>handler
        [
            [
                insecure-addr ascii <client> drop &dispose :> first-client
                started 5 seconds mailbox-get-timeout drop
                insecure-addr ascii <client> drop &dispose drop
                [ started 100 milliseconds mailbox-get-timeout drop ]
                [ timed-out-error? ] must-fail-with
                CHAR: x first-client stream-write1
                first-client stream-flush
                started 5 seconds mailbox-get-timeout
            ] with-destructors
        ] with-threaded-server
    ] call
] unit-test

{ t } [ ascii <threaded-server> listen-on empty? ] unit-test

{ f } [
    ascii <threaded-server>
        25 internet-server >>insecure
    listen-on
    empty?
] unit-test

{ t } [
    T{ inet4 f "1.2.3.4" 1234 } T{ inet4 f "1.2.3.5" 1235 }
    [ log-connection ] 2keep
    [ remote-address get = ] [ local-address get = ] bi*
    and
] unit-test

{ } [ ascii <threaded-server> init-server drop ] unit-test

{ 10 } [
    ascii <threaded-server>
        10 >>max-connections
    init-server semaphore>> count>>
] unit-test

{ "Hello world." } [
    ascii <threaded-server>
        5 >>max-connections
        0 >>insecure
        [ "Hello world." write stop-this-server ] >>handler
    [
        insecure-addr ascii <client> drop stream-contents
    ] with-threaded-server
] unit-test

{ } [
    ascii <threaded-server>
        5 >>max-connections
        0 >>insecure
    start-server [ '[ _ wait-for-server ] in-thread ] [ stop-server ] bi
] unit-test

ipv6-supported? [
    { f } [
        ascii <threaded-server>
            "localhost" 1234 inet boa >>insecure
        listen-on
        [ inet6? ] any?
    ] unit-test
] unless

! Test that we can listen on several ports at once.
{ } [
    utf8 <threaded-server>
        "127.0.0.1" 0 <inet4>
        "127.0.0.1" 0 <inet4>
        2array >>insecure

        "127.0.0.1" 0 <inet4>
        "127.0.0.1" 0 <inet4>
        2array >>secure

        start-server stop-server
] unit-test

! add-running-server
[
    ascii <threaded-server> HS{ } clone 2dup adjoin
    add-running-server
] [ server-already-running? ] must-fail-with

! stop-server
[
    ascii <threaded-server> <flag> >>server-stopped
    stop-server
] [ server-not-running? ] must-fail-with
