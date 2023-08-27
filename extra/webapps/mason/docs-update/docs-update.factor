! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions help.html http.server.responses
io.directories io.files io.launcher io.pathnames kernel
mason.config memoize namespaces sequences threads
webapps.mason.utils ;
IN: webapps.mason.docs-update

: docs-path ( -- path )
    docs-directory get "docs.tar.gz" append-path ;

: update-docs ( -- )
    home [
        "newdocs" file-exists? [ "newdocs" delete-tree ] when

        "newdocs" make-directory
        "newdocs" [ { "tar" "xfz" } docs-path suffix try-process ] with-directory

        "docs" file-exists? [ "docs" "docs.old" move-file ] when
        "newdocs/docs" "docs" move-file

        "newdocs" delete-directory
        "docs.old" file-exists? [ "docs.old" delete-tree ] when

        \ load-index reset-memoized
    ] with-directory ;

: <docs-update-action> ( -- action )
    <action>
    [ validate-secret ] >>validate
    [
        [ update-docs ] "Documentation update" spawn drop
        "OK" <text-content>
    ] >>submit ;
