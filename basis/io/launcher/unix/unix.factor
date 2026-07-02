! Copyright (C) 2007, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
alien.utilities assocs combinators combinators.short-circuit
continuations environment fry
io.backend io.backend.unix io.encodings.utf8 io.files.private
io.files.unix io.launcher io.launcher.private io.pathnames
io.ports kernel libc math namespaces sequences simple-tokenizer
strings system unix unix.ffi unix.process unix.types ;
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
    SIGPIPE SIG_DFL signal drop ;

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
    dup SIGPIPE 2^ sigset_t <ref>
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

: fd-redirection? ( obj -- ? )
    {
        { [ dup not ] [ drop f ] }
        { [ dup string? ] [ drop f ] }
        { [ dup appender? ] [ drop f ] }
        { [ dup +closed+ eq? ] [ drop f ] }
        { [ dup +stdout+ eq? ] [ drop f ] }
        { [ dup fd? ] [ drop t ] }
        [ underlying-handle fd-redirection? ]
    } cond ;

: spawn-safe-redirection? ( process -- ? )
    {
        [ stdin>> fd-redirection? not ]
        [ stdout>> fd-redirection? not ]
        [
            stderr>> dup +stdout+ eq?
            [ drop t ] [ fd-redirection? not ] if
        ]
    } 1&& ;

: redirect-file* ( actions obj flags fd -- )
    -rot [ normalize-path ] dip file-mode
    posix_spawn_file_actions_addopen check-posix ;

: redirect-file-append* ( actions obj flags fd -- )
    -rot drop path>> normalize-path append-flags file-mode
    posix_spawn_file_actions_addopen check-posix ;

: redirect-closed* ( actions obj flags fd -- )
    [ drop "/dev/null" ] 2dip redirect-file* ;

: redirect* ( actions obj flags fd -- )
    {
        { [ pick not ] [ 4drop ] }
        { [ pick string? ] [ redirect-file* ] }
        { [ pick appender? ] [ redirect-file-append* ] }
        { [ pick +closed+ eq? ] [ redirect-closed* ] }
        [ [ underlying-handle ] 2dip redirect* ]
    } cond ;

: setup-redirection* ( actions attrp argv process -- actions' attrp argv )
    pickd
    [ stdin>> ?closed read-flags 0 redirect* ]
    [ stdout>> ?closed write-flags 1 redirect* ]
    [
        stderr>> dup +stdout+ eq?
        [ drop 1 2 posix_spawn_file_actions_adddup2 check-posix ]
        [ ?closed write-flags 2 redirect* ] if
    ] 2tri ;

: setup-priority* ( pid process -- pid )
    priority>> [
        [
            [ PRIO_PROCESS ] 2dip >prio
            unix.process:setpriority io-error
        ] keepd
    ] when* ;

: spawn-process ( process -- pid )
    {
        [
            [ 0 pid_t <ref> dup ] dip
            get-arguments [
                first utf8 string>alien
                posix-spawn-file-actions-init setup-working-directory
                posix-spawnattr-init reset-ignored-signals*
            ] keep utf8 strings>alien POSIX_SPAWN_SETSIGDEF
        ]
        [
            setup-process-group*
            overd posix_spawnattr_setflags check-posix
        ]
        [ setup-redirection* ]
        [
            get-environment assoc>env utf8 strings>alien
            posix_spawnp check-posix pid_t deref
        ]
        [ setup-priority* ]
    } cleave ;

M: unix (current-process) getpid ;

M: unix (run-process)
    os macos? cpu arm.64? and
    [ dup spawn-safe-redirection? ] [ f ] if
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
