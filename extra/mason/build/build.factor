! Copyright (C) 2008, 2011 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel calendar io.directories io.encodings.utf8
io.files io.launcher io.pathnames namespaces prettyprint
combinators sequences mason.child mason.cleanup mason.common mason.config
mason.docs mason.release mason.report mason.email mason.git
mason.notify mason.platform mason.updates ;
QUALIFIED: continuations
IN: mason.build

: create-build-dir ( -- )
    now datestamp stamp set
    build-dir make-directory ;

: enter-build-dir  ( -- )
    "Building in directory " build-dir append print-timestamp
    build-dir set-current-directory ;

: clone-source ( -- )
    "Cloning GIT repository" print-timestamp
    "git" "clone" builds-dir get "factor" append-path 3array
    short-running-process ;

: copy-image ( -- )
    builds-dir get boot-image-name append-path
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

: build ( -- )
    create-build-dir
    enter-build-dir
    [
        begin-build
        build-child
        [ notify-report ] [
            status-clean eq?
            [ notify-upload upload-docs release ] when
        ] bi
        notify-finish
        finish-build
    ] [ cleanup ] [ ] continuations:cleanup
    notify-idle ;

MAIN: build
