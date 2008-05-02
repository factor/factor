! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files io.encodings.utf8 namespaces http.server
http.server.static http xmode.code2html kernel html sequences
accessors fry ;
IN: xmode.code2html.responder

: <sources> ( root -- responder )
    [
        drop
        "text/html" <content> swap
        [ "last-modified" set-header ]
        [
            '[
                ,
                dup file-name swap utf8
                <file-reader>
                [ htmlize-stream ] with-html-stream
            ] >>body
        ] bi
    ] <file-responder> ;
