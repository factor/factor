! Copyright (C) 2007, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators io.backend io.directories io.encodings.binary
io.files io.pathnames kernel locals namespaces sequences splitting
system tools.deploy.backend tools.deploy.config
tools.deploy.config.editor tools.deploy.windows.ico vocabs.loader
webbrowser ;
IN: tools.deploy.windows

CONSTANT: app-icon-resource-id "APPICON"

:: copy-vm ( executable bundle-name extension -- vm-path )
    vm-path "." split1-last drop extension append
    bundle-name executable ".exe" append append-path
    [ copy-file ] keep normalize-path ;

: create-exe-dir ( vocab bundle-name -- vm-path )
    deploy-console? get ".com" ".exe" ? copy-vm ;

: vocab-windows-icon-path ( vocab -- string )
    vocab-dir "icon.ico" append-path ;

: embed-ico ( vm-path vocab -- )
    dup vocab-windows-icon-path vocab-append-path dup file-exists?
    [ binary file-contents app-icon-resource-id embed-icon-resource ]
    [ 2drop ] if ;

M: windows deploy*
    deploy-name get
    {
        [ create-exe-dir dup ]
        [ drop embed-ico ]
        [ drop deployed-image-name ]
        [ drop namespace make-deploy-image-executable ]
        [ nip "" [ copy-resources ] [ copy-libraries ] 3bi ]
        [ nip maybe-open-deploy-directory ]
    } 2cleave ;

M: windows deploy-path
    deploy-directory get [
        dup deploy-config [
            deploy-name get
            swap ".exe" append append-path
            normalize-path
        ] with-variables
    ] with-directory ;
