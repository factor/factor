USING: accessors arrays assocs calendar
combinators.short-circuit continuations environment eval
hashtables io io.directories io.encodings.ascii
io.encodings.utf8 io.files io.files.temp io.files.unique
io.launcher io.launcher.private io.launcher.windows
io.pathnames kernel math namespaces parser sequences
splitting strings system tools.test ;
IN: io.launcher.windows.tests

: console-vm-path ( -- path )
    vm-path ".exe" ?tail [ ".com" append ] when ;

! Windows environment names are case-insensitive, including non-ASCII
! names. Later entries win without leaving duplicate keys in the block.
{ H{ { "PATH" "new" } { "OTHER" "keep" } } } [
    { { "Path" "old" } { "OTHER" "keep" } }
    { { "PATH" "new" } } environment-union >hashtable
] unit-test

{ H{ { "Ä" "new" } { "SS" "distinct" } { "ß" "sharp" } } } [
    { { "ä" "old" } { "SS" "distinct" } }
    { { "Ä" "new" } { "ß" "sharp" } } environment-union >hashtable
] unit-test

{ V{ { "path" "last" } } } [
    <process> +replace-environment+ >>environment-mode
    { { "Path" "first" } { "path" "last" } } >>environment
    get-environment
] unit-test

{ { "A" "b" } } [
    H{ } { { "b" "second" } { "A" "first" } }
    environment-union keys >array
] unit-test

! Even an empty Unicode environment block needs two NUL code units.
{ { 0 0 } } [
    <process> +replace-environment+ >>environment-mode
    CreateProcess-args new fill-lpEnvironment nip lpEnvironment>> >array
] unit-test

{ { 97 61 98 0 0 } } [
    <process> +replace-environment+ >>environment-mode
    { { "a" "b" } } >>environment
    CreateProcess-args new fill-lpEnvironment nip lpEnvironment>> >array
] unit-test

: child-case-environment ( mode -- value )
    <process> swap >>environment-mode
    console-vm-path "-script"
    "vocab:io/launcher/windows/test/env.factor" 3array >>command
    os-envs [ drop "Factor_Case_Test" environment-key= ] assoc-reject
    { { "FACTOR_CASE_TEST" "child" } } assoc-union >>environment
    utf8 [ read-contents ] with-process-reader eval( -- assoc ) >alist
    [ first "FACTOR_CASE_TEST" environment-key= ] filter
    dup length 1 assert= first second ;

{ "child" "parent" "child" } [
    "parent" "Factor_Case_Test" [
        +append-environment+ child-case-environment
        +prepend-environment+ child-case-environment
        +replace-environment+ child-case-environment
    ] with-os-env
] unit-test

{ "hello world" } [ { "hello" "world" } join-arguments ] unit-test

{ "\"\" \"a\tb\"" } [ { "" "a\tb" } join-arguments ] unit-test
[ "a\0b" escape-argument ] [ invalid-process-argument? ] must-fail-with

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


CONSTANT: argument-cases {
    "" "plain" "two words" "a\tb" "trailing\\" "two words\\\\"
    "\"" "a\"b" "\\\"key=value\\\"" "a\\\\\"b"
    "Örjan" "日本語" "&|<>()^!" "%PATH%" "!PATH!"
    "%%" "%CD%" "%cd:~,%" "%CMDCMDLINE:~-1%&echo BATBADBUT-PROBE"
    "\"&echo BATBADBUT-PROBE&rem \"" "=,;[]{}"
}

: argument-command ( arguments -- command )
    [
        console-vm-path "-no-user-init"
        "vocab:io/launcher/windows/test/argv.factor" absolute-path 3array
    ] dip append ;

: read-arguments ( command -- arguments )
    utf8 [ read-contents ] with-process-reader eval( -- arguments ) ;

{ t } [ argument-cases dup argument-command read-arguments = ] unit-test

{ t } [
    argument-cases dup argument-command
    "vocab:io/launcher/windows/test/argv.cmd" absolute-path prefix
    read-arguments =
] unit-test

! Script paths can themselves contain percent signs, spaces and Unicode.
{ t } [
    [
        "vocab:io/launcher/windows/test/argv.cmd"
        "argv %PATH% & 日本語.CMD" copy-file
        argument-cases dup argument-command
        "argv %PATH% & 日本語.CMD" absolute-path prefix read-arguments =
    ] with-test-directory
] unit-test

{ t t t f } [
    "a.cmd" batch-script? "a.BAT" batch-script?
    "a.CmD. " batch-script? "a.exe" batch-script?
] unit-test

{ "\"%%cd:~,%PATH%%cd:~,%\"" } [ "%PATH%" escape-batch-argument ] unit-test
[ "x\ny" escape-batch-argument ] [ invalid-batch-argument? ] must-fail-with
[ "x\ry" escape-batch-argument ] [ invalid-batch-argument? ] must-fail-with
[ "x\0y" escape-batch-argument ] [ invalid-batch-argument? ] must-fail-with

[
    "vocab:io/launcher/windows/test/argv.cmd"
    8192 CHAR: a <string> 2array batch-command-line
] [ batch-command-line-too-long? ] must-fail-with

! A supplementary character takes two UTF-16 code units on Windows.
[
    "vocab:io/launcher/windows/test/argv.cmd"
    4096 0x1f600 <string> 2array batch-command-line
] [ batch-command-line-too-long? ] must-fail-with

! Notepad may forward to an existing window and exit immediately. Use a
! console child with a known lifetime to exercise process timeout handling.
: timeout-test-command ( -- command )
    console-vm-path "-no-user-init"
    "-e=USING: calendar threads ; 30 seconds sleep" 3array ;

{ } [
    <process>
        timeout-test-command >>command
        1/2 seconds >>timeout
    "timeout-process" set
] unit-test

{ f } [ "timeout-process" get process-running? ] unit-test

{ f } [ "timeout-process" get process-started? ] unit-test

{ } [ "timeout-process" [ run-detached ] change ] unit-test

[ "timeout-process" get wait-for-process ] must-fail

{ t } [ "timeout-process" get killed>> ] unit-test

{ f } [ "timeout-process" get process-running? ] unit-test

[
    <process>
        timeout-test-command >>command
        1/2 seconds >>timeout
    try-process
] must-fail

[
    <process>
        timeout-test-command >>command
        1/2 seconds >>timeout
    try-output-process
] must-fail

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
