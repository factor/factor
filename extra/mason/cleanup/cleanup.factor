! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces arrays continuations io.files io.launcher
mason.common mason.platform mason.config ;
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
            "factor" delete-tree
        ] with-directory
    ] unless ;
