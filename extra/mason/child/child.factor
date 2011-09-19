! Copyright (C) 2008, 2011 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators.short-circuit fry
continuations debugger io.directories io.files io.launcher
io.pathnames io.encodings.ascii kernel make mason.common
mason.config mason.platform mason.report mason.notify namespaces
sequences quotations macros system combinators splitting ;
IN: mason.child

: nmake-cmd ( -- args )
    { "nmake" "/f" "nmakefile" }
    target-cpu get name>> "." split "-" join suffix ;

: gnu-make-cmd ( -- args )
    gnu-make
    target-os get name>> target-cpu get name>> (platform)
    2array ;

: make-cmd ( -- args )
    {
        { [ target-os get windows = ] [ nmake-cmd ] }
        [ gnu-make-cmd ]
    } cond ;

: make-vm ( -- )
    "factor" [
        <process>
            make-cmd >>command
            "../compile-log" >>stdout
            +stdout+ >>stderr
        try-process
    ] with-directory ;

: factor-vm ( -- string )
    target-os get windows = "./factor.com" "./factor" ? ;

: boot-cmd ( -- cmd )
    [
        factor-vm ,
        "-i=" boot-image-name append ,
        "-no-user-init" ,
        boot-flags get %
    ] { } make ;

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
    [ first ] [
        [ first first2 ] [ rest ] bi
        '[ _ _ [ _ recover-cond ] recover-else ]
    ] if ;

: build-child ( -- status )
    {
        { [ notify-make-vm make-vm ] [ compile-failed ] }
        { [ notify-boot boot ] [ boot-failed ] }
        { [ notify-test test ] [ test-failed ] }
        [ success ]
    } recover-cond ;
