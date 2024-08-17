! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors http io.encodings.utf8 io.streams.string kernel
xml.syntax xml.writer ;
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
        <!DOCTYPE html>
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

: <100> ( -- response ) "100" "Continue" <trivial-response> ;
: <101> ( -- response ) "101" "Switching Protocols" <trivial-response> ;
: <102> ( -- response ) "102" "Processing" <trivial-response> ;
: <103> ( -- response ) "103" "Early Hints" <trivial-response> ;
: <110> ( -- response ) "110" "Response Is Stale" <trivial-response> ;
: <111> ( -- response ) "111" "Revalidation Failed" <trivial-response> ;
: <112> ( -- response ) "112" "Disconnected Operation" <trivial-response> ;
: <113> ( -- response ) "113" "Heuristic Expiration" <trivial-response> ;
: <199> ( -- response ) "199" "Miscellaneous Warning" <trivial-response> ;
: <200> ( -- response ) "200" "OK" <trivial-response> ;
: <201> ( -- response ) "201" "Created" <trivial-response> ;
: <202> ( -- response ) "202" "Accepted" <trivial-response> ;
: <203> ( -- response ) "203" "Non-Authoritative Information" <trivial-response> ;
: <204> ( -- response ) "204" "No Content" <trivial-response> ;
: <205> ( -- response ) "205" "Reset Content" <trivial-response> ;
: <206> ( -- response ) "206" "Partial Content" <trivial-response> ;
: <207> ( -- response ) "207" "Multi-Status" <trivial-response> ;
: <208> ( -- response ) "208" "Already Reported" <trivial-response> ;
: <214> ( -- response ) "214" "Transformation Applied" <trivial-response> ;
: <218> ( -- response ) "218" "This Is Fine" <trivial-response> ;
: <226> ( -- response ) "226" "IM Used" <trivial-response> ;
: <299> ( -- response ) "299" "Miscellaneous Persistent Warning" <trivial-response> ;
: <300> ( -- response ) "300" "Multiple Choices" <trivial-response> ;
: <301> ( -- response ) "301" "Moved Permanently" <trivial-response> ;
: <302> ( -- response ) "302" "Found" <trivial-response> ;
: <303> ( -- response ) "303" "See Other" <trivial-response> ;
: <304> ( -- response ) "304" "Not Modified" <trivial-response> ;
: <305> ( -- response ) "305" "Use Proxy" <trivial-response> ;
: <306> ( -- response ) "306" "(Unused)" <trivial-response> ;
: <307> ( -- response ) "307" "Temporary Redirect" <trivial-response> ;
: <308> ( -- response ) "308" "Permanent Redirect" <trivial-response> ;
: <400> ( -- response ) "400" "Bad Request" <trivial-response> ;
: <401> ( -- response ) "401" "Unauthorized" <trivial-response> ;
: <402> ( -- response ) "402" "Payment Required" <trivial-response> ;
: <403> ( -- response ) "403" "Forbidden" <trivial-response> ;
: <404> ( -- response ) "404" "Not Found" <trivial-response> ;
: <405> ( -- response ) "405" "Method Not Allowed" <trivial-response> ;
: <406> ( -- response ) "406" "Not Acceptable" <trivial-response> ;
: <407> ( -- response ) "407" "Proxy Authentication Required" <trivial-response> ;
: <408> ( -- response ) "408" "Request Timeout" <trivial-response> ;
: <409> ( -- response ) "409" "Conflict" <trivial-response> ;
: <410> ( -- response ) "410" "Gone" <trivial-response> ;
: <411> ( -- response ) "411" "Length Required" <trivial-response> ;
: <412> ( -- response ) "412" "Precondition Failed" <trivial-response> ;
: <413> ( -- response ) "413" "Payload Too Large" <trivial-response> ;
: <414> ( -- response ) "414" "URI Too Long" <trivial-response> ;
: <415> ( -- response ) "415" "Unsupported Media Type" <trivial-response> ;
: <416> ( -- response ) "416" "Range Not Satisfiable" <trivial-response> ;
: <417> ( -- response ) "417" "Expectation Failed" <trivial-response> ;
: <418> ( -- response ) "418" "I'm a teapot" <trivial-response> ;
: <419> ( -- response ) "419" "Page Expired" <trivial-response> ;
: <420> ( -- response ) "420" "Method Failure or Enhance Your Calm" <trivial-response> ;
: <421> ( -- response ) "421" "Misdirected Request" <trivial-response> ;
: <422> ( -- response ) "422" "Unprocessable Entity" <trivial-response> ;
: <423> ( -- response ) "423" "Locked" <trivial-response> ;
: <424> ( -- response ) "424" "Failed Dependency" <trivial-response> ;
: <425> ( -- response ) "425" "Too Early" <trivial-response> ;
: <426> ( -- response ) "426" "Upgrade Required" <trivial-response> ;
: <428> ( -- response ) "428" "Precondition Required" <trivial-response> ;
: <429> ( -- response ) "429" "Too Many Requests" <trivial-response> ;
: <430> ( -- response ) "430" "HTTP Status Code" <trivial-response> ;
: <431> ( -- response ) "431" "Request Header Fields Too Large" <trivial-response> ;
: <440> ( -- response ) "440" "Login Timeout" <trivial-response> ;
: <444> ( -- response ) "444" "No Response" <trivial-response> ;
: <449> ( -- response ) "449" "Retry With" <trivial-response> ;
: <451> ( -- response ) "451" "Unavailable For Legal Reasons" <trivial-response> ;
: <460> ( -- response ) "460" "Client Closed Connection Prematurely" <trivial-response> ;
: <463> ( -- response ) "463" "Too Many Forwarded IP Addresses" <trivial-response> ;
: <464> ( -- response ) "464" "Incompatible Protocol" <trivial-response> ;
: <494> ( -- response ) "494" "Request Header Too Large" <trivial-response> ;
: <495> ( -- response ) "495" "SSL Certificate Error" <trivial-response> ;
: <496> ( -- response ) "496" "SSL Certificate Required" <trivial-response> ;
: <497> ( -- response ) "497" "HTTP Request Sent to HTTPS Port" <trivial-response> ;
: <498> ( -- response ) "498" "Invalid Token" <trivial-response> ;
: <499> ( -- response ) "499" "Client Closed Request" <trivial-response> ;
: <500> ( -- response ) "500" "Internal Server Error" <trivial-response> ;
: <501> ( -- response ) "501" "Not Implemented" <trivial-response> ;
: <502> ( -- response ) "502" "Bad Gateway" <trivial-response> ;
: <503> ( -- response ) "503" "Service Unavailable" <trivial-response> ;
: <504> ( -- response ) "504" "Gateway Timeout" <trivial-response> ;
: <505> ( -- response ) "505" "HTTP Version Not Supported" <trivial-response> ;
: <506> ( -- response ) "506" "Variant Also Negotiates" <trivial-response> ;
: <507> ( -- response ) "507" "Insufficient Storage" <trivial-response> ;
: <508> ( -- response ) "508" "Loop Detected" <trivial-response> ;
: <509> ( -- response ) "509" "Bandwidth Limit Exceeded" <trivial-response> ;
: <510> ( -- response ) "510" "Not Extended" <trivial-response> ;
: <511> ( -- response ) "511" "Network Authentication Required" <trivial-response> ;
: <520> ( -- response ) "520" "Web Server Is Returning an Unknown Error" <trivial-response> ;
: <521> ( -- response ) "521" "Web Server Is Down" <trivial-response> ;
: <522> ( -- response ) "522" "Connection Timed Out" <trivial-response> ;
: <523> ( -- response ) "523" "Origin Is Unreachable" <trivial-response> ;
: <524> ( -- response ) "524" "A Timeout Occurred" <trivial-response> ;
: <525> ( -- response ) "525" "SSL Handshake Failed" <trivial-response> ;
: <526> ( -- response ) "526" "Invalid SSL Certificate" <trivial-response> ;
: <527> ( -- response ) "527" "Railgun Listener to Origin" <trivial-response> ;
: <529> ( -- response ) "529" "The Service Is Overloaded" <trivial-response> ;
: <530> ( -- response ) "530" "Site Frozen" <trivial-response> ;
: <561> ( -- response ) "561" "Unauthorized" <trivial-response> ;
: <598> ( -- response ) "598" "Network Read Timeout Error" <trivial-response> ;
: <599> ( -- response ) "599" "Network Connect Timeout Error" <trivial-response> ;
: <999> ( -- response ) "999" "Unauthorized" <trivial-response> ;
