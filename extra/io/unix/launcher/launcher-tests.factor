IN: io.unix.launcher.tests
USING: io.files tools.test io.launcher arrays io namespaces
continuations math ;

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
    [
        "echo Hello" +command+ set
        "launcher-test-1" temp-file +stdout+ set
    ] { } make-assoc try-process
] unit-test

[ "Hello\n" ] [
    "cat"
    "launcher-test-1" temp-file
    2array
    <process-stream> contents
] unit-test

[ "" ] [
    [
        "cat"
        "launcher-test-1" temp-file
        2array +arguments+ set
        +inherit+ +stdout+ set
    ] { } make-assoc <process-stream> contents
] unit-test

[ ] [
    [ "launcher-test-1" temp-file delete-file ] ignore-errors
] unit-test

[ ] [
    [
        "cat" +command+ set
        +closed+ +stdin+ set
        "launcher-test-1" temp-file +stdout+ set
    ] { } make-assoc try-process
] unit-test

[ "" ] [
    "cat"
    "launcher-test-1" temp-file
    2array
    <process-stream> contents
] unit-test

[ ] [
    2 [
        "launcher-test-1" temp-file <file-appender> [
            [
                +stdout+ set
                "echo Hello" +command+ set
            ] { } make-assoc try-process
        ] with-disposal
    ] times
] unit-test

[ "Hello\nHello\n" ] [
    "cat"
    "launcher-test-1" temp-file
    2array
    <process-stream> contents
] unit-test
