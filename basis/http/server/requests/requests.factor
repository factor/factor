USING: accessors arrays ascii combinators combinators.short-circuit continuations
http http.parsers io io.crlf io.encodings io.encodings.binary
io.streams.limited io.streams.throwing kernel make math.order math.parser
namespaces peg peg.parsers
sequences splitting strings urls urls.encoding ;
FROM: mime.multipart => parse-multipart mime-decoding-ran-out-of-bytes?
no-content-disposition? unknown-content-disposition? ;
IN: http.server.requests

ERROR: request-error ;

ERROR: no-boundary < request-error ;

ERROR: invalid-path < request-error path ;

ERROR: invalid-content-length < request-error content-length ;

ERROR: content-length-missing < request-error ;

ERROR: bad-request-line < request-error parse-error ;

ERROR: bad-request-header < request-error error ;

ERROR: bad-request-body < request-error error ;

ERROR: incomplete-request < request-error ;

ERROR: malformed-request < request-error error ;

ERROR: unsupported-transfer-encoding < request-error transfer-encoding ;

: check-absolute ( url -- )
    path>> dup "/" head? [ drop ] [ invalid-path ] if ; inline

<PRIVATE

PARTIAL-PEG: parse-server-request-line ( string -- triple )
    full-request-parser simple-request-parser 2array choice just ;

PARTIAL-PEG: parse-server-header-line ( string -- pair )
    [
        field-name-parser ,
        ":" token hide ,
        space-parser ,
        [ dup CHAR: \t = swap control? not or ] satisfy repeat0
        case-sensitive [ [ blank? ] trim-tail ] action ,
    ] seq* just ;

PRIVATE>

: parse-request-line-safe ( string -- triple )
    [ parse-server-request-line ] [ nip bad-request-line ] recover ;

<PRIVATE

: read-request-line-string ( -- string/f )
    read1 {
        { f [ f ] }
        { CHAR: \r [ read1 CHAR: \n assert= "" ] }
        { CHAR: \n [ "" ] }
        [
            ! Reject binary protocols before waiting for a newline. In
            ! particular, a TLS ClientHello starts with the control byte
            ! 0x16; waiting for its random payload to contain a newline
            ! deadlocks the HTTP server and the TLS client (#2823).
            dup control? over CHAR: \t = not and [
                dup 1string parse-request-line-safe drop
            ] when
            read-?crlf "" or swap prefix
        ]
    } case ;

PRIVATE>

: read-request-line ( request -- request )
    read-request-line-string
    [ dup "" = ] [ drop read-request-line-string ] while
    parse-request-line-safe first3
    [ >>method ] [ >url dup check-absolute >>url ] [ >>version ] tri* ;

: read-request-header ( request -- request )
    [ read-?crlf [ incomplete-request ] unless* dup empty? not ]
    [ [ parse-server-header-line ] [ nip bad-request-header ] recover ]
    produce nip process-header >>header ;

SYMBOL: upload-limit

upload-limit [ 200,000,000 ] initialize

: parse-multipart-form-data ( string -- separator )
    ";" split1 nip
    [ av-pairs-parser parse-fully ] [ 2drop no-boundary ] recover
    [ first >lower "boundary" = ] find nip
    [ second ] [ no-boundary ] if*
    dup empty? [ no-boundary ] when ;

: maybe-limit-input ( content-length -- )
    input-stream get dup decoder? [ stream>> ] when
    limited-stream? [ unlimited-input ] when
    upload-limit get [ min ] when* limited-input ;

: read-multipart-data ( request content-length -- mime-parts )
    maybe-limit-input binary decode-input
    ! Keep the throwing stream inside the length limit: reaching the
    ! declared end is normal, but earlier transport EOF is an error.
    input-stream [ [ <throws-on-eof-stream> ] change-stream ] change
    "content-type" header parse-multipart-form-data
    [
        parse-multipart
        ! Read the MIME epilogue using full reads: limited-stream counts
        ! requested bytes, so partial reads cannot verify Content-Length.
        [ 65536 read ] [ drop ] while*
    ] [
        nip dup stream-exhausted? [ drop incomplete-request ] when
        dup {
            [ mime-decoding-ran-out-of-bytes? ]
            [ no-content-disposition? ]
            [ unknown-content-disposition? ]
            [ assert-sequence? ]
            [ parse-error? ]
        } 1|| [ bad-request-body ] [ rethrow ] if
    ] recover ;

: read-content ( content-length -- content )
    dup maybe-limit-input
    [ read ] keep over length = [ incomplete-request ] unless ;

: parse-content-length-safe ( request -- content-length )
    "content-length" header [
        [ dup [ digit? ] all? [ string>number ] [ drop f ] if ]
        [
            dup 0 upload-limit get between? [
                invalid-content-length
            ] unless
        ] [ invalid-content-length ] ?if
    ] [ content-length-missing ] if* ;

: parse-content ( request content-type -- post-data )
    dup <post-data> -rot over parse-content-length-safe swap
    {
        { "multipart/form-data" [ read-multipart-data >>params ] }
        { "application/x-www-form-urlencoded" [
            nip read-content query>assoc >>params
        ] }
        [ drop nip read-content >>data ]
    } case ;

: read-request-data ( request -- request )
    dup "transfer-encoding" header
    [ unsupported-transfer-encoding ] when*
    dup method>> { "POST" "PUT" "PATCH" } member? [
        dup dup "content-type" header
        ";" split1 drop parse-content >>data
    ] when ;

: extract-host ( request -- request )
    [ ] [ url>> ] [
        "host" header [ parse-host ] [ nip bad-request-header ] recover
    ] tri
    [ >>host ] [ >>port ] bi*
    drop ;

: extract-cookies ( request -- request )
    dup "cookie" header [ parse-cookie >>cookies ] when* ;

: read-request ( -- request )
    [
        <request>
        read-request-line
        read-request-header
        read-request-data
        extract-host
        extract-cookies
    ] [
        dup { [ assert? ] [ parse-error? ] } 1||
        [ malformed-request ] [ rethrow ] if
    ] recover ;
