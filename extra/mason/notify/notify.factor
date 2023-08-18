! Copyright (C) 2009, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors continuations debugger http.client io
io.encodings.utf8 io.files kernel make mason.common mason.config
mason.email namespaces sequences ;
IN: mason.notify

: status-notify? ( -- ? )
    status-url get
    target-variant get not and ;

: status-params ( report arg message -- assoc )
    [
        short-host-name "host-name" ,,
        target-cpu get "target-cpu" ,,
        target-os get "target-os" ,,
        status-secret get "secret" ,,
        [ "report" ,, ]
        [ "arg" ,, ]
        [ "message" ,, ] tri*
    ] H{ } make ;

: status-notify ( report arg message -- )
    status-notify? [
        '[
            5 [
                _ _ _ status-params status-url get
                http-post 2drop
            ] retry
        ] [
            "STATUS NOTIFY FAILED:" print-timestamp
            error. flush
        ] recover
    ] [ 3drop ] if ;

: notify-heartbeat ( -- )
    f f "heartbeat" status-notify ;

: notify-idle ( -- )
    f f "idle" status-notify ;

: notify-begin-build ( git-id -- )
    [ "Starting build of GIT ID " prepend print-timestamp ]
    [ f swap "git-id" status-notify ]
    bi ;

: notify-make-vm ( -- )
    "Compiling VM" print-timestamp
    f f "make-vm" status-notify ;

: notify-boot ( -- )
    "Bootstrapping" print-timestamp
    f f "boot" status-notify ;

: notify-test ( -- )
    "Running tests" print-timestamp
    f f "test" status-notify ;

: notify-report ( status -- )
    [ name>> "Build finished with status: " prepend print-timestamp ]
    [
        [ "report" utf8 file-contents ] dip
        [ name>> "report" status-notify ] [ email-report ] 2bi
    ] bi ;

: notify-upload ( -- )
    f f "upload" status-notify ;

: notify-finish ( -- )
    f f "finish" status-notify ;

: notify-release ( archive-name -- )
    [ "Uploaded " prepend print-timestamp ]
    [ f swap "release" status-notify ] bi ;
