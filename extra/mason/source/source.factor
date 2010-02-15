! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image bootstrap.image.download io io.directories
io.directories.hierarchy io.files.unique io.launcher
io.pathnames kernel sequences namespaces mason.common mason.config ;
IN: mason.source

: clone-factor ( -- )
    { "git" "clone" } home "factor" append-path suffix try-process ;

: save-git-id ( -- )
    git-id "git-id" to-file ;

: delete-git-tree ( -- )
    ".git" delete-tree ;

: download-images ( -- )
    images [ download-image ] each ;

: prepare-source ( -- )
    "factor" [ save-git-id delete-git-tree download-images ] with-directory ;

: package-name ( version -- string )
    "factor-src-" ".zip" surround ;

: make-tarball ( version -- path )
    [ { "zip" "-qr9" } ] dip package-name
    [ suffix "factor" suffix try-process ] keep ;

: make-package ( version -- path )
    unique-directory
    [
        clone-factor prepare-source make-tarball
        "Package created: " write absolute-path dup print
    ] with-directory ;

: remote-location ( version -- dest )
    [ upload-directory get "/releases/" ] dip 3append ;

: remote-archive-name ( version -- dest )
    [ remote-location ] [ package-name ] bi "/" glue ;

: upload-package ( package version -- )
    [ upload-username get upload-host get ] dip
    remote-archive-name
    upload-safely ;

: release-source-package ( version -- )
    [ make-package ] [ upload-package ] bi ;
