! Copyright (C) 2008, 2009 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators.short-circuit fry
continuations debugger io.directories io.files io.launcher
io.pathnames io.encodings.ascii kernel make mason.common mason.config
mason.platform mason.report mason.notify namespaces sequences
quotations macros ;
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

: recover-else ( try catch else -- )
    [ [ '[ @ f t ] ] [ '[ @ f ] ] bi* recover ] dip '[ drop @ ] when ; inline

MACRO: recover-cond ( alist -- )
    dup { [ length 1 = ] [ first callable? ] } 1&&
    [ first ] [ [ first first2 ] [ rest ] bi '[ _ _ [ _ recover-cond ] recover-else ] ] if ;

: build-child ( -- status )
    copy-image
    {
        { [ notify-make-vm make-vm ] [ compile-failed ] }
        { [ notify-boot boot ] [ boot-failed ] }
        { [ notify-test test ] [ test-failed ] }
        [ success ]
    } recover-cond ;