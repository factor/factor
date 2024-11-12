! Copyright (C) 2008 James Cash
! See https://factorcode.org/license.txt for BSD license.
USING: combinators io.backend io.directories io.files.info.unix
io.pathnames kernel namespaces sequences system
tools.deploy.backend tools.deploy.config
tools.deploy.config.editor ;
IN: tools.deploy.unix

CONSTANT: extension ".out"

: create-app-dir ( vocab bundle-name -- vm-path )
    [ os macos? [ extension append ] unless ] dip
    copy-vm dup 0o755 set-file-permissions ;

M: unix deploy*
    deploy-name get
    {
        [ create-app-dir ]
        [ drop deployed-image-name ]
        [ drop namespace make-deploy-image-executable ]
        [ nip "" [ copy-resources ] [ copy-libraries ] 3bi ]
        [ nip maybe-open-deploy-directory ]
    } 2cleave ;

M: unix deploy-path
    deploy-directory get [
        dup deploy-config [
            deploy-name get
            swap extension append append-path
            normalize-path
        ] with-variables
    ] with-directory ;
