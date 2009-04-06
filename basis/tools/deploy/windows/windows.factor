! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files io.pathnames io.directories io.encodings.ascii kernel namespaces
sequences locals system splitting tools.deploy.backend
tools.deploy.config tools.deploy.config.editor assocs hashtables
prettyprint combinators windows.shell32 windows.user32 ;
IN: tools.deploy.windows

: copy-dll ( bundle-name -- )
    "resource:factor.dll" swap copy-file-into ;

:: copy-vm ( executable bundle-name extension -- vm )
    vm "." split1-last drop extension append
    bundle-name executable ".exe" append append-path
    [ copy-file ] keep ;

: create-exe-dir ( vocab bundle-name -- vm )
    dup copy-dll
    deploy-ui? get [
        [ "" copy-theme ] [ ".exe" copy-vm ] bi
    ] [ ".com" copy-vm ] if ;

M: winnt deploy*
    "resource:" [
        dup deploy-config [
            deploy-name get
            [
                [ create-exe-dir ]
                [ image-name ]
                [ drop ]
                2tri namespace make-deploy-image
            ]
            [ nip open-in-explorer ] 2bi
        ] bind
    ] with-directory ;
