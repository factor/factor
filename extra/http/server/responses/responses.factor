! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: html.elements math.parser http accessors kernel
io io.streams.string ;
IN: http.server.responses

: <content> ( body content-type -- response )
    <response>
        200 >>code
        "Document follows" >>message
        swap >>content-type
        swap >>body ;
    
: trivial-response-body ( code message -- )
    <html>
        <body>
            <h1> [ number>string write bl ] [ write ] bi* </h1>
        </body>
    </html> ;

: <trivial-response> ( code message -- response )
    2dup [ trivial-response-body ] with-string-writer
    "text/html" <content>
        swap >>message
        swap >>code ;

: <304> ( -- response )
    304 "Not modified" <trivial-response> ;

: <403> ( -- response )
    403 "Forbidden" <trivial-response> ;

: <400> ( -- response )
    400 "Bad request" <trivial-response> ;

: <404> ( -- response )
    404 "Not found" <trivial-response> ;
