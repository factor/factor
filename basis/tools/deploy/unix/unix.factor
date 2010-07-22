! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: io io.backend io.directories io.files io.files.info.unix
io.pathnames kernel namespaces sequences system
tools.deploy.backend tools.deploy.config
tools.deploy.config.editor vocabs.loader vocabs.metadata ;
IN: tools.deploy.unix

: used-ico ( vocab -- ico )
    dup vocab-windows-icon-path vocab-append-path
    [ exists? ] keep "vocab:ui/backend/gtk/icon.ico" ? ;

: copy-ico ( vocab bundle-name -- )
    [ used-ico ]
    [ "ui/backend/gtk/icon.ico" append-path ] bi*
    copy-file ;

: create-app-dir ( vocab bundle-name -- vm )
    [ copy-vm ] [ copy-ico ] 2bi
    dup OCT: 755 set-file-permissions ;

: bundle-name ( -- str )
    deploy-name get ;

M: unix deploy* ( vocab -- )
    "resource:" [
        dup deploy-config [
            [ bundle-name create-app-dir ] keep
            [ bundle-name image-name ] keep
            namespace make-deploy-image
            bundle-name "" [ copy-resources ] [ copy-libraries ] 3bi
            bundle-name normalize-path "Binary deployed to " "." surround print
        ] bind
    ] with-directory ;
