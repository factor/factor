! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files namespaces webapps.file http.server.responders
xmode.code2html kernel html ;
IN: webapps.source

global [
    ! Serve up our own source code
    "source" [
        [
            "" resource-path "doc-root" set
            [
                drop
                serving-html
                [ swap htmlize-stream ] with-html-stream
            ] serve-file-hook set
            file-responder
        ] with-scope
    ] add-simple-responder
] bind
