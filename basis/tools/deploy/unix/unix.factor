! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: io io.pathnames io.directories io.files
io.files.info.unix io.backend kernel namespaces make sequences
system tools.deploy.backend tools.deploy.config
tools.deploy.config.editor assocs hashtables prettyprint ;
IN: tools.deploy.unix

: create-app-dir ( vocab bundle-name -- vm )
    dup "" copy-theme
    copy-vm
    dup OCT: 755 set-file-permissions ;

: bundle-name ( -- str )
    deploy-name get ;

M: unix deploy* ( vocab -- )
    "." resource-path [
        dup deploy-config [
            [ bundle-name create-app-dir ] keep
            [ bundle-name image-name ] keep
            namespace make-deploy-image
            bundle-name normalize-path [ "Binary deployed to " % % "." % ] "" make print
        ] bind
    ] with-directory ;