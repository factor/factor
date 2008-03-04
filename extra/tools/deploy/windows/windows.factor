! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files kernel namespaces sequences system
tools.deploy.backend tools.deploy.config assocs hashtables
prettyprint windows.shell32 windows.user32 ;
IN: tools.deploy.windows

: copy-vm ( executable bundle-name -- vm )
    swap path+ ".exe" append
    vm over copy-file ;

: copy-fonts ( bundle-name -- )
    "fonts/" resource-path swap copy-tree-into ;

: copy-dlls ( bundle-name -- )
    { "freetype6.dll" "zlib1.dll" "factor.dll" }
    [ resource-path ] map
    swap copy-files-into ;

: create-exe-dir ( vocab bundle-name -- vm )
    dup copy-dlls
    dup copy-fonts
    copy-vm ;

: image-name ( vocab bundle-name -- str )
    swap path+ ".image" append ;

TUPLE: windows-deploy-implementation ;

T{ windows-deploy-implementation } deploy-implementation set-global

M: windows-deploy-implementation deploy*
    "." resource-path [
        dup deploy-config [
            [ deploy-name get create-exe-dir ] keep
            [ deploy-name get image-name ] keep
            [ namespace make-deploy-image ] keep
            open-in-explorer
        ] bind
    ] with-directory ;
