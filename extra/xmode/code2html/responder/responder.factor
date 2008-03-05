! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files namespaces http.server http.server.static http
xmode.code2html kernel html sequences accessors ;
IN: xmode.code2html.responder

: <sources> ( root -- responder )
    [
        drop
        "text/html" <content>
        over file-http-date "last-modified" set-header
        swap [
            dup file-name swap <file-reader> htmlize-stream
        ] curry >>body
    ] <file-responder> ;
