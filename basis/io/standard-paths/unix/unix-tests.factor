! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators continuations destructors environment hashtables io io.directories io.encodings.utf8 io.files
io.files.info io.files.info.unix io.files.links io.pathnames io.standard-paths
io.standard-paths.unix io.encodings.binary io.encodings.string io.launcher io.launcher.private io.streams.duplex kernel libc locals namespaces sequences splitting
system tools.test tools.test.unix unix.users ;
IN: io.standard-paths.unix.tests

! Installed commands may live in a Nix/Guix store or a system profile. The
! fixtures below verify search order; these checks verify real executables.
:: executable-named? ( path name -- ? )
    path [ path file-name name = path file-executable? and ] [ f ] if ;

: path-fixture ( -- )
    { "blocked" "directory" "valid" } [ make-directory ] each
    "not executable" "blocked/probe" utf8 set-file-contents
    "blocked/probe" 0o644 set-file-permissions
    "directory/probe" make-directory
    "exit 0\n" test-script "valid/probe" utf8 set-file-contents
    "valid/probe" 0o755 set-file-permissions ;

{ t } [
    [
        path-fixture
        { "blocked" "directory" "valid" } [ absolute-path ] map ":" join
        "PATH" [ "probe" find-in-path "valid/probe" absolute-path = ] with-os-env
    ] with-test-directory
] unit-test

{ f } [
    [
        path-fixture
        "blocked:directory" "PATH" [ "probe" find-in-path ] with-os-env
    ] with-test-directory
] unit-test

{ t } [
    [
        path-fixture "links" make-directory
        "valid/probe" absolute-path "links/probe" make-link
        "links:valid" "PATH" [ "probe" find-in-path "links/probe" = ] with-os-env
    ] with-test-directory
] unit-test

{ t } [
    [
        path-fixture "links" make-directory
        "absent" "links/probe" make-link
        "links:valid" "PATH" [ "probe" find-in-path "valid/probe" = ] with-os-env
    ] with-test-directory
] unit-test

{ t } [
    [
        "exit 0\n" test-script "probe" utf8 set-file-contents
        "probe" 0o755 set-file-permissions
        "" "PATH" [ "probe" find-in-path "probe" = ] with-os-env
    ] with-test-directory
] unit-test

{ f } [ f "PATH" [ "ls" find-in-path ] with-os-env ] unit-test

{ f } [ "" find-in-path ] unit-test
{ t } [
    "ls" find-in-path "ls" executable-named?
] unit-test

{ t } [
    "/factor-nonexistent-path:" "PATH" os-env append "PATH" [
        "ps" find-in-path "ps" executable-named?
    ] with-os-env
] unit-test

{ t } [
    "ls" find-in-standard-login-path "ls" executable-named?
] unit-test

! Shell startup output must not become part of the search directories.
{ { "/bin" "/usr/bin" } } [
    "warning: startup\nfortune: text\n__FACTOR_LOGIN_PATH__/bin:/usr/bin\nlogout\n"
    utf8 encode parse-login-paths
] unit-test

{ { } } [ "startup without PATH marker\n" utf8 encode parse-login-paths ] unit-test

:: with-passwd-fixture ( entry quot -- )
    H{ } clone :> cache
    entry effective-user-id cache set-at
    cache user-cache quot with-variable ; inline

: shell-fixture ( contents -- passwd )
    "login-shell" utf8 set-file-contents
    "login-shell" 0o755 set-file-permissions
    passwd new "login-shell" absolute-path >>shell ;

! A completed login shell supplies its PATH even when the inherited PATH differs.
{ { "/login-only" } } [
    [
        "PATH=/login-only; export PATH\nexec " test-shell append "\n" append
        test-script shell-fixture
        [ "/inherited-only" "PATH" [ standard-login-paths ] with-os-env ]
        with-passwd-fixture
    ] with-test-directory
] unit-test

! Startup can terminate before the shell reads our PATH command.
{ { "/inherited-only" } } [
    [
        "exit 0\n" test-script shell-fixture
        [ "/inherited-only" "PATH" [ standard-login-paths ] with-os-env ]
        with-passwd-fixture
    ] with-test-directory
] unit-test

! A process UID need not appear in the passwd database.
{ { "/inherited-only" } } [
    f [ "/inherited-only" "PATH" [ standard-login-paths ] with-os-env ]
    with-passwd-fixture
] unit-test

! Expected early stdin closure is the only I/O error eligible for PATH fallback.
{ t } [ [ EPIPE (throw-errno) ] [ login-shell-pipe-closed? ] recover ] unit-test
{ f } [ [ EIO (throw-errno) ] [ login-shell-pipe-closed? ] recover ] unit-test
{ f } [ "unrelated error" login-shell-pipe-closed? ] unit-test

! Force the real write/flush/disposal EPIPE path: the exact child has exited
! before the probe is sent, rather than relying on scheduler timing.
{ } [
    { "-c" "exit 0" } test-shell prefix binary (process-stream)
    wait-for-process 0 assert=
    [ write-login-command ] with-disposal
] unit-test

! A shell can emit a valid marked PATH and exit without reading stdin.
{ { "/fast-shell" } } [
    [
        "printf '__FACTOR_LOGIN_PATH__/fast-shell\\n'\nexit 0\n" test-script shell-fixture
        shell>> shell-login-paths
    ] with-test-directory
] unit-test

! An EPIPE on probe stdin is expected; unrelated IO errors and non-IO
! exceptions must propagate unchanged.
{ } [ [ EPIPE "probe stdin closed" libc-error ] ignore-closed-login-input ] unit-test
[ [ EACCES "permission denied" libc-error ] ignore-closed-login-input ]
[ dup libc-error? [ errno>> EACCES = ] [ drop f ] if ] must-fail-with
[ [ "unrelated login failure" throw ] ignore-closed-login-input ]
[ "unrelated login failure" = ] must-fail-with

! Closing the probe output must not suppress errors from reading stdout.
:: read-closed-login-output ( -- )
    { "-c" "exit 0" } test-shell prefix binary (process-stream)
    wait-for-process 0 assert= :> stream
    [
        stream write-login-command
        stream in>> dispose
        stream stream-read1 drop
    ] [ stream dispose ] finally ;

[ read-closed-login-output ] [ already-disposed? ] must-fail-with
