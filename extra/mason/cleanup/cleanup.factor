! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays io.directories io.files kernel mason.common
mason.config mason.platform namespaces ;
IN: mason.cleanup

: compress ( filename -- )
    dup file-exists? [
        "bzip2" swap 2array short-running-process
    ] [ drop ] if ;

: compress-image ( -- )
    target-boot-image-name compress ;

: compress-test-log ( -- )
    "test-log" compress ;

: cleanup-build ( -- )
    builder-debug get [
        build-dir [
            compress-image
            compress-test-log
            "factor" delete-tree
        ] with-directory
    ] unless ;
