! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files kernel namespaces sequences system
tools.deploy tools.deploy.config assocs hashtables prettyprint ;
IN: tools.deploy.windows

: copy-vm ( executable bundle-name -- vm )
    swap path+ ".exe" append vm swap [ copy-file ] keep ;

: copy-fonts ( bundle-name -- )
    "fonts/" resource-path
    swap "fonts/" path+ copy-directory ;

: copy-dlls ( bundle-name -- )
    {
        "freetype6.dll"
        "zlib1.dll"
        "factor-nt.dll"
    } [
        dup resource-path -rot path+ copy-file
    ] curry* each ;

: create-exe-dir ( vocab bundle-name -- vm )
    dup copy-dlls
    dup copy-fonts
    copy-vm ;

: image-name ( vocab bundle-name -- str )
    swap path+ ".image" append ;

TUPLE: windows-deploy-implementation ;

T{ windows-deploy-implementation } deploy-implementation set-global

M: windows-deploy-implementation deploy
    "." resource-path cd
    dup deploy-config [
        [ deploy-name get create-exe-dir ] keep
        [ deploy-name get image-name ] keep
        namespace
    ] bind deploy* ;
