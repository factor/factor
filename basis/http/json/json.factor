USING: accessors http http.client http.client.private
io.encodings.string io.encodings.utf8 json kernel strings ;

IN: http.json

: accept-json ( request -- request )
    "application/json" "Accept" set-header ;

: <json-request> ( url method -- request )
    <client-request> accept-json ;

: <json-data> ( assoc/json-string -- post-data )
    dup string? [ >json ] unless utf8 encode
    "application/json" <post-data> swap >>data ;

: http-request-json ( request -- response json )
    http-request json> ;

: http-json ( request -- json )
    http-request-json nip ;

: http-get-json ( url -- response json )
    "GET" <json-request> http-request-json ;

: http-put-json ( assoc/json-string url -- response json )
    [ <json-data> ] dip "PUT" <json-request> swap >>data http-request-json ;

: http-post-json ( assoc/json-string url -- response json )
    [ <json-data> ] dip "POST" <json-request> swap >>data http-request-json ;

: http-head-json ( url -- response json )
    "HEAD" <json-request> http-request-json ;

: http-options-json ( url -- response json )
    "OPTIONS" <json-request> http-request-json ;

: http-delete-json ( url -- response json )
    "DELETE" <json-request> http-request-json ;

: http-trace-json ( url -- response json )
    "TRACE" <json-request> http-request-json ;

: http-patch-json ( assoc/json-string url -- response json )
    [ <json-data> ] dip "PATCH" <json-request> swap >>data http-request-json ;

: rest-request-json ( url method -- response json )
    <json-request> http-request-json ;

: rest-request-json-with-body ( body url method -- response json )
    [ <json-data> ] 2dip <json-request> swap >>data http-request-json ;
