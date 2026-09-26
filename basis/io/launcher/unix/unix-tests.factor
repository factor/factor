USING: accessors alien.c-types byte-arrays calendar concurrency.promises
continuations destructors environment io
io.backend.unix io.directories io.encodings.ascii
io.encodings.binary io.encodings.utf8 io.files
io.launcher io.launcher.unix
io.streams.duplex io.timeouts kernel libc locals math namespaces
sequences sets threads tools.test unix.process unix.signals unix.types ;
IN: io.launcher.unix.tests

! Temporary C strings must be released on success and on an exception.
{ t } [
    disposables get cardinality
    [ { "cat" "test argument" } spawn-strings drop ] with-destructors
    disposables get cardinality =
] unit-test

! The discarded streams share a temporary descriptor, not an inherited one.
{ } [
    <process> { "cat" } >>command
    +closed+ >>stdin +closed+ >>stdout +closed+ >>stderr try-process
] unit-test

{ t } [
    disposables get cardinality
    [
        <process> { "/nonexistent-factor-spawn-test" } >>command
        +closed+ >>stdin +closed+ >>stdout +closed+ >>stderr
        run-detached drop
    ] ignore-errors
    disposables get cardinality =
] unit-test

{ t } [
    disposables get cardinality
    [ [ { "cat" "test argument" } spawn-strings drop
        "spawn setup failed" throw ] with-destructors ] ignore-errors
    disposables get cardinality =
] unit-test

! Inheritance reads the live environment rather than a cached snapshot.
{ "first" "second" } [
    "first" "FACTOR_SPAWN_TEST" [
        { "sh" "-c" "printf %s \"$FACTOR_SPAWN_TEST\"" } process-contents
    ] with-os-env
    "second" "FACTOR_SPAWN_TEST" [
        { "sh" "-c" "printf %s \"$FACTOR_SPAWN_TEST\"" } process-contents
    ] with-os-env
] unit-test

[
    { } [ { "touch" "launcher-test-1" } try-process ] unit-test

    { t } [ "launcher-test-1" file-exists? ] unit-test

    { } [
        "launcher-test-1" ?delete-file
    ] unit-test

    { } [
        <process>
            "echo Hello" >>command
            "launcher-test-1" >>stdout
        try-process
    ] unit-test

    { "Hello\n" } [
        { "cat" "launcher-test-1" }
        ascii <process-reader> stream-contents
    ] unit-test

    { } [
        "launcher-test-1" ?delete-file
    ] unit-test

    { } [
        <process>
            "cat" >>command
            +closed+ >>stdin
            "launcher-test-1" >>stdout
        try-process
    ] unit-test

    { "" } [
        { "cat" "launcher-test-1" }
        ascii <process-reader> stream-contents
    ] unit-test

    { } [
        2 [
            "launcher-test-1" binary <file-appender> [
                <process>
                    swap >>stdout
                    "echo Hello" >>command
                try-process
            ] with-disposal
        ] times
    ] unit-test

    { "Hello\nHello\n" } [
        { "cat" "launcher-test-1" }
        ascii <process-reader> stream-contents
    ] unit-test

    { "hi\n" } [
        <process>
            { "echo" "hi" } >>command
            "launcher-test-2" >>stdout
        try-process
        "launcher-test-2" utf8 file-contents
    ] unit-test

    { "hi\nhi\n" } [
        2 [
            <process>
                "echo hi" >>command
                "launcher-test-3" <appender> >>stdout
            try-process
        ] times
        "launcher-test-3" utf8 file-contents
    ] unit-test

] with-test-directory

{ t } [
    <process>
        "env" >>command
        { { "A" "B" } } >>environment
    ascii <process-reader> stream-lines
    "A=B" swap member?
] unit-test

{ { "A=B" } } [
    <process>
        "env" >>command
        { { "A" "B" } } >>environment
        +replace-environment+ >>environment-mode
    ascii <process-reader> stream-lines
] unit-test

{ t } [
    "ls" utf8 <process-stream> stream-contents >boolean
] unit-test

{ "Hello world.\n" } [
    "cat" utf8 <process-stream> [
        "Hello world.\n" write
        output-stream get dispose
        input-stream get stream-contents
    ] with-stream
] unit-test

{ 524288 } [
    <process>
        { "sh" "-c" "dd if=/dev/zero bs=65536 count=8 2>/dev/null" } >>command
    binary <process-reader> stream-contents length
] unit-test

! Test process timeouts
[
    <process>
        { "sleep" "10" } >>command
        1 seconds >>timeout
    run-process
] [ process-was-killed? ] must-fail-with

[
    <process>
        { "sleep" "10" } >>command
        1 seconds >>timeout
    try-process
] [ process-was-killed? ] must-fail-with

[
    <process>
        { "sleep" "10" } >>command
        1 seconds >>timeout
    try-output-process
] [ io-timeout? ] must-fail-with

! Killed processes were exiting with code 0 on FreeBSD
{ f } [
    [let
        <promise> :> p
        <promise> :> s

        [
            "sleep 1000" run-detached
            [ p fulfill ] [ wait-for-process s fulfill ] bi
        ] in-thread

        p 1 seconds ?promise-timeout (kill-process)
        s 3 seconds ?promise-timeout 0 =
    ]
] unit-test

! Make sure that subprocesses don't inherit our ignored signal disposition

! First, ensure that the Factor VM ignores SIGPIPE
: send-sigpipe ( pid -- )
    "SIGPIPE" signal-names index 1 +
    kill io-error ;

{ } [ (current-process) send-sigpipe ] unit-test

! Spawn a process
{ T{ signal f 13 } } [
    "sleep 1000" run-detached
    1 seconds sleep
    [ handle>> send-sigpipe ]
    [ 2 seconds swap set-timeout ]
    [ wait-for-process ]
    tri
] unit-test

USING: alien.c-types byte-arrays continuations io.launcher.unix
unix.types ;
QUALIFIED: unix.ffi

! Check the disposition before exec, which would reset a bogus handler.
:: test-reset-sigpipe ( -- default? )
    SIGPIPE unix.ffi:SIG_IGN unix.ffi:signal :> previous
    [
        reset-ignored-signals
        SIGPIPE unix.ffi:SIG_IGN unix.ffi:signal unix.ffi:SIG_DFL =
    ] [ SIGPIPE previous unix.ffi:signal drop ] finally ;

{ t } [ test-reset-sigpipe ] unit-test

! A sigset_t is opaque; shifting by the signal number also selected SIGALRM.
{ 1 0 } [
    posix-spawnattr-init [
        [
            reset-ignored-signals*
            sigset_t heap-size <byte-array>
            [ posix_spawnattr_getsigdefault check-posix ] keep
            [ SIGPIPE sigismember ] [ SIGALRM sigismember ] bi
        ] keep
    ] [ posix-spawnattr-destroy ] finally
] unit-test

! Test priority
{ 0 } [
    <process>
        { "bash" "-c" "sleep 2&" } >>command
        +low-priority+ >>priority
    run-process status>>
] unit-test

! Check that processes launched with the group option kill their children (or not)
! This test should leave two sleeps running for 30 seconds.
[
    <process> { "bash" "-c" "sleep 30& sleep 30" } >>command
        +same-group+ >>group
        500 milliseconds >>timeout
    run-process
] [ process-was-killed? ] must-fail-with

! This test should kill the sleep after 500ms.
[
    <process> { "bash" "-c" "sleep 30& sleep 30" } >>command
        +new-group+ >>group
        500 milliseconds >>timeout
    run-process
] [ process-was-killed? ] must-fail-with

! This test should kill the sleep after 500ms.
[
    <process> { "bash" "-c" "sleep 30& sleep 30" } >>command
        +new-session+ >>group
        500 milliseconds >>timeout
    run-process
] [ process-was-killed? ] must-fail-with
