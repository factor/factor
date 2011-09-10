! Copyright (C) 2009, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry http.client io io.encodings.utf8 io.files
kernel mason.common mason.config mason.email mason.twitter
namespaces prettyprint sequences debugger continuations ;
IN: mason.notify

: status-notify? ( -- ? )
    status-url get
    target-variant get not and ;

: status-params ( report arg message -- assoc )
    [
        short-host-name "host-name" set
        target-cpu get "target-cpu" set
        target-os get "target-os" set
        status-secret get "secret" set
        [ "report" set ]
        [ "arg" set ]
        [ "message" set ] tri*
    ] H{ } make-assoc ;

: status-notify ( report arg message -- )
    status-notify? [
        '[
            5 [
                _ _ _ status-params status-url get
                http-post 2drop
            ] retry
        ] [
            "STATUS NOTIFY FAILED:" print
            error. flush
        ] recover
    ] [ 3drop ] if ;

: notify-heartbeat ( -- )
    f f "heartbeat" status-notify ;

: notify-idle ( -- )
    f f "idle" status-notify ;

: notify-begin-build ( git-id -- )
    [ "Starting build of GIT ID " write print flush ]
    [ f swap "git-id" status-notify ]
    bi ;

: notify-make-vm ( -- )
    "Compiling VM" print flush
    f f "make-vm" status-notify ;

: notify-boot ( -- )
    "Bootstrapping" print flush
    f f "boot" status-notify ;

: notify-test ( -- )
    "Running tests" print flush
    f f "test" status-notify ;

: notify-report ( status -- )
    [ "Build finished with status: " write . flush ]
    [
        [ "report" utf8 file-contents ] dip
        [ name>> "report" status-notify ] [ email-report ] 2bi
    ] bi ;

: notify-upload ( -- )
    f f "upload" status-notify ;

: notify-finish ( -- )
    f f "finish" status-notify ;

: notify-release ( archive-name -- )
    [ "Uploaded " prepend [ print flush ] [ mason-tweet ] bi ]
    [ f swap "release" status-notify ]
    bi ;
