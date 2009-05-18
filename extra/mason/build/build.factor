! Copyright (C) 2008, 2009 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel calendar io.directories io.encodings.utf8
io.files io.launcher namespaces prettyprint mason.child mason.cleanup
mason.common mason.help mason.release mason.report mason.email
mason.notify ;
IN: mason.build

QUALIFIED: continuations

: create-build-dir ( -- )
    now datestamp stamp set
    build-dir make-directory ;

: enter-build-dir  ( -- ) build-dir set-current-directory ;

: clone-builds-factor ( -- )
    "git" "clone" builds/factor 3array short-running-process ;

: begin-build ( -- )
    "factor" [ git-id ] with-directory
    [ "git-id" to-file ]
    [ current-git-id set ]
    [ notify-begin-build ]
    tri ;

: build ( -- )
    create-build-dir
    enter-build-dir
    clone-builds-factor
    [
        begin-build
        build-child
        [ notify-report ]
        [ status-clean eq? [ upload-help release ] when ] bi
    ] [ cleanup ] [ ] continuations:cleanup ;

MAIN: build
