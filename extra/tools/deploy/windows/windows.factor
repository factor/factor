! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files kernel namespaces sequences system
tools.deploy.backend tools.deploy.config assocs hashtables
prettyprint combinators windows.shell32 windows.user32 ;
IN: tools.deploy.windows

: copy-dlls ( bundle-name -- )
    {
        "resource:freetype6.dll"
        "resource:zlib1.dll"
        "resource:factor.dll"
    } swap copy-files-into ;

: create-exe-dir ( vocab bundle-name -- vm )
    dup copy-dlls
    dup "" copy-fonts
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
