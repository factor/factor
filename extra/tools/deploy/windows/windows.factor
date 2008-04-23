! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files kernel namespaces sequences system
tools.deploy.backend tools.deploy.config assocs hashtables
prettyprint windows.shell32 windows.user32 ;
IN: tools.deploy.windows

: copy-dlls ( bundle-name -- )
    { "resource:freetype6.dll" "resource:zlib1.dll" "resource:factor.dll" }
    swap copy-files-into ;

: create-exe-dir ( vocab bundle-name -- vm )
    dup copy-dlls
    dup "" copy-fonts
    ".exe" copy-vm ;

M: winnt deploy*
    "." resource-path [
        dup deploy-config [
            [ deploy-name get create-exe-dir ] keep
            [ deploy-name get image-name ] keep
            [ namespace make-deploy-image ] keep
            open-in-explorer
        ] bind
    ] with-directory ;
