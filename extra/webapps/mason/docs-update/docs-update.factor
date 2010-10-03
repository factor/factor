! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations namespaces sequences
furnace.actions help.html http.server.responses io.directories
io.directories.hierarchy io.launcher io.files io.pathnames
kernel memoize threads webapps.mason.utils ;
IN: webapps.mason.docs-update

SYMBOL: docs-path

: update-docs ( -- )
    home [
        "newdocs" make-directory
        "newdocs" [ { "tar" "xfz" } docs-path get suffix try-process ] with-directory

        "docs" exists? [ "docs" "docs.old" move-file ] when
        "newdocs/docs" "docs" move-file

        "newdocs" delete-directory
        "docs.old" exists? [ "docs.old" delete-tree ] when

        \ load-index reset-memoized
    ] with-directory ;

: <docs-update-action> ( -- action )
    <action>
    [ validate-secret ] >>validate
    [
        [ update-docs ] "Documentation update" spawn drop
        "OK" "text/plain" <content>
    ] >>submit ;
