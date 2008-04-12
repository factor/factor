! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files kernel namespaces sequences system
tools.deploy.backend tools.deploy.config assocs hashtables
prettyprint windows.shell32 windows.user32 ;
IN: tools.deploy.windows

: copy-dlls ( bundle-name -- )
    { "freetype6.dll" "zlib1.dll" "factor.dll" }
    [ resource-path ] map
    swap copy-files-into ;

: create-exe-dir ( vocab bundle-name -- vm )
    dup copy-dlls
    dup "" copy-fonts
    ".exe" copy-vm ;

: image-name ( vocab bundle-name -- str )
    prepend-path ".image" append ;

M: winnt deploy*
    "." resource-path [
        dup deploy-config [
            [ deploy-name get create-exe-dir ] keep
            [ deploy-name get image-name ] keep
            [ namespace make-deploy-image ] keep
            (normalize-path) open-in-explorer
        ] bind
    ] with-directory ;
