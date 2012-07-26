USING: accessors arrays assocs calendar continuations
environment eval hashtables io io.directories
io.encodings.ascii io.files io.files.temp io.launcher
io.launcher.windows io.pathnames kernel math namespaces parser
sequences splitting system tools.test combinators.short-circuit ;
IN: io.launcher.windows.tests

[ "hello world" ] [ { "hello" "world" } join-arguments ] unit-test

[ "bob \"mac arthur\"" ] [ { "bob" "mac arthur" } join-arguments ] unit-test

[ "bob mac\\\\arthur" ] [ { "bob" "mac\\\\arthur" } join-arguments ] unit-test

[ "bob \"mac arthur\\\\\"" ] [ { "bob" "mac arthur\\" } join-arguments ] unit-test

! Bug #245
[ "\\\"hi\\\"" ] [ { "\"hi\"" } join-arguments ] unit-test

[ "\"\\\"hi you\\\"\"" ] [ { "\"hi you\"" } join-arguments ] unit-test

! Commented line -- what should appear on the command line
! \foo\\bar\\\bas\ -> \foo\\bar\\\bas\
[ "\\foo\\\\bar\\\\\\bas\\" ]
[ { "\\foo\\\\bar\\\\\\bas\\" } join-arguments ] unit-test

! \"foo"\\bar\\\bas\ -> \\\"foo\"\\bar\\\bas\
[ "\\\\\\\"foo\\\"\\\\bar\\\\\\bas\\" ]
[ { "\\\"foo\"\\\\bar\\\\\\bas\\" } join-arguments ] unit-test

! \foo\\"bar"\\\bas\ -> \foo\\\\\"bar\"\\\bas\
[ "\\foo\\\\\\\\\\\"bar\\\"\\\\\\bas\\" ]
[ { "\\foo\\\\\"bar\"\\\\\\bas\\" } join-arguments ] unit-test

! \foo\\bar\\\"bas"\ -> \foo\\bar\\\\\\\"bas\"\
[ "\\foo\\\\bar\\\\\\\\\\\\\\\"bas\\\"\\" ]
[ { "\\foo\\\\bar\\\\\\\"bas\"\\" } join-arguments ] unit-test

! \foo\\bar bar\\\bas\ -> "\foo\\bar bar\\\bas\\"
[ "\"\\foo\\\\bar bar\\\\\\bas\\\\\"" ]
[ { "\\foo\\\\bar bar\\\\\\bas\\" } join-arguments ] unit-test


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

[
    <process>
        "notepad" >>command
        1/2 seconds >>timeout
    try-process
] must-fail

[
    <process>
        "notepad" >>command
        1/2 seconds >>timeout
    try-output-process
] must-fail

: console-vm ( -- path )
    vm ".exe" ?tail [ ".com" append ] when ;

[ ] [
    <process>
        console-vm "-run=hello-world" 2array >>command
        "out.txt" temp-file >>stdout
    try-process
] unit-test

[ "Hello world" ] [
    "out.txt" temp-file ascii file-lines first
] unit-test

[ "IN: scratchpad " ] [
    <process>
        console-vm "-run=listener" 2array >>command
        +closed+ >>stdin
        +stdout+ >>stderr
    ascii [ lines last ] with-process-reader
] unit-test

: launcher-test-path ( -- str )
    "resource:basis/io/launcher/windows/test" ;

[ ] [
    launcher-test-path [
        <process>
            console-vm "-script" "stderr.factor" 3array >>command
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
            console-vm "-script" "stderr.factor" 3array >>command
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
            console-vm "-script" "stderr.factor" 3array >>command
            "err2.txt" temp-file >>stderr
        ascii <process-reader> stream-lines first
    ] with-directory
] unit-test

[ "error" ] [
    "err2.txt" temp-file ascii file-lines first
] unit-test

[ t ] [
    launcher-test-path [
        <process>
            console-vm "-script" "env.factor" 3array >>command
        ascii <process-reader> stream-contents
    ] with-directory eval( -- alist )

    os-envs =
] unit-test

[ t ] [
    launcher-test-path [
        <process>
            console-vm "-script" "env.factor" 3array >>command
            +replace-environment+ >>environment-mode
            os-envs >>environment
        ascii <process-reader> stream-contents
    ] with-directory eval( -- alist )
    
    os-envs =
] unit-test

[ "B" ] [
    launcher-test-path [
        <process>
            console-vm "-script" "env.factor" 3array >>command
            { { "A" "B" } } >>environment
        ascii <process-reader> stream-contents
    ] with-directory eval( -- alist )

    "A" swap at
] unit-test

[ f ] [
    launcher-test-path [
        <process>
            console-vm "-script" "env.factor" 3array >>command
            { { "USERPROFILE" "XXX" } } >>environment
            +prepend-environment+ >>environment-mode
        ascii <process-reader> stream-contents
    ] with-directory eval( -- alist )

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
                console-vm "-script" "append.factor" 3array >>command
                "append-test" temp-file <appender> >>stdout
            try-process
        ] with-directory
    ] times
   
    "append-test" temp-file ascii file-contents
] unit-test

[ "IN: scratchpad " ] [
    console-vm "-run=listener" 2array
    ascii [ "USE: system 0 exit" print flush lines last ] with-process-stream
] unit-test

[ ] [
    console-vm "-run=listener" 2array
    ascii [ "USE: system 0 exit" print ] with-process-writer
] unit-test

[ ] [
    <process>
    console-vm "-run=listener" 2array >>command
    "vocab:io/launcher/windows/test/input.txt" >>stdin
    try-process
] unit-test

! Regression
[ "asdfdontexistplzplz" >process wait-for-success ]
[
    {
        [ process-failed? ]
        [ process>> process? ]
        [ process>> command>> "asdfdontexistplzplz" = ]
        [ process>> status>> f = ]
    } 1&&
] must-fail-with