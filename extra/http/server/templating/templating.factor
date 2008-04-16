USING: accessors kernel fry io.encodings.utf8 io.files
http http.server ;
IN: http.server.templating

MIXIN: template

GENERIC: call-template ( template -- )

M: template write-response-body* call-template ;

: template-convert ( template output -- )
    utf8 [ call-template ] with-file-writer ;

! responder integration
: serve-template ( template -- response )
    "text/html" <content>
    swap '[ , call-template ] >>body ;
