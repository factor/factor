! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files io.encodings.utf8 namespaces http.server
http.server.static http xmode.code2html kernel html sequences
accessors fry ;
IN: xmode.code2html.responder

: <sources> ( root -- responder )
    [
        drop
         '[
            , [ file-name ] keep utf8 [
                [ htmlize-stream ] with-html-stream
            ] with-file-reader
        ] <html-content>
    ] <file-responder> ;
