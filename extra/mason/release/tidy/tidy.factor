! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image continuations debugger fry
io.directories io.directories.hierarchy io.files io.launcher
kernel mason.common namespaces sequences ;
FROM: mason.config => target-os ;
IN: mason.release.tidy

: common-files ( -- seq )
    images [ boot-image-name ] map
    {
        "vm"
        "temp"
        "logs"
        ".git"
        ".gitignore"
        "Makefile"
        "unmaintained"
        "unfinished"
        "build-support"
    }
    append ;

: remove-common-files ( -- )
    common-files [ delete-tree ] each ;

: remove-factor-app ( -- )
    target-os get "macosx" =
    [ "Factor.app" delete-tree ] unless ;

: tidy ( -- )
    "factor" [ remove-factor-app remove-common-files ] with-directory ;
