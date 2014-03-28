! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math.parser http accessors kernel xml.syntax xml.writer
io io.streams.string io.encodings.utf8 ;
IN: http.server.responses

: <content> ( body content-type -- response )
    <response>
        200 >>code
        "Document follows" >>message
        utf8 >>content-encoding
        swap >>content-type
        swap >>body ;

: <text-content> ( body -- response )
    "text/plain" <content> ;
    
: trivial-response-body ( code message -- )
    <XML
        <html>
            <body>
                <h1><-> <-></h1>
            </body>
        </html>
    XML> write-xml ;

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
