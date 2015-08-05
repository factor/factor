! Copyright (C) 2008, 2011 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators
combinators.short-circuit continuations fry io.directories
io.launcher io.pathnames kernel macros make mason.config
mason.notify mason.platform mason.report namespaces quotations
sequences splitting system ;
IN: mason.child

! Make sure we call the build directory's factor.cmd
: nmake-cmd ( -- args )
    "./build-support/factor.cmd" absolute-path
    target-cpu get name>> "." split "-" join 2array ;

: gnu-make-cmd ( -- args )
    gnu-make
    target-os get name>> target-cpu get name>> (platform)
    2array ;

: mason-child-make-cmd ( -- args )
    {
        { [ target-os get windows = ] [ nmake-cmd ] }
        [ gnu-make-cmd ]
    } cond ;

: make-mason-child-vm ( -- )
    "factor" [
        <process>
            mason-child-make-cmd >>command
            "../compile-log" >>stdout
            +stdout+ >>stderr
            +new-group+ >>group
        try-process
    ] with-directory ;

! On windows, process launches relative to current process, ignoring
! current-directory variables. Must pass absolute-path of factor.com
: mason-child-vm ( -- string )
    target-os get windows = [
        "./factor.com" absolute-path
    ] [
        "./factor"
    ] if ;

: mason-child-boot-cmd ( -- cmd )
    [
        mason-child-vm ,
        "-i=" target-boot-image-name append ,
        "-no-user-init" ,
        boot-flags get %
    ] { } make ;

: bootstrap-mason-child ( -- )
    "factor" [
        <process>
            mason-child-boot-cmd >>command
            +closed+ >>stdin
            "../boot-log" >>stdout
            +stdout+ >>stderr
            1 hours >>timeout
            +new-group+ >>group
        try-process
    ] with-directory ;

: mason-child-test-cmd ( -- cmd ) mason-child-vm "-run=mason.test" 2array ;

: test-mason-child ( -- )
    "factor" [
        <process>
            mason-child-test-cmd >>command
            +closed+ >>stdin
            "../test-log" >>stdout
            +stdout+ >>stderr
            4 hours >>timeout
            +new-group+ >>group
        try-process
    ] with-directory ;

: recover-else ( try catch else -- )
    [ [ '[ @ f t ] ] [ '[ @ f ] ] bi* recover ] dip '[ drop @ ] when ; inline

MACRO: recover-cond ( alist -- quot )
    dup { [ length 1 = ] [ first callable? ] } 1&&
    [ first ] [
        [ first first2 ] [ rest ] bi
        '[ _ _ [ _ recover-cond ] recover-else ]
    ] if ;

: build-child ( -- status )
    {
        { [ notify-make-vm make-mason-child-vm ] [ compile-failed ] }
        { [ notify-boot bootstrap-mason-child ] [ boot-failed ] }
        { [ notify-test test-mason-child ] [ test-failed ] }
        [ success ]
    } recover-cond ;
