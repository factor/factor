! Copyright (C) 2008, 2011 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators.short-circuit
continuations io.directories io.launcher io.pathnames kernel
layouts make mason.config mason.notify mason.platform
mason.report namespaces quotations sequences system ;
IN: mason.child

: gnu-make-cmd ( -- args )
    gnu-make
    target-os get name>> target-cpu get name>> (platform)
    2array ;

HOOK: compile-factor-command os ( -- array )
M: unix compile-factor-command ( -- array )
    gnu-make-cmd ;

! Windows has separate 32/64 bit shells, so assuming the cell bits here is fine
! because it won't find the right toolchain otherwise.
M: windows compile-factor-command ( -- array )
    { "nmake" "/f" "NMakefile" } cell-bits 64 = "x86-64-vista" "x86-32-vista" ? suffix ;

HOOK: factor-path os ( -- path )
M: unix factor-path "./factor" ;
M: windows factor-path "./factor.com" ;

: make-mason-child-vm ( -- )
    "factor" [
        <process>
            compile-factor-command >>command
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
            2 hours >>timeout
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
