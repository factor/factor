! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry http.client io io.encodings.utf8 io.files
kernel mason.common mason.config mason.email mason.twitter
namespaces prettyprint sequences debugger continuations ;
IN: mason.notify

: status-notify ( report arg message -- )
    '[
        5 [
            [
                short-host-name "host-name" set
                target-cpu get "target-cpu" set
                target-os get "target-os" set
                status-secret get "secret" set
                _ "report" set
                _ "arg" set
                _ "message" set
            ] H{ } make-assoc
            status-url get http-post 2drop
        ] retry
    ] [
        "STATUS NOTIFY FAILED:" print
        error. flush
    ] recover ;

: notify-heartbeat ( -- )
    f f "heartbeat" status-notify ;

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

: notify-release ( archive-name -- )
    [ "Uploaded " prepend [ print flush ] [ mason-tweet ] bi ]
    [ f swap "release" status-notify ]
    bi ;
