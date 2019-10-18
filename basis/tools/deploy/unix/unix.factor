! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: io io.backend io.directories io.files.info.unix kernel
namespaces sequences system tools.deploy.backend
tools.deploy.config tools.deploy.config.editor ;
QUALIFIED: webbrowser
IN: tools.deploy.unix

: create-app-dir ( vocab bundle-name -- vm )
    copy-vm
    dup 0o755 set-file-permissions ;

: bundle-name ( -- str )
    deploy-name get ;

M: unix deploy* ( vocab -- )
    "resource:" [
        dup deploy-config [
            [ bundle-name create-app-dir ] keep
            [ deployed-image-name ] keep
            namespace make-deploy-image-executable
            bundle-name "" [ copy-resources ] [ copy-libraries ] 3bi
            bundle-name normalize-path "Binary deployed to " "." surround print
            bundle-name webbrowser:open-file
        ] with-variables
    ] with-directory ;
