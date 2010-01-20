! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays continuations io.directories
io.directories.hierarchy io.files io.launcher kernel
mason.common mason.config mason.platform namespaces ;
IN: mason.cleanup

: compress ( filename -- )
    dup exists? [ "bzip2" swap 2array short-running-process ] [ drop ] if ;

: compress-image ( -- )
    boot-image-name compress ;

: compress-test-log ( -- )
    "test-log" compress ;

: cleanup ( -- )
    builder-debug get [
        build-dir [
            compress-image
            compress-test-log
            "factor" really-delete-tree
        ] with-directory
    ] unless ;
