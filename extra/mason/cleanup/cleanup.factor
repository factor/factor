! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays continuations io.directories
io.directories.hierarchy io.files io.launcher kernel
mason.common mason.config mason.platform namespaces ;
IN: mason.cleanup

: compress-image ( -- )
    "bzip2" boot-image-name 2array try-process ;

: compress-test-log ( -- )
    "test-log" exists? [
        { "bzip2" "test-log" } try-process
    ] when ;

: cleanup ( -- )
    builder-debug get [
        build-dir [
            compress-image
            compress-test-log
            "factor" really-delete-tree
        ] with-directory
    ] unless ;
