! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces continuations debugger sequences fry
io.files io.launcher mason.common mason.platform
mason.config ;
IN: mason.release.tidy

: common-files ( -- seq )
    {
        "boot.x86.32.image"
        "boot.x86.64.image"
        "boot.macosx-ppc.image"
        "boot.linux-ppc.image"
        "vm"
        "temp"
        "logs"
        ".git"
        ".gitignore"
        "Makefile"
        "unmaintained"
        "unfinished"
        "build-support"
    } ;

: remove-common-files ( -- )
    common-files [ delete-tree ] each ;

: remove-factor-app ( -- )
    target-os get "macosx" =
    [ [ "Factor.app" delete-tree ] unless ;

: tidy ( -- )
    "factor" [ remove-factor-app remove-common-files ] with-directory ;
