! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: io io.backend io.directories io.files io.files.info.unix
io.pathnames kernel namespaces sequences system
tools.deploy.backend tools.deploy.config
tools.deploy.config.editor vocabs.loader vocabs.metadata ;
IN: tools.deploy.unix

: used-icon ( vocab -- ico )
    dup vocab-dir "icon.png" append-path vocab-append-path
    [ exists? ] keep "vocab:ui/backend/gtk/icon.png" ? ;

: copy-icon ( vocab bundle-name -- )
    [ used-icon ]
    [ "ui/backend/gtk/icon.png" append-path ] bi*
    copy-file ;

: create-app-dir ( vocab bundle-name -- vm )
    [ copy-vm ] [ copy-icon ] 2bi
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
