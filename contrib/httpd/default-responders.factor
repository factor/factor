! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: httpd
USING: browser-responder callback-responder file-responder
help-responder inspect-responder io kernel namespaces
prettyprint ;

#! Remove all existing responders, and create a blank
#! responder table.
global [
    H{ } clone responders set

    ! 404 error message pages are served by this guy
    "404" [ no-such-responder ] add-simple-responder

    ! Online help browsing
    "help" [ help-responder ] add-simple-responder
    
    ! Used by other responders
    "callback" [ callback-responder ] add-simple-responder

    ! Javascript source used by ajax libraries
    "javascript" [ 
        [
            "contrib/httpd/javascript/" resource-path
            "doc-root" set
            file-responder
        ] with-scope
    ] add-simple-responder

    ! Global variables
    "inspector" [ inspect-responder ] add-simple-responder
    
    ! Servers Factor word definitions from the image.
    "browser" [ browser-responder ] add-simple-responder
    
    ! Serves files from a directory stored in the "doc-root"
    ! variable. You can set the variable in the global namespace,
    ! or inside the responder.
    "file" [ file-responder ] add-simple-responder
    
    ! The root directory is served by...
    "file" set-default-responder

    vhosts nest [ H{ } clone "default" set ] bind
] bind
