USING: byte-arrays destructors io io.directories
io.encodings.ascii io.encodings.binary io.files io.launcher
io.sockets io.streams.duplex kernel make namespaces prettyprint
sequences strings system threads tools.test ;

[
    [
        "socket-server" <local>
        ascii <server> [
            accept drop [
                "Hello world" print flush
                readln "XYZ" = "FOO" "BAR" ? print flush
            ] with-stream
        ] with-disposal

        "socket-server" delete-file
    ] "Test" spawn drop

    yield

    { { "Hello world" "FOO" } } [
        [
            "socket-server" <local> ascii [
                readln ,
                "XYZ" print flush
                readln ,
            ] with-client
        ] { } make
    ] unit-test

    ! Unix domain datagram sockets
    [
        "datagram-server" <local> <datagram> "d" [

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

            "datagram-server" delete-file
        ] with-variable
    ] "Test" spawn drop

    yield

    { } [ "datagram-client" <local> <datagram> "d" set ] unit-test

    { } [
        "hello" >byte-array
        "datagram-server" <local>
        "d" get send
    ] unit-test

    { "olleh" t } [
        "d" get receive
        "datagram-server" <local> =
        [ >string ] dip
    ] unit-test

    { } [
        "hello" >byte-array
        "datagram-server" <local>
        "d" get send
    ] unit-test

    { "hello world" t } [
        "d" get receive
        "datagram-server" <local> =
        [ >string ] dip
    ] unit-test

    { } [ "d" get dispose ] unit-test

    ! Test error behavior

    "datagram-client" delete-file

    { } [ "datagram-client" <local> <datagram> "d" set ] unit-test

    [ B{ 1 2 3 } "another-datagram" <local> "d" get send ] must-fail

    { } [ "d" get dispose ] unit-test

    ! See what happens on send/receive after close

    [ "d" get receive ] must-fail

    [ B{ 1 2 } "datagram-server" <local> "d" get send ] must-fail

    ! Invalid parameter tests

    [
        image-path binary [ input-stream get accept ] with-file-reader
    ] must-fail

    [
        image-path binary [ input-stream get receive ] with-file-reader
    ] must-fail

    [
        image-path binary [
            B{ 1 2 } "datagram-server" <local>
            input-stream get send
        ] with-file-reader
    ] must-fail

] with-test-directory

! closing stdin caused some problems
{ } [
    [
        vm-path ,
        "-i=" image-path append ,
        "-e=USING: destructors namespaces io calendar threads ; input-stream get dispose 1 seconds sleep" ,
    ] { } make try-process
] unit-test
