! Copyright (C) 2008, 2009 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators.short-circuit
continuations debugger io.directories io.files io.launcher
io.pathnames io.encodings.ascii kernel make mason.common mason.config
mason.platform mason.report mason.email namespaces sequences ;
IN: mason.child

: make-cmd ( -- args )
    gnu-make platform 2array ;

: make-vm ( -- )
    "factor" [
        <process>
            make-cmd >>command
            "../compile-log" >>stdout
            +stdout+ >>stderr
        try-process
    ] with-directory ;

: builds-factor-image ( -- img )
    builds/factor boot-image-name append-path ;

: copy-image ( -- )
    builds-factor-image "." copy-file-into
    builds-factor-image "factor" copy-file-into ;

: factor-vm ( -- string )
    target-os get "winnt" = "./factor.com" "./factor" ? ;

: boot-cmd ( -- cmd )
    factor-vm
    "-i=" boot-image-name append
    "-no-user-init"
    3array ;

: boot ( -- )
    "factor" [
        <process>
            boot-cmd >>command
            +closed+ >>stdin
            "../boot-log" >>stdout
            +stdout+ >>stderr
            1 hours >>timeout
        try-process
    ] with-directory ;

: test-cmd ( -- cmd ) factor-vm "-run=mason.test" 2array ;

: test ( -- )
    "factor" [
        <process>
            test-cmd >>command
            +closed+ >>stdin
            "../test-log" >>stdout
            +stdout+ >>stderr
            4 hours >>timeout
        try-process
    ] with-directory ;

: return-with ( obj -- * ) return-continuation get continue-with ;

: build-clean? ( -- ? )
    {
        [ load-everything-vocabs-file eval-file empty? ]
        [ test-all-vocabs-file eval-file empty? ]
        [ help-lint-vocabs-file eval-file empty? ]
        [ compiler-errors-file eval-file empty? ]
        [ benchmark-error-vocabs-file eval-file empty? ]
    } 0&& ;

: build-child ( -- )
    [
        return-continuation set

        copy-image

        [ make-vm ] [ compile-failed-report status-error return-with ] recover
        [ boot ] [ boot-failed-report status-error return-with ] recover
        [ test ] [ test-failed-report status-error return-with ] recover

        successful-report

        build-clean? status-clean status-dirty ? return-with
    ] callcc1
    status set
    email-report ;