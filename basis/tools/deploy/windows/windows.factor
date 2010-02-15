! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.encodings.binary io.files io.pathnames io.directories
io.encodings.ascii kernel namespaces
sequences locals system splitting tools.deploy.backend
tools.deploy.config tools.deploy.config.editor assocs hashtables
prettyprint combinators windows.kernel32 windows.shell32 windows.user32
alien.c-types vocabs.metadata vocabs.loader ;
IN: tools.deploy.windows

CONSTANT: app-icon-resource-id "APPICON"

: copy-dll ( bundle-name -- )
    "resource:factor.dll" swap copy-file-into ;

:: copy-vm ( executable bundle-name extension -- vm )
    vm "." split1-last drop extension append
    bundle-name executable ".exe" append append-path
    [ copy-file ] keep ;

: create-exe-dir ( vocab bundle-name -- vm )
    dup copy-dll
    deploy-ui? get ".exe" ".com" ? copy-vm ;

:: (embed-ico) ( vm ico-bytes -- )
    vm 0 BeginUpdateResource :> hUpdate
    hUpdate [
        hUpdate RT_ICON app-icon-resource-id 0 ico-bytes dup byte-length
        UpdateResource drop
        hUpdate 0 EndUpdateResource drop
    ] when ;

: embed-ico ( vm vocab -- )
    dup vocab-windows-icon-path vocab-append-path dup exists?
    [ binary file-contents (embed-ico) ]
    [ 2drop ] if ;

M: winnt deploy*
    "resource:" [
        dup deploy-config [
            deploy-name get
            {
                [ create-exe-dir dup ]
                [ drop embed-ico ]
                [ image-name ]
                [ drop namespace make-deploy-image ]
                [ nip "" copy-resources ]
                [ nip open-in-explorer ]
            } 2cleave 
        ] bind
    ] with-directory ;
