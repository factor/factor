USING: io.launcher tools.test calendar accessors environment
namespaces kernel system arrays io io.files io.encodings.ascii
sequences parser assocs hashtables math continuations eval
io.files.temp io.directories io.pathnames ;
IN: io.launcher.windows.nt.tests

[ ] [
    <process>
        "notepad" >>command
        1/2 seconds >>timeout
    "notepad" set
] unit-test

[ f ] [ "notepad" get process-running? ] unit-test

[ f ] [ "notepad" get process-started? ] unit-test

[ ] [ "notepad" [ run-detached ] change ] unit-test

[ "notepad" get wait-for-process ] must-fail

[ t ] [ "notepad" get killed>> ] unit-test

[ f ] [ "notepad" get process-running? ] unit-test

[ ] [
    <process>
        vm "-quiet" "-run=hello-world" 3array >>command
        "out.txt" temp-file >>stdout
    try-process
] unit-test

[ "Hello world" ] [
    "out.txt" temp-file ascii file-lines first
] unit-test

[ ] [
    <process>
        vm "-run=listener" 2array >>command
        +closed+ >>stdin
    try-process
] unit-test

: launcher-test-path ( -- str )
    "resource:basis/io/launcher/windows/nt/test" ;

[ ] [
    launcher-test-path [
        <process>
            vm "-script" "stderr.factor" 3array >>command
            "out.txt" temp-file >>stdout
            "err.txt" temp-file >>stderr
        try-process
    ] with-directory
] unit-test

[ "output" ] [
    "out.txt" temp-file ascii file-lines first
] unit-test

[ "error" ] [
    "err.txt" temp-file ascii file-lines first
] unit-test

[ ] [
    launcher-test-path [
        <process>
            vm "-script" "stderr.factor" 3array >>command
            "out.txt" temp-file >>stdout
            +stdout+ >>stderr
        try-process
    ] with-directory
] unit-test

[ "outputerror" ] [
    "out.txt" temp-file ascii file-lines first
] unit-test

[ "output" ] [
    launcher-test-path [
        <process>
            vm "-script" "stderr.factor" 3array >>command
            "err2.txt" temp-file >>stderr
        ascii <process-reader> lines first
    ] with-directory
] unit-test

[ "error" ] [
    "err2.txt" temp-file ascii file-lines first
] unit-test

[ t ] [
    launcher-test-path [
        <process>
            vm "-script" "env.factor" 3array >>command
        ascii <process-reader> contents
    ] with-directory eval

    os-envs =
] unit-test

[ t ] [
    launcher-test-path [
        <process>
            vm "-script" "env.factor" 3array >>command
            +replace-environment+ >>environment-mode
            os-envs >>environment
        ascii <process-reader> contents
    ] with-directory eval
    
    os-envs =
] unit-test

[ "B" ] [
    launcher-test-path [
        <process>
            vm "-script" "env.factor" 3array >>command
            { { "A" "B" } } >>environment
        ascii <process-reader> contents
    ] with-directory eval

    "A" swap at
] unit-test

[ f ] [
    launcher-test-path [
        <process>
            vm "-script" "env.factor" 3array >>command
            { { "USERPROFILE" "XXX" } } >>environment
            +prepend-environment+ >>environment-mode
        ascii <process-reader> contents
    ] with-directory eval

    "USERPROFILE" swap at "XXX" =
] unit-test

2 [
    [ ] [
        <process>
            "cmd.exe /c dir" >>command
            "dir.txt" temp-file >>stdout
        try-process
    ] unit-test

    [ ] [ "dir.txt" temp-file delete-file ] unit-test
] times

[ "append-test" temp-file delete-file ] ignore-errors

[ "Hello appender\r\nHello appender\r\n" ] [
    2 [
        launcher-test-path [
            <process>
                vm "-script" "append.factor" 3array >>command
                "append-test" temp-file <appender> >>stdout
            try-process
        ] with-directory
    ] times
   
    "append-test" temp-file ascii file-contents
] unit-test
