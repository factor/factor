USING: accessors kernel fry io io.encodings.utf8 io.files
http http.server debugger prettyprint continuations ;
IN: http.server.templating

MIXIN: template

GENERIC: call-template* ( template -- )

ERROR: template-error template error ;

M: template-error error.
    "Error while processing template " write
    [ template>> pprint ":" print nl ]
    [ error>> error. ]
    bi ;

: call-template ( template -- )
    [ call-template* ] [ template-error ] recover ;

M: template write-response-body* call-template ;

: template-convert ( template output -- )
    utf8 [ call-template ] with-file-writer ;

! responder integration
: serve-template ( template -- response )
    "text/html" <content>
    swap '[ , call-template ] >>body ;
