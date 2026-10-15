! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii continuations destructors environment io io.encodings.binary
io.encodings.string io.encodings.utf8 io.files io.launcher
io.launcher.private io.pathnames io.standard-paths io.standard-paths.private io.streams.duplex kernel libc locals math
sequences splitting system unix.users ;
IN: io.standard-paths.unix

M: unix application-directories "PATH" os-env [ ":" split ] [ { } ] if* ;

M: unix find-in-path*
    1array application-directories [ executable-file? ] find-path-entry ;

! Login startup files may print terminal escapes, warnings, or fortunes.
! Read only the marked PATH line emitted after startup has completed.
: parse-login-paths ( seq -- strings )
    utf8 decode "__FACTOR_LOGIN_PATH__" split1 nip
    [ "\n" split1 drop ":" split ] [ { } ] if* ;

! Only a shell that closes stdin before reading our command permits PATH fallback.
! Preserve unrelated I/O failures instead of treating them as empty shell output.
: login-shell-pipe-closed? ( error -- ? )
    dup libc-error? [ errno>> EPIPE = ] [ drop f ] if ;

: ignore-closed-login-input ( quot: ( -- ) -- )
    [ login-shell-pipe-closed? ] ignore-error ; inline

:: write-login-command ( stream -- )
    [
        [
            "echo \"__FACTOR_LOGIN_PATH__$PATH\"\nexit\n" utf8 encode
            stream stream-write stream stream-flush
        ] ignore-closed-login-input
    ] [
        ! Close stdin now, including after a failed flush. This also prevents
        ! duplex disposal from retrying a buffered write to an exited shell.
        [ stream out>> dispose ] ignore-closed-login-input
    ] finally ;

:: shell-login-paths ( shell -- strings )
    ! csh requires -l to be its only option. Supply commands on stdin
    ! so every login shell can initialize its normal startup files.
    { "-l" } shell prefix
    binary (process-stream) :> ( stream process )
    [
        stream [| stream |
            stream write-login-command
            stream stream-contents* parse-login-paths
        ] with-disposal
    ] [ process wait-for-process drop ] finally ;

: standard-login-paths ( -- strings )
    effective-user-id user-passwd
    [ shell>> shell-login-paths dup empty? [ drop application-directories ] when ]
    [ application-directories ] if* ;

M: unix find-in-standard-login-path*
    1array standard-login-paths [ executable-file? ] find-path-entry ;
