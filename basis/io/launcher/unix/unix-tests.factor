USING: accessors alien.c-types alien.libraries arrays byte-arrays calendar concurrency.promises
continuations destructors environment io
io.backend.unix io.directories io.encodings.ascii
io.encodings.binary io.encodings.utf8 io.files io.files.info.unix
io.launcher io.launcher.unix io.pathnames
io.streams.duplex io.timeouts kernel libc locals math namespaces
sequences sets system threads tools.test tools.test.unix unix.process unix.signals unix.types ;
IN: io.launcher.unix.tests

! PATH is resolved against Factor's child directory and read afresh each time.
[
    "first" make-directory "second" make-directory
    "" test-script
    [ "echo first" append "first/launcher-path-test" utf8 set-file-contents ]
    [ "echo second" append "second/launcher-path-test" utf8 set-file-contents ] bi
    "first/launcher-path-test" 0o755 set-file-permissions
    "second/launcher-path-test" 0o755 set-file-permissions

    { "first\n" "second\n" } [
        "first:second" "PATH" [ { "launcher-path-test" } process-contents ] with-os-env
        "second:first" "PATH" [ { "launcher-path-test" } process-contents ] with-os-env
    ] unit-test

    ! A directory with the command's name cannot shadow a later executable.
    "first/launcher-path-test" delete-file
    "first/launcher-path-test" make-directory
    { "second\n" } [
        "first:second" "PATH" [ { "launcher-path-test" } process-contents ] with-os-env
    ] unit-test

    { "second\n" } [
        "second" [
            ":/nonexistent-factor-path" "PATH"
            [ { "launcher-path-test" } process-contents ] with-os-env
        ] with-directory
    ] unit-test

    ! Non-executable candidates are skipped; a slash bypasses PATH lookup.
    "second/launcher-path-test" 0o644 set-file-permissions
    { f } [ "second" "PATH" [ "launcher-path-test" spawn-executable ] with-os-env ] unit-test
    { "./second/launcher-path-test" } [ "./second/launcher-path-test" spawn-executable ] unit-test
] with-test-directory

! Killing an exited process must preserve its successful status.
{ } [
    { "true" } run-detached
    [ wait-for-success ] [ kill-process ] [ wait-for-success ] tri
] unit-test

! Fast exits and coalesced SIGCHLD notifications must not strand any waiters.
{ } [
    5 [
        100 [
            <process> { "true" } >>command 5 seconds >>timeout run-detached
        ] replicate wait-for-success
    ] times
] unit-test

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
            { "sleep" "1000" } run-detached
            [ p fulfill ] [ wait-for-process s fulfill ] bi
        ] in-thread

        p 1 seconds ?promise-timeout (kill-process)
        s 3 seconds ?promise-timeout 0 =
    ]
] unit-test

! Termination can arrive between fork and exec, before the VM's signal
! handlers have been replaced. It must still terminate the child.
{ t } [
    20 [
        "sleep 1" run-detached
        [ (kill-process) ] [ wait-for-process signal? ] bi
    ] replicate [ ] all?
] unit-test

! Make sure that subprocesses don't inherit our ignored signal disposition

! First, ensure that the Factor VM ignores SIGPIPE
: send-sigpipe ( pid -- )
    "SIGPIPE" signal-names index 1 +
    kill io-error ;

{ } [ (current-process) send-sigpipe ] unit-test

! Spawn a process
SIGPIPE signal boa 1array [
    { "sleep" "1000" } run-detached
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
    SIGPIPE unix.ffi:SIG_IGN unix.ffi:signal drop
    [
        reset-ignored-signals
        SIGPIPE unix.ffi:SIG_IGN unix.ffi:signal unix.ffi:SIG_DFL =
    ] [ SIGPIPE unix.ffi:SIG_IGN unix.ffi:signal drop ] finally ;

{ t } [ test-reset-sigpipe ] unit-test

! A sigset_t is opaque; shifting by the signal number also selected SIGALRM.
! Older Bionic uses fork and does not expose POSIX spawn attributes.
"posix_spawnattr_getsigdefault" f dlsym? [
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
] when

! Use the base system shell for the priority and process-group tests.
! Test priority
{ 0 } [
    <process>
        { "-c" "sleep 2&" } test-shell prefix >>command
        +low-priority+ >>priority
    run-process status>>
] unit-test

! Check that processes launched with the group option kill their children (or not)
! This test should leave two sleeps running for 30 seconds.
[
    <process> { "-c" "sleep 30& sleep 30" } test-shell prefix >>command
        +same-group+ >>group
        500 milliseconds >>timeout
    run-process
] [ process-was-killed? ] must-fail-with

! This test should kill the sleep after 500ms.
[
    <process> { "-c" "sleep 30& sleep 30" } test-shell prefix >>command
        +new-group+ >>group
        500 milliseconds >>timeout
    run-process
] [ process-was-killed? ] must-fail-with

! This test should kill the sleep after 500ms.
[
    <process> { "-c" "sleep 30& sleep 30" } test-shell prefix >>command
        +new-session+ >>group
        500 milliseconds >>timeout
    run-process
] [ process-was-killed? ] must-fail-with

! Regression: native readiness can queue a reader before its timer closes the pipe.
USING: alien.data assocs concurrency.promises.private
 io.backend.unix.multiplexers io.launcher.private io.pipes io.ports
 system unix.ffi unix.time words ;

: process-pipe-timeout ( process quot -- ) with-process-io-timeout ; inline

! A real process subclass controls only the native readiness/cancellation order.
! Cancellation is reached by the original timer, never manually invoked here.
TUPLE: timeout-order-process < process readiness-first? callback-observed? reaped? ;

M: timeout-order-process cancel-operation
    dup reaped?>> [
        dup handle>> [ "timer reached child before original notify-exit" throw ] when
        dup killed>> [ "normal exit incorrectly marked killed" throw ] when
    ] [
        dup handle>> [ "live timer lost child handle before cancellation" throw ] unless
    ] if
    t >>callback-observed?
    dup readiness-first?>> [
        dup pipe>> in>> fd>> mx get-global input-available
    ] when
    kill-process ;

! Haiku's installed SIGCHLD handler captures launcher-owned statuses natively.
! Consume that authoritative record without yielding to Factor's timer thread.
! Raw waitpid would compete with the handler even without a scheduler yield.
:: haiku-timeout-order-exit ( pid -- reaped-pid status )
    f :> reaped-pid! f :> status!
    nano-count 30,000,000,000 + :> deadline
    [ reaped-pid not nano-count deadline < and ] [
        { int int } [
            "factor_haiku_next_process_exit" "io.launcher.haiku" lookup-word
            execute( pid-out status-out -- available )
        ] with-out-parameters :> ( available child raw-status )
        available io-error
        available 1 = [
            child pid = [ child reaped-pid! raw-status status! ] [
                child find-process dup [ raw-status code>status notify-exit ]
                [ drop "authoritative Haiku exit has unknown owner" throw ] if
            ] if
        ] when
        reaped-pid not [
            ! A native select pause lets the child run but not the Factor timer.
            0 f f f 1000 make-timeval unix.ffi:select
            0 < [ errno EINTR = [ "native Haiku exit pause failed" throw ] unless ] when
        ] when
    ] while
    reaped-pid [ reaped-pid status ]
    [ "authoritative Haiku exact child exit timed out" throw ] if ;

:: timeout-order-native-exit ( pid -- reaped-pid status )
    os haiku? [ pid haiku-timeout-order-exit ] [
        { int } [ pid swap 0 unix.process:waitpid ] with-out-parameters
    ] if ;

:: reaped-timeout-order ( readiness-first? -- error )
    (pipe) :> release-pipe
    timeout-order-process new
        H{ } clone >>environment +append-environment+ >>environment-mode
        +new-group+ >>group readiness-first? >>readiness-first? t >>reaped?
        { "sh" "-c" "printf R; read token; sleep 60 & exit 0" } >>command
        release-pipe in>> >>stdin 100 milliseconds >>timeout
    binary (process-reader) :> ( stream process )
    release-pipe in>> dispose
    process handle>> :> pid
    f :> group-owned?!
    stream underlying-port :> port
    <promise> :> ready <promise> :> done
    [
        ! fork returns before the child sets its group. A byte from the executed
        ! shell proves group setup and redirection completed without polling.
        port 30 seconds [ stream-read1 ] with-timeout* 82 =
        [ "helper readiness byte not observed" throw ] unless
        pid getpgid pid = [ "helper process group is not uniquely owned" throw ] unless
        t group-owned?!
        [
            [ process [ drop t ready (fulfill)
                port stream-read1 drop f ] process-pipe-timeout
            ] [ ] recover done (fulfill)
        ] "Actual timer after reaped child" spawn drop
        ready 30 seconds ?promise-timeout drop
        port handle>> fd>> mx get-global reads>> key?
        [ "genuine timer reader not registered" throw ] unless
        ! Background sleep retains stdout while the original child exits.
        ! No scheduler yield occurs between this native write and exact waitpid.
        release-pipe out>> fd>> B{ 10 } 1 unix.ffi:write
        1 = [ "genuine timer stdin release failed" throw ] unless
        pid timeout-order-native-exit :> ( reaped-pid status )
        reaped-pid pid = [ "genuine timer exact child not reaped" throw ] unless
        status code>status dup 0 = [ "genuine timer child not normal exit" throw ] unless
        process swap notify-exit
        done 30 seconds ?promise-timeout
        process callback-observed?>> [ "actual timer callback not observed" throw ] unless
        process handle>> [ "timer changed normal reaped handle" throw ] when
        process killed>> [ "timer changed normal reaped killed state" throw ] when
        process status>> 0 = [ "timer changed normal exit status" throw ] unless
    ] [
        ! Reaped child started its helper in this uniquely owned process group.
        [
            group-owned? [ pid SIGTERM killpg drop ] [
                ! Before ownership proof, signal only the still-owned child PID.
                process handle>> pid = [ pid SIGTERM kill drop ] when
            ] if
        ] ignore-errors
        [ stream dispose release-pipe dispose ] ignore-errors
    ] finally ;

{ t } [ f reaped-timeout-order io-timeout? ] unit-test
! Baseline ready-first expects already-disposed; scoped candidate io-timeout.
{ t } [ t reaped-timeout-order io-timeout? ] unit-test

:: live-timeout-order ( readiness-first? -- error )
    timeout-order-process new
        H{ } clone >>environment +append-environment+ >>environment-mode
        +same-group+ >>group readiness-first? >>readiness-first?
        { "sleep" "60" } >>command 100 milliseconds >>timeout
    binary (process-reader) :> ( stream process )
    <promise> :> ready <promise> :> done
    [
        [
            [ process [ drop t ready (fulfill)
                stream underlying-port stream-read1 drop f ] process-pipe-timeout
            ] [ ] recover done (fulfill)
        ] "Actual timer on live child" spawn drop
        ready 30 seconds ?promise-timeout drop
        stream underlying-port handle>> fd>> mx get-global reads>> key?
        [ "live timer reader not registered" throw ] unless
        done 30 seconds ?promise-timeout
        process callback-observed?>> [ "live actual timer not observed" throw ] unless
        process killed>> [ "live timer failed to mark killed" throw ] unless
    ] [
        [ stream dispose ] ignore-errors
        [ process kill-process process (wait-for-process) drop ] ignore-errors
    ] finally ;

:: untimed-process-pipe-disposal ( -- error )
    <process> { "sleep" "60" } >>command
    binary (process-reader) :> ( stream process )
    process timeout [ "untimed fixture has a timeout" throw ] when
    process kill-process
    [ process [ drop stream stream-read1 drop f ] process-pipe-timeout ] [ ] recover
    [ stream dispose process (wait-for-process) drop ] ignore-errors ;

{ t } [ f live-timeout-order io-timeout? ] unit-test
{ t } [ t live-timeout-order io-timeout? ] unit-test
{ t } [ untimed-process-pipe-disposal already-disposed? ] unit-test
