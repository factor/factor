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
    [
        "404" "responder" set
        [ drop no-such-responder ] "get" set
    ] make-responder

    ! Online help browsing
    "help" [ help-responder ] install-cont-responder

    ! Javascript source used by ajax libraries
    [ 
      "contrib/httpd/javascript/" resource-path "doc-root" set
      "javascript" "responder" set
      [ file-responder ] "get" set
      [ file-responder ] "post" set
      [ file-responder ] "head" set
    ] make-responder

    ! Global variables
    "inspector" [ inspect-responder ] install-cont-responder
    
    ! Servers Factor word definitions from the image.
    "browser" [ browser-responder ] install-cont-responder
    
    ! Serves files from a directory stored in the "doc-root"
    ! variable. You can set the variable in the global namespace,
    ! or inside the responder.
    [
        ! "/var/www/" "doc-root" set
        "file" "responder" set
        [ file-responder ] "get" set
        [ file-responder ] "post" set
        [ file-responder ] "head" set
    ] make-responder
    
    ! The root directory is served by...
    "file" set-default-responder

    vhosts nest [ H{ } clone "default" set ] bind
] bind
