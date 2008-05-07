USING: io.files io.sockets io kernel threads
namespaces tools.test continuations strings byte-arrays
sequences prettyprint system io.encodings.binary io.encodings.ascii
io.streams.duplex ;
IN: io.unix.tests

! Unix domain stream sockets
: socket-server "unix-domain-socket-test" temp-file ;

[
    [ socket-server delete-file ] ignore-errors

    socket-server <local>
    ascii <server> [
        accept drop [
            "Hello world" print flush
            readln "XYZ" = "FOO" "BAR" ? print flush
        ] with-stream
    ] with-disposal

    socket-server delete-file
] "Test" spawn drop

yield

[ { "Hello world" "FOO" } ] [
    [
        socket-server <local> ascii [
            readln ,
            "XYZ" print flush
            readln ,
        ] with-client
    ] { } make
] unit-test

: datagram-server "unix-domain-datagram-test" temp-file ;
: datagram-client "unix-domain-datagram-test-2" temp-file ;

! Unix domain datagram sockets
[ datagram-server delete-file ] ignore-errors
[ datagram-client delete-file ] ignore-errors

[
    [
        datagram-server <local> <datagram> "d" set

        "Receive 1" print

        "d" get receive >r reverse r>
        
        "Send 1" print
        dup .

        "d" get send

        "Receive 2" print

        "d" get receive >r " world" append r>
        
        "Send 1" print
        dup .

         "d" get send

        "d" get dispose

        "Done" print

        datagram-server delete-file
    ] with-scope
] "Test" spawn drop

yield

[ datagram-client delete-file ] ignore-errors

datagram-client <local> <datagram>
"d" set

[ ] [
    "hello" >byte-array
    datagram-server <local>
    "d" get send
] unit-test

[ "olleh" t ] [
    "d" get receive
    datagram-server <local> =
    >r >string r>
] unit-test

[ ] [
    "hello" >byte-array
    datagram-server <local>
    "d" get send
] unit-test

[ "hello world" t ] [
    "d" get receive
    datagram-server <local> =
    >r >string r>
] unit-test

[ ] [ "d" get dispose ] unit-test

! Test error behavior
: another-datagram "unix-domain-datagram-test-3" temp-file ;

[ another-datagram delete-file ] ignore-errors

datagram-client delete-file

[ ] [ datagram-client <local> <datagram> "d" set ] unit-test

[ B{ 1 2 3 } another-datagram <local> "d" get send ] must-fail

[ ] [ "d" get dispose ] unit-test

! See what happens on send/receive after close

[ "d" get receive ] must-fail

[ B{ 1 2 } datagram-server <local> "d" get send ] must-fail

! Invalid parameter tests

[
    image binary [ input-stream get accept ] with-file-reader
] must-fail

[
    image binary [ input-stream get receive ] with-file-reader
] must-fail

[
    image binary [
        B{ 1 2 } datagram-server <local>
        input-stream get send
    ] with-file-reader
] must-fail
