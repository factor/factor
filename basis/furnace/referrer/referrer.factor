USING: accessors kernel
http.server http.server.filters http.server.responses
furnace ;
IN: furnace.referrer

TUPLE: referrer-check < filter-responder quot ;

C: <referrer-check> referrer-check

M: referrer-check call-responder*
    referrer over quot>> call
    [ call-next-method ]
    [ 2drop 403 "Bad referrer" <trivial-response> ] if ;

: <check-form-submissions> ( responder -- responder' )
    [ same-host? post-request? not or ] <referrer-check> ;
