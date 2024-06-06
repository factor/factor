USING: accessors arrays assocs calendar
combinators.short-circuit continuations environment eval
hashtables io io.directories io.encodings.ascii
io.encodings.utf8 io.files io.files.temp io.files.unique
io.launcher io.launcher.private io.launcher.windows
io.pathnames kernel math namespaces parser sequences
splitting system tools.test ;
IN: io.launcher.windows.tests

{ "hello world" } [ { "hello" "world" } join-arguments ] unit-test

{ "bob \"mac arthur\"" } [ { "bob" "mac arthur" } join-arguments ] unit-test

{ "bob mac\\\\arthur" } [ { "bob" "mac\\\\arthur" } join-arguments ] unit-test

{ "bob \"mac arthur\\\\\"" } [ { "bob" "mac arthur\\" } join-arguments ] unit-test

! Bug #245
{ "\\\"hi\\\"" } [ { "\"hi\"" } join-arguments ] unit-test

{ "\"\\\"hi you\\\"\"" } [ { "\"hi you\"" } join-arguments ] unit-test

! Commented line -- what should appear on the command line
! \foo\\bar\\\bas\ -> \foo\\bar\\\bas\
{ "\\foo\\\\bar\\\\\\bas\\" }
[ { "\\foo\\\\bar\\\\\\bas\\" } join-arguments ] unit-test

! \"foo"\\bar\\\bas\ -> \\\"foo\"\\bar\\\bas\
{ "\\\\\\\"foo\\\"\\\\bar\\\\\\bas\\" }
[ { "\\\"foo\"\\\\bar\\\\\\bas\\" } join-arguments ] unit-test

! \foo\\"bar"\\\bas\ -> \foo\\\\\"bar\"\\\bas\
{ "\\foo\\\\\\\\\\\"bar\\\"\\\\\\bas\\" }
[ { "\\foo\\\\\"bar\"\\\\\\bas\\" } join-arguments ] unit-test

! \foo\\bar\\\"bas"\ -> \foo\\bar\\\\\\\"bas\"\
{ "\\foo\\\\bar\\\\\\\\\\\\\\\"bas\\\"\\" }
[ { "\\foo\\\\bar\\\\\\\"bas\"\\" } join-arguments ] unit-test

! \foo\\bar bar\\\bas\ -> "\foo\\bar bar\\\bas\\"
{ "\"\\foo\\\\bar bar\\\\\\bas\\\\\"" }
[ { "\\foo\\\\bar bar\\\\\\bas\\" } join-arguments ] unit-test


{ } [
    <process>
        "notepad" >>command
        1/2 seconds >>timeout
    "notepad" set
] unit-test

{ f } [ "notepad" get process-running? ] unit-test

{ f } [ "notepad" get process-started? ] unit-test

{ } [ "notepad" [ run-detached ] change ] unit-test

[ "notepad" get wait-for-process ] must-fail

{ t } [ "notepad" get killed>> ] unit-test

{ f } [ "notepad" get process-running? ] unit-test

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

: console-vm-path ( -- path )
    vm-path ".exe" ?tail [ ".com" append ] when ;

SYMBOLS: out-path err-path ;

! +same-group+
{ "Hello world" } [
    <process>
        console-vm-path "-run=hello-world" 2array >>command
        [ "out" ".txt" unique-file ] with-temp-directory
        [ out-path set-global ] keep >>stdout
        +stdout+ >>stderr
        10 seconds >>timeout
        +same-group+ >>group
    try-process
    out-path get-global ascii file-lines first
] unit-test

! +new-group+
{ "Hello world" } [
    <process>
        console-vm-path "-run=hello-world" 2array >>command
        [ "out" ".txt" unique-file ] with-temp-directory
        [ out-path set-global ] keep >>stdout
        +stdout+ >>stderr
        10 seconds >>timeout
        +new-group+ >>group
    try-process
    out-path get-global ascii file-lines first
] unit-test

{ "IN: scratchpad " } [
    <process>
        console-vm-path "-run=listener" 2array >>command
        +closed+ >>stdin
        +stdout+ >>stderr
    utf8 [ read-lines last ] with-process-reader
] unit-test

: launcher-test-path ( -- str )
    "resource:basis/io/launcher/windows/test" ;

{ } [
    launcher-test-path [
        <process>
            console-vm-path "-script" "stderr.factor" 3array >>command
            [ "out" ".txt" unique-file ] with-temp-directory
            [ out-path set-global ] keep >>stdout
            [ "err" ".txt" unique-file ] with-temp-directory
            [ err-path set-global ] keep >>stderr
        try-process
    ] with-directory
] unit-test

{ "output" } [
    out-path get-global ascii file-lines first
] unit-test

{ "error" } [
    err-path get-global ascii file-lines first
] unit-test

{ } [
    launcher-test-path [
        <process>
            console-vm-path "-script" "stderr.factor" 3array >>command
            [ "out" ".txt" unique-file ] with-temp-directory
            [ out-path set-global ] keep >>stdout
            +stdout+ >>stderr
        try-process
    ] with-directory
] unit-test

{ "outputerror" } [
    out-path get-global ascii file-lines first
] unit-test

{ "output" } [
    launcher-test-path [
        <process>
            console-vm-path "-script" "stderr.factor" 3array >>command
            [ "err2" ".txt" unique-file ] with-temp-directory
            [ err-path set-global ] keep >>stderr
        process-contents
    ] with-directory
] unit-test

{ "error" } [
    err-path get-global ascii file-lines first
] unit-test

{ t } [
    launcher-test-path [
        <process>
            console-vm-path "-script" "env.factor" 3array >>command
        utf8 [ read-contents ] with-process-reader
    ] with-directory eval( -- alist )

    os-envs =
] unit-test

{ t } [
    launcher-test-path [
        <process>
            console-vm-path "-script" "env.factor" 3array >>command
            +replace-environment+ >>environment-mode
            os-envs >>environment
        utf8 [ read-contents ] with-process-reader
    ] with-directory eval( -- alist )

    os-envs =
] unit-test

{ "B" } [
    launcher-test-path [
        <process>
            console-vm-path "-script" "env.factor" 3array >>command
            { { "A" "B" } } >>environment
        utf8 [ read-contents ] with-process-reader
    ] with-directory eval( -- alist )

    "A" of
] unit-test

{ f } [
    launcher-test-path [
        <process>
            console-vm-path "-script" "env.factor" 3array >>command
            { { "USERPROFILE" "XXX" } } >>environment
            +prepend-environment+ >>environment-mode
        utf8 [ read-contents ] with-process-reader
    ] with-directory eval( -- alist )

    "USERPROFILE" of "XXX" =
] unit-test

2 [
    { } [
        <process>
            "cmd.exe /c dir" >>command
            [ "dir" ".txt" unique-file ] with-temp-directory
            [ out-path set-global ] keep >>stdout
        try-process
    ] unit-test

    { } [ out-path get-global delete-file ] unit-test
] times

{ "Hello appender\r\nÖrjan ågren är åter\r\nHello appender\r\nÖrjan ågren är åter\r\n" } [
    [ "append-test" "" unique-file ] with-temp-directory out-path set-global
    2 [
        launcher-test-path [
            <process>
                console-vm-path "-script" "append.factor" 3array >>command
                out-path get-global <appender> >>stdout
            try-process
        ] with-directory
    ] times

    out-path get-global utf8 file-contents
] unit-test

{ t "This is a hidden process.\r\n" } [
    "cmd /c echo.This is a hidden process." utf8 (process-stream) hidden>> swap stream-contents
] unit-test

{ "IN: scratchpad " } [
    console-vm-path "-run=listener" 2array
    ascii [ "quit" print flush read-lines last ] with-process-stream
] unit-test

{ } [
    console-vm-path "-run=listener" 2array
    ascii [ "quit" print ] with-process-writer
] unit-test

{ } [
    <process>
    console-vm-path "-run=listener" 2array >>command
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
