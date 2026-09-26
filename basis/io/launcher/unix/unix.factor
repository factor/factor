! Copyright (C) 2007, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.destructors alien.strings
alien.utilities assocs byte-arrays combinators concurrency.flags continuations destructors
environment environment.unix fry
io.backend io.backend.unix io.backend.unix.multiplexers
io.encodings.utf8 io.files.info io.files.private
io.files.unix io.launcher io.launcher.private io.pathnames
io.ports kernel libc locals math namespaces sequences simple-tokenizer
splitting strings system unix unix.ffi unix.process unix.types ;
QUALIFIED-WITH: unix.signals sig
IN: io.launcher.unix

: get-arguments ( process -- seq )
    command>> dup string? [ tokenize ] when ;

: assoc>env ( assoc -- env )
    [ "=" glue ] { } assoc>map ;

: setup-process-group ( process -- process )
    dup group>> {
        { +same-group+ [ ] }
        { +new-group+ [ 0 0 setpgid io-error ] }
        { +new-session+ [ setsid io-error ] }
    } case ;

: >prio ( priority -- prio )
    {
        { +lowest-priority+ [ 20 ] }
        { +low-priority+ [ 10 ] }
        { +normal-priority+ [ 0 ] }
        { +high-priority+ [ -10 ] }
        { +highest-priority+ [ -20 ] }
        { +realtime-priority+ [ -20 ] }
    } case ;

: setup-priority ( process -- process )
    dup priority>> [ >prio set-priority ] when* ;

: reset-fd ( fd -- )
    [ F_SETFL 0 fcntl io-error ] [ F_SETFD 0 fcntl io-error ] bi ;

: redirect-fd ( oldfd fd -- )
    2dup = [ 2drop ] [ dup2 io-error ] if ;

: redirect-file ( obj flags fd -- )
    [ [ normalize-path ] dip file-mode open-file ] dip redirect-fd ;

: redirect-file-append ( obj flags fd -- )
    [ drop path>> normalize-path open-append ] dip redirect-fd ;

: redirect-closed ( obj flags fd -- )
    [ drop "/dev/null" ] 2dip redirect-file ;

: redirect ( obj flags fd -- )
    {
        { [ pick not ] [ 3drop ] }
        { [ pick string? ] [ redirect-file ] }
        { [ pick appender? ] [ redirect-file-append ] }
        { [ pick +closed+ eq? ] [ redirect-closed ] }
        { [ pick fd? ] [ [ drop fd>> dup reset-fd ] dip redirect-fd ] }
        [ [ underlying-handle ] 2dip redirect ]
    } cond ;

: ?closed ( obj -- obj' )
    dup +closed+ eq? [ drop "/dev/null" ] when ;

: setup-redirection ( process -- process )
    dup stdin>> ?closed read-flags 0 redirect
    dup stdout>> ?closed write-flags 1 redirect
    dup stderr>> dup +stdout+ eq? [
        drop 1 2 dup2 io-error
    ] [
        ?closed write-flags 2 redirect
    ] if ;

: setup-environment ( process -- process )
    dup pass-environment? [
        dup get-environment set-os-envs
    ] when ;

! Ignored signals are not reset to the default handler.
: reset-ignored-signals ( -- )
    SIGPIPE SIG_DFL signal SIG_ERR = [ throw-errno ] when ;

: fork-process ( process -- pid )
    [ reset-ignored-signals ] [ 2drop 248 _exit ] recover
    [ setup-process-group ] [ 2drop 249 _exit ] recover
    [ setup-priority ] [ 2drop 250 _exit ] recover
    [ setup-redirection ] [ 2drop 251 _exit ] recover
    [ current-directory get cd ] [ 2drop 252 _exit ] recover
    [ setup-environment ] [ 2drop 253 _exit ] recover
    [ get-arguments exec-args-with-path ] [ 2drop 254 _exit ] recover
    255 _exit
    f throw ;

: setup-working-directory ( actions -- actions' )
    dup current-directory get
    posix-spawn-file-actions-addchdir ;

: reset-ignored-signals* ( attrp -- attrp' )
    dup sigset_t heap-size <byte-array>
    dup sigemptyset io-error
    dup SIGPIPE sigaddset io-error
    posix_spawnattr_setsigdefault check-posix ;

: setup-process-group* ( attrp argv flags process -- attrp' argv flags' )
    group>> {
        { +same-group+ [ ] }
        { +new-group+ [
            POSIX_SPAWN_SETPGROUP bitor
            pick 0 posix_spawnattr_setpgroup check-posix
        ] }
        { +new-session+ [ POSIX_SPAWN_SETSID bitor ] }
    } case ;

: reset-fd* ( actions fd -- )
    dup F_SETFL 0 fcntl io-error
    posix_spawn_file_actions_addinherit_np check-posix ;

: redirect-fd* ( actions oldfd fd -- )
    2dup =
    [ 3drop ]
    [ posix_spawn_file_actions_adddup2 check-posix ] if ;

: redirect-file* ( actions obj flags fd -- )
    -rot [ normalize-path ] dip file-mode
    posix_spawn_file_actions_addopen check-posix ;

: redirect-file-append* ( actions obj flags fd -- )
    -rot drop path>> normalize-path append-flags file-mode
    posix_spawn_file_actions_addopen check-posix ;

SYMBOL: spawn-null-fd

: open-spawn-null ( -- fd )
    "/dev/null" O_RDWR file-mode open-file &close-file
    dup F_SETFD FD_CLOEXEC fcntl io-error ;

: spawn-null ( -- fd )
    spawn-null-fd get [
        ! Keep the source above stdio, even if the parent has closed stdio.
        open-spawn-null [ dup 3 < ] [ drop open-spawn-null ] while
        dup spawn-null-fd set
    ] unless* ;

: redirect-closed* ( actions obj flags fd -- )
    [ 2drop spawn-null ] dip redirect-fd* ;

: redirect* ( actions obj flags fd -- )
    {
        { [ pick not ] [ 4drop ] }
        { [ pick string? ] [ redirect-file* ] }
        { [ pick appender? ] [ redirect-file-append* ] }
        { [ pick +closed+ eq? ] [ redirect-closed* ] }
        { [ pick fd? ] [ [ drop fd>> 2dup reset-fd* ] dip redirect-fd* ] }
        [ [ underlying-handle ] 2dip redirect* ]
    } cond ;

: setup-redirection* ( actions attrp argv process -- actions' attrp argv )
    pickd
    [ stdin>> read-flags 0 redirect* ]
    [ stdout>> write-flags 1 redirect* ]
    [
        stderr>> dup +stdout+ eq?
        [ drop 1 2 posix_spawn_file_actions_adddup2 check-posix ]
        [ write-flags 2 redirect* ] if
    ] 2tri ;

: setup-priority* ( pid process -- pid )
    priority>> [
        [
            [ PRIO_PROCESS ] 2dip >prio
            unix.process:setpriority io-error
        ] keepd
    ] when* ;

DESTRUCTOR: posix-spawn-file-actions-destroy
DESTRUCTOR: posix-spawnattr-destroy

! argv and custom envp strings only need to live until posix_spawnp returns.
: spawn-strings ( strings -- argv )
    [ utf8 malloc-string &free ] map f suffix void* >c-array ;

: spawn-environment ( process -- envp )
    dup pass-environment?
    [ get-environment assoc>env spawn-strings ]
    [ drop environ void* deref ] if ;

! Probe PATH entries before spawning: on macOS, unsuccessful spawnp attempts
! are much more expensive than checking whether an executable exists.
: spawn-candidate? ( path -- ? )
    [ dup X_OK access 0 = [ directory? not ] [ drop f ] if ]
    [ 2drop f ] recover ;

:: spawn-executable ( command -- path/f )
    CHAR: / command member? [ command ] [
        "PATH" os-env [
            ":" split [
                command append-path normalize-path
                dup spawn-candidate?
                [ drop f ] unless
            ] map-find drop
        ] [ f ] if*
    ] if ;

:: spawn-command ( pid command actions attr argv env -- error )
    command spawn-executable [| path |
        pid path actions attr argv env posix_spawn
        dup 0 = [ ] [
            ! Let libc preserve search errors and executable-format behavior
            ! if a candidate changed or could not actually be executed.
            drop pid command actions attr argv env posix_spawnp
        ] if
    ] [ pid command actions attr argv env posix_spawnp ] if* ;

: (spawn-process) ( process -- pid )
    {
        [
            [ 0 pid_t <ref> dup ] dip
            get-arguments [
                first
                posix-spawn-file-actions-init &posix-spawn-file-actions-destroy
                setup-working-directory
                posix-spawnattr-init &posix-spawnattr-destroy reset-ignored-signals*
            ] keep spawn-strings POSIX_SPAWN_SETSIGDEF
        ]
        [
            setup-process-group*
            overd posix_spawnattr_setflags check-posix
        ]
        [ setup-redirection* ]
        [
            spawn-environment
            spawn-command check-posix pid_t deref
        ]
        [ setup-priority* ]
    } cleave ;

: spawn-process ( process -- pid )
    f spawn-null-fd [ [ (spawn-process) ] with-destructors ] with-variable ;

M: unix (current-process) getpid ;

M: unix (process-notifications?)
    [
        [ wait-flag get-global raise-flag ] SIGCHLD
        mx get-global add-signal-callback
    ] [ drop f ] recover ;

M: unix (run-process)
    os macos? cpu arm.64? and
    [ spawn-process ] [ '[ _ fork-process ] [ ] with-fork ] if ;

M: unix (kill-process)
    [ handle>> SIGTERM ] [ group>> ] bi {
        { +same-group+ [ kill ] }
        { +new-group+ [ killpg ] }
        { +new-session+ [ killpg ] }
    } case io-error ;

: find-process ( handle -- process )
    processes get keys [ handle>> = ] with find nip ;

: code>status ( code -- obj )
    dup WIFSIGNALED [ WTERMSIG sig:signal boa ] [ WEXITSTATUS ] if ;

M: unix (wait-for-processes)
    { int } [ -1 swap WNOHANG waitpid ] with-out-parameters
    swap dup 0 <= [
        2drop t
    ] [
        find-process dup
        [ swap code>status notify-exit f ] [ 2drop f ] if
    ] if ;
