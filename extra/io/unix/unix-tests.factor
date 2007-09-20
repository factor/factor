USING: io.files io.sockets io kernel threads namespaces
tools.test continuations strings byte-arrays sequences
prettyprint system ;
IN: temporary

! Unix domain stream sockets
[
    [
        "unix-domain-socket-test" resource-path delete-file
    ] catch drop

    "unix-domain-socket-test" resource-path <local>
    <server> [
        stdio get accept [
            "Hello world" print flush
            readln "XYZ" = "FOO" "BAR" ? print flush
        ] with-stream
    ] with-stream

    "unix-domain-socket-test" resource-path delete-file
] in-thread

yield

[ { "Hello world" "FOO" } ] [
    [
        "unix-domain-socket-test" resource-path <local> <client>
        [
            readln ,
            "XYZ" print flush
            readln ,
        ] with-stream
    ] { } make
] unit-test

! Unix domain datagram sockets
[
    "unix-domain-datagram-test" resource-path delete-file
] catch drop

: server-addr "unix-domain-datagram-test" resource-path <local> ;
: client-addr "unix-domain-datagram-test-2" resource-path <local> ;

[
    [
        server-addr <datagram> "d" set

        "Receive 1" print

        "d" get receive >r reverse r>
        
        "Send 1" print
        dup .

        "d" get send

        "Receive 2" print

        "d" get receive >r >upper r>
        
        "Send 1" print
        dup .

         "d" get send

        "d" get stream-close

        "Done" print

        "unix-domain-datagram-test" resource-path delete-file
    ] with-scope
] in-thread

yield

[
    "unix-domain-datagram-test-2" resource-path delete-file
] catch drop

client-addr <datagram>
"d" set

[ ] [
    "hello" >byte-array
    server-addr
    "d" get send
] unit-test

[ "olleh" t ] [
    "d" get receive
    server-addr =
    >r >string r>
] unit-test

[ ] [
    "hello" >byte-array
    server-addr
    "d" get send
] unit-test

[ "HELLO" t ] [
    "d" get receive
    server-addr =
    >r >string r>
] unit-test

[ ] [ "d" get stream-close ] unit-test

! Test error behavior

[
    "unix-domain-datagram-test-3" resource-path delete-file
] catch drop

"unix-domain-datagram-test-2" resource-path delete-file

[ ] [ client-addr <datagram> "d" set ] unit-test

[
    B{ 1 2 3 } "unix-domain-datagram-test-3" <local> "d" get send
] unit-test-fails

[ ] [ "d" get stream-close ] unit-test

! See what happens on send/receive after close

[ "d" get receive ] unit-test-fails

[ B{ 1 2 } server-addr "d" get send ] unit-test-fails

! Invalid parameter tests

[
    image <file-reader> [ stdio get accept ] with-stream
] unit-test-fails

[
    image <file-reader> [ stdio get receive ] with-stream
] unit-test-fails

[
    image <file-reader> [
        B{ 1 2 } server-addr
        stdio get send
    ] with-stream
] unit-test-fails
