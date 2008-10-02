! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files kernel namespaces sequences system
tools.deploy.backend tools.deploy.config assocs hashtables
prettyprint combinators windows.shell32 windows.user32 ;
IN: tools.deploy.windows

: copy-dll ( bundle-name -- )
    "resource:factor.dll" swap copy-file-into ;

: copy-freetype ( bundle-name -- )
    deploy-ui? get [
        {
            "resource:freetype6.dll"
            "resource:zlib1.dll"
        } swap copy-files-into
    ] when ;

: create-exe-dir ( vocab bundle-name -- vm )
    deploy-ui? get [
        dup copy-dll
        dup copy-freetype
        dup "" copy-fonts
    ] when
    ".exe" copy-vm ;

M: winnt deploy*
    "resource:" [
        deploy-name over deploy-config at
        [
            {
                [ create-exe-dir ]
                [ image-name ]
                [ drop ]
                [ drop deploy-config ]
            } 2cleave make-deploy-image
        ]
        [ nip open-in-explorer ] 2bi
    ] with-directory ;
