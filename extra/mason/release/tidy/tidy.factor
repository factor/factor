! Copyright (C) 2008, 2011 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: bootstrap.image io.directories io.files kernel namespaces
sequences system ;
FROM: mason.config => target-os ;
IN: mason.release.tidy

CONSTANT: cleanup-list {
    "vm"
    "temp"
    "logs"
    ".git"
    ".gitattributes"
    ".github"
    ".gitignore"
    ".mailmap"
    "build"
    "build.zig"
    "build.zig.zon"
    "GNUmakefile"
    "Nmakefile"
    "unmaintained"
    "build.cmd"
    "build.sh"
    "build-support"
    "images"
    "factor.dll.exp"
    "factor.dll.lib"
    "factor.exp"
    "factor.lib"
    "factor.image.fresh"
    "libfactor-ffi-test.exp"
    "libfactor-ffi-test.lib"
}

: useless-files ( -- seq )
    cleanup-list image-names [ boot-image-name ] map append
    target-os get macos? [ "Factor.app" suffix ] unless ;

: tidy ( -- )
    "factor" [
        useless-files
        [ file-exists? ] filter
        [ delete-tree ] each
    ] with-directory ;
