! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image bootstrap.image.download io
io.directories io.directories.hierarchy io.files.unique
io.launcher io.pathnames kernel namespaces sequences
mason.common mason.config webapps.mason.version.files ;
IN: webapps.mason.version.source

: clone-factor ( -- )
    { "git" "clone" "git://factorcode.org/git/factor.git" } try-process ;

: git-reset ( git-id -- )
    { "git" "reset" "--hard" } swap suffix try-process ;

: save-git-id ( git-id -- )
    "git-id" to-file ;

: delete-git-tree ( -- )
    ".git" delete-tree
    ".gitignore" delete-file ;

: download-images ( -- )
    image-names [ boot-image-name download-image ] each ;

: prepare-source ( git-id -- )
    "factor" [
        [ git-reset ] [ save-git-id ] bi
        delete-git-tree
        download-images
    ] with-directory ;

: (make-source-release) ( version -- path )
    [ { "zip" "-qr9" } ] dip source-release-name file-name
    [ suffix "factor" suffix try-process ] keep ;

: make-source-release ( version git-id -- path )
    "Creating source release..." print flush
    [
        current-temporary-directory get [
            clone-factor prepare-source (make-source-release)
            "Package created: " write absolute-path dup print
        ] with-directory
    ] with-unique-directory drop ;

: upload-source-release ( package version -- )
    "Uploading source release..." print flush
    [ package-username get package-host get ] dip
    remote-source-release-name
    upload-safely ;

: do-source-release ( version git-id -- )
    [ make-source-release ] [ drop upload-source-release ] 2bi ;
