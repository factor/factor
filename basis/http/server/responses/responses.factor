! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry http io io.encodings.utf8 io.files
io.streams.string kernel math math.parser parser sequences
splitting unicode words xml.syntax xml.writer ;
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

: <html-content> ( body -- response )
    "text/html" <content> ;

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
    <html-content>
        swap >>message
        swap >>code ;

<<
"vocab:http/server/responses/http-status-codes.txt"
utf8 file-lines [ [ blank? ] trim ] map
dup [ "Value" head? ] find drop 1 + tail
[ "Unassigned" swap subseq? ] reject
[
    "[RFC" over start head " " split1 [ blank? ] trim
    [
        [
            "<" ">" surround create-word-in dup reset-generic
        ] keep string>number
    ] dip '[ _ _ <trivial-response> ] ( -- response )
    define-declared
] each
>>
