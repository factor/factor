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
        "docs.new" ?delete-tree

        "docs.new" make-directory
        "docs.new" [ { "tar" "xfz" } docs-path suffix try-process ] with-directory

        "docs" "docs.old" ?move-file
        "docs.new/docs" "docs" move-file

        "docs.new" delete-directory
        "docs.old" ?delete-tree

        \ load-index reset-memoized
    ] with-directory ;

: <docs-update-action> ( -- action )
    <action>
    [ validate-secret ] >>validate
    [
        [ update-docs ] "Documentation update" spawn drop
        "OK" <text-content>
    ] >>submit ;
