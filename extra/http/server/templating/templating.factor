USING: accessors kernel fry io.encodings.utf8 io.files
http.server ;
IN: http.server.templating

GENERIC: call-template ( template -- )

: template-convert ( template output -- )
    utf8 [ call-template ] with-file-writer ;

! responder integration
: serve-template ( template -- response )
    "text/html" <content>
    swap '[ , call-template ] >>body ;
