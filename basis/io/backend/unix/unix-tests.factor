USING: io.files io.files.temp io.directories io.sockets io kernel threads
namespaces tools.test continuations strings byte-arrays
sequences prettyprint system io.encodings.binary io.encodings.ascii
io.streams.duplex destructors make io.launcher ;
IN: io.backend.unix.tests

! Unix domain stream sockets
: socket-server ( -- path ) "unix-domain-socket-test" temp-file ;

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

: datagram-server ( -- path ) "unix-domain-datagram-test" temp-file ;
: datagram-client ( -- path ) "unix-domain-datagram-test-2" temp-file ;

! Unix domain datagram sockets
[ datagram-server delete-file ] ignore-errors
[ datagram-client delete-file ] ignore-errors

[
    [
        datagram-server <local> <datagram> "d" set

        "Receive 1" print

        "d" get receive [ reverse ] dip
        
        "Send 1" print
        dup .

        "d" get send

        "Receive 2" print

        "d" get receive [ " world" append ] dip
        
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
    [ >string ] dip
] unit-test

[ ] [
    "hello" >byte-array
    datagram-server <local>
    "d" get send
] unit-test

[ "hello world" t ] [
    "d" get receive
    datagram-server <local> =
    [ >string ] dip
] unit-test

[ ] [ "d" get dispose ] unit-test

! Test error behavior
: another-datagram ( -- path ) "unix-domain-datagram-test-3" temp-file ;

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

! closing stdin caused some problems
[ ] [
    [
        vm ,
        "-i=" image append ,
        "-run=none" ,
        "-e=USING: destructors namespaces io calendar threads ; input-stream get dispose 1 seconds sleep" ,
    ] { } make try-process
] unit-test
