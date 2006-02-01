! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: httpd
USING: io browser-responder cont-responder file-responder
help-responder inspect-responder kernel namespaces prettyprint ;

#! Remove all existing responders, and create a blank
#! responder table.
global [
    H{ } clone responders set

    ! 404 error message pages are served by this guy
    "404" [ no-such-responder ] install-cont-responder

    ! Online help browsing
    "help" [ help-responder ] install-cont-responder

    ! Javascript source used by ajax libraries
    "javascript" [ 
        [
            "contrib/httpd/javascript/" resource-path
            "doc-root" set
            file-responder
        ] with-scope
    ] install-cont-responder

    ! Global variables
    "inspector" [ inspect-responder ] install-cont-responder
    
    ! Servers Factor word definitions from the image.
    "browser" [ browser-responder ] install-cont-responder
    
    ! Serves files from a directory stored in the "doc-root"
    ! variable. You can set the variable in the global namespace,
    ! or inside the responder.
    "file" [ file-responder ] install-cont-responder
    
    ! The root directory is served by...
    "file" set-default-responder

    vhosts nest [ H{ } clone "default" set ] bind
] bind
