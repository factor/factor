IN: io.launcher.unix.tests
USING: io.files io.files.temp io.directories io.pathnames
tools.test io.launcher arrays io namespaces continuations math
io.encodings.binary io.encodings.ascii accessors kernel
sequences io.encodings.utf8 destructors io.streams.duplex locals
concurrency.promises threads unix.process ;

[ ] [
    [ "launcher-test-1" temp-file delete-file ] ignore-errors
] unit-test

[ ] [
    "touch"
    "launcher-test-1" temp-file
    2array
    try-process
] unit-test

[ t ] [ "launcher-test-1" temp-file exists? ] unit-test

[ ] [
    [ "launcher-test-1" temp-file delete-file ] ignore-errors
] unit-test

[ ] [
    <process>
        "echo Hello" >>command
        "launcher-test-1" temp-file >>stdout
    try-process
] unit-test

[ "Hello\n" ] [
    "cat"
    "launcher-test-1" temp-file
    2array
    ascii <process-reader> stream-contents
] unit-test

[ ] [
    [ "launcher-test-1" temp-file delete-file ] ignore-errors
] unit-test

[ ] [
    <process>
        "cat" >>command
        +closed+ >>stdin
        "launcher-test-1" temp-file >>stdout
    try-process
] unit-test

[ f ] [
    "cat"
    "launcher-test-1" temp-file
    2array
    ascii <process-reader> stream-contents
] unit-test

[ ] [
    2 [
        "launcher-test-1" temp-file binary <file-appender> [
            <process>
                swap >>stdout
                "echo Hello" >>command
            try-process
        ] with-disposal
    ] times
] unit-test

[ "Hello\nHello\n" ] [
    "cat"
    "launcher-test-1" temp-file
    2array
    ascii <process-reader> stream-contents
] unit-test

[ t ] [
    <process>
        "env" >>command
        { { "A" "B" } } >>environment
    ascii <process-reader> stream-lines
    "A=B" swap member?
] unit-test

[ { "A=B" } ] [
    <process>
        "env" >>command
        { { "A" "B" } } >>environment
        +replace-environment+ >>environment-mode
    ascii <process-reader> stream-lines
] unit-test

[ "hi\n" ] [
    temp-directory [
        [ "aloha" delete-file ] ignore-errors
        <process>
            { "echo" "hi" } >>command
            "aloha" >>stdout
        try-process
    ] with-directory
    temp-directory "aloha" append-path
    utf8 file-contents
] unit-test

[ "append-test" temp-file delete-file ] ignore-errors

[ "hi\nhi\n" ] [
    2 [
        <process>
            "echo hi" >>command
            "append-test" temp-file <appender> >>stdout
        try-process
    ] times
    "append-test" temp-file utf8 file-contents
] unit-test

[ t ] [ "ls" utf8 <process-stream> stream-contents >boolean ] unit-test

[ "Hello world.\n" ] [
    "cat" utf8 <process-stream> [
        "Hello world.\n" write
        output-stream get dispose
        input-stream get stream-contents
    ] with-stream
] unit-test

! Killed processes were exiting with code 0 on FreeBSD
[ f ] [
    [let | p [ <promise> ]
           s [ <promise> ] |
       [
           "sleep 1000" run-detached
           [ p fulfill ] [ wait-for-process s fulfill ] bi
       ] in-thread

       p ?promise handle>> 9 kill drop
       s ?promise 0 =
    ]
] unit-test
