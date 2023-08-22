! Copyright (C) 2007, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: io io.files io.pathnames io.encodings.utf8 namespaces
http.server http.server.responses http.server.static http
xmode.code2html kernel sequences accessors fry ;
IN: xmode.code2html.responder

: <sources> ( root -- responder )
    [
        drop
        dup '[
            _ utf8 [
                _ file-name input-stream get htmlize-stream
            ] with-file-reader
        ] <html-content>
    ] <file-responder> ;
