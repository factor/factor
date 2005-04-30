! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: httpd-responder
USING: browser-responder cont-responder file-responder kernel
namespaces prettyprint quit-responder resource-responder
test-responder ;

#! Remove all existing responders, and create a blank
#! responder table.
global [ <namespace> "httpd-responders" set ] bind

! Runs all unit tests and dumps result to the client. This uses
! a lot of server resources, so disable it on a busy server.
<responder> [
    "test" "responder" set
    [ test-responder ] "get" set
] extend add-responder

! 404 error message pages are served by this guy
<responder> [
    "404" "responder" set
    [ drop no-such-responder ] "get" set
] extend add-responder

! Serves files from a directory stored in the "doc-root"
! variable. You can set the variable in the global namespace,
! or inside the responder.
<responder> [
    ! "/var/www/" "doc-root" set
    "file" "responder" set
    [ file-responder ] "get" set
    [ file-responder ] "post" set
    [ file-responder ] "head" set
] extend add-responder

! Serves Factor source code 
<responder> [
    "resource" "responder" set
    [ resource-responder ] "get" set
] extend add-responder

! Servers Factor word definitions from the image.
"browser" [ f browser-responder ] install-cont-responder

! The root directory is served by...
"file" set-default-responder
