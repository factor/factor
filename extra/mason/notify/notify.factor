! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays accessors io io.sockets io.encodings.utf8 io.files
io.launcher kernel make mason.config mason.common mason.email
mason.twitter namespaces sequences ;
IN: mason.notify

: status-notify ( input-file args -- )
    status-host get [
        [
            "ssh" , status-host get , "-l" , status-username get ,
            "./mason-notify" ,
            host-name ,
            target-cpu get ,
            target-os get ,
        ] { } make prepend
        <process>
            swap >>command
            swap [ +closed+ ] unless* >>stdin
        try-output-process
    ] [ 2drop ] if ;

: notify-begin-build ( git-id -- )
    [ "Starting build of GIT ID " write print flush ]
    [ f swap "git-id" swap 2array status-notify ]
    bi ;

: notify-make-vm ( -- )
    "Compiling VM" print flush
    f { "make-vm" } status-notify ;

: notify-boot ( -- )
    "Bootstrapping" print flush
    f { "boot" } status-notify ;

: notify-test ( -- )
    "Running tests" print flush
    f { "test" } status-notify ;

: notify-report ( status -- )
    [ "Build finished with status: " write print flush ]
    [
        [ "report" utf8 file-contents ] dip email-report
        "report" { "report" } status-notify
    ] bi ;

: notify-release ( archive-name -- )
    "Uploaded " prepend [ print flush ] [ mason-tweet ] bi ;