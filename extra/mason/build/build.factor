! Copyright (C) 2008, 2011 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays calendar combinators continuations io.backend
io.directories io.pathnames kernel mason.child mason.cleanup
mason.common mason.config mason.docs mason.git mason.notify
mason.platform mason.release mason.updates namespaces sequences
;
IN: mason.build

: create-build-dir ( -- )
    now datestamp stamp set
    build-dir make-directory ;

: enter-build-dir  ( -- )
    "Building in directory " build-dir append print-timestamp
    build-dir set-current-directory ;

: clone-source ( -- )
    "Cloning GIT repository" print-timestamp
    "git" "clone" builds-dir get "factor" append-path absolute-path 3array
    short-running-process ;

: copy-image ( -- )
    builds-dir get target-boot-image-name append-path
    [ "." copy-file-into ] [ "factor" copy-file-into ] bi ;

: save-git-id ( -- )
    "factor" [ git-id ] with-directory {
        [ "git-id" to-file ]
        [ "factor/git-id" to-file ]
        [ current-git-id set ]
        [ notify-begin-build ]
    } cleave ;

: begin-build ( -- )
    clone-source
    copy-image
    save-git-id ;

: do-build ( -- )
    create-build-dir
    enter-build-dir
    [
        begin-build
        build-child
        [ notify-report ] [
            status-clean eq?
            [ notify-benchmarks notify-upload upload-docs release ] when
        ] bi
        notify-finish
        finish-build
    ] [ cleanup-build ] finally
    notify-idle ;

MAIN: do-build
