! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: bootstrap.image bootstrap.image.download io
io.directories io.files.temp io.files.unique io.launcher
io.pathnames kernel namespaces sequences mason.common
mason.config webapps.mason.version.files ;
IN: webapps.mason.version.source

: clone-factor ( -- )
    { "git" "clone" "https://github.com/factor/factor.git" } try-process ;

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

: zip-source ( version -- path )
    [ { "zip" "-qr9" } ] dip source-release-name file-name
    [ suffix "factor" suffix try-process ] keep ;

: make-source-release ( version git-id -- path )
    "Creating source release..." print flush
    clone-factor prepare-source zip-source
    "Package created: " write absolute-path dup print ;

: upload-source-release ( path version -- )
    "Uploading source release..." print flush
    [ package-username get package-host get ] dip
    remote-source-release-name
    upload-safely ;

: do-source-release ( version git-id -- )
    [
        [
            [ make-source-release ]
            [ drop upload-source-release ] 2bi
        ] cleanup-unique-directory
    ] with-temp-directory ;
