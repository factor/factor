USING: accessors arrays assocs continuations http http.client
http.client.private http.server http.server.requests io io.crlf
io.streams.limited io.streams.string linked-assocs kernel math
math.parser multiline namespaces peg sequences splitting
strings tools.test urls ;
IN: http.server.requests.tests

: request>string ( request -- string )
    [ write-request ] with-string-writer ;

: string>request ( str -- request )
    [ request-limit get limited-input read-request ] with-string-reader ;

: content-length>request ( content-length -- request )
    { { "foo" "bar" } } "localhost" <post-request> request>string
    "7" rot replace string>request ;

! POST requests
{ "foo=bar" "7" } [
    "foo=bar" "localhost" <post-request> request>string string>request
    [ data>> data>> ] [ header>> "content-length" of ] bi
] unit-test

{ f "0" } [
    "" "localhost" <post-request> request>string string>request
    [ data>> data>> ] [ header>> "content-length" of ] bi
] unit-test

! A truncated request must never reach an action with partial form data.
[
    { { "foo" "bar" } } "localhost" <post-request> request>string
    "7" "190" replace string>request
] [ incomplete-request? ] must-fail-with

! The request-header budget must not silently truncate ordinary bodies.
{ 70000 } [
    70000 CHAR: a <string> "localhost" <post-request>
    request>string string>request data>> data>> length
] unit-test

{ 70000 } [
    "foo" 70000 CHAR: a <string> 2array 1array "localhost" <post-request>
    request>string string>request data>> params>> "foo" of length
] unit-test

! Content-Length also bounds reads when more data follows the body.
{ "abc" "extra" } [
    "POST / HTTP/1.1\r\nContent-Length: 3\r\n\r\nabcextra" [
        request-limit get limited-input read-request data>> data>>
        unlimited-input 5 read
    ] with-string-reader
] unit-test

[
    "POST / HTTP/1.1\r\nContent-Length: 10\r\n\r\nabc" string>request
] [ incomplete-request? ] must-fail-with

! An HTTP/1.1 request line cannot be parsed as a valid prefix or
! downgraded to a simple request when its version is malformed.
[
    "GET / HTTP/1.1 trailing-garbage\r\n\r\n" string>request
] [ bad-request-line? ] must-fail-with

[
    "GET / HTTP/2.0\r\n\r\n" string>request
] [ bad-request-line? ] must-fail-with

! EOF (including the header size limit) is not an empty header line.
[
    "GET / HTTP/1.1\r\nHost: localhost" string>request
] [ incomplete-request? ] must-fail-with

[
    "GET / HTTP/1.1\r\nX-Large: " 70000 CHAR: a <string>
    "\r\n\r\n" 3append string>request
] [ incomplete-request? ] must-fail-with

[
    "GET / HTTP/1.1\r\nBadHeader\r\n\r\n" string>request
] [ bad-request-header? ] must-fail-with

! Values must be parsed in full without stripping semantic quotes.
{ "\"v1\", \"v2\"" } [
    "GET / HTTP/1.1\r\nIf-None-Match: \"v1\", \"v2\"\r\n\r\n"
    string>request "if-none-match" header
] unit-test

{ "abc" } [
    "POST / HTTP/1.1\r\nContent-Length: \t3 \t\r\n\r\nabc"
    string>request data>> data>>
] unit-test

[
    "POST / HTTP/1.1\r\nContent-Length: \"3\"junk\r\n\r\nabc" string>request
] [ invalid-content-length? ] must-fail-with

[
    "POST / HTTP/1.1\r\nContent-Length: 3\0junk\r\n\r\nabc" string>request
] [ bad-request-header? ] must-fail-with

[
    "POST / HTTP/1.1\r\nContent-Length : 3\r\n\r\nabc" string>request
] [ bad-request-header? ] must-fail-with

[
    "GET / HTTP/1.1\r\nX-Test: value\r\n continuation\r\n\r\n" string>request
] [ bad-request-header? ] must-fail-with

[
    "GET / HTTP/1.1\r\nHost: localhost:garbage\r\n\r\n" string>request
] [ bad-request-header? ] must-fail-with

[
    "GET / HTTP/1.1\rX" string>request
] [ malformed-request? ] must-fail-with

[
    "POST / HTTP/1.1\r\nContent-Length: 12\r\nContent-Type: multipart/form-data; boundary=xyz\r\n\r\n--xyz\r\nshort"
    string>request
] [ bad-request-body? ] must-fail-with

! Chunked requests are unsupported; never interpret them using a
! conflicting Content-Length or ignore the coding on a GET request.
[
    "POST / HTTP/1.1\r\nTransfer-Encoding: chunked\r\nContent-Length: 3\r\n\r\nabc"
    string>request
] [ unsupported-transfer-encoding? ] must-fail-with

[
    "GET / HTTP/1.1\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\n"
    string>request
] [ unsupported-transfer-encoding? ] must-fail-with

! A boundary is a named MIME parameter, and can be quoted or follow
! other parameters.
{ "xyz" } [
    "multipart/form-data; boundary=\"xyz\"" parse-multipart-form-data
] unit-test

{ "xyz" } [
    "multipart/form-data; charset=UTF-8; Boundary=xyz"
    parse-multipart-form-data
] unit-test

[
    "multipart/form-data; boundary=\"\"" parse-multipart-form-data
] [ no-boundary? ] must-fail-with

[
    "multipart/form-data; charset=UTF-8" parse-multipart-form-data
] [ no-boundary? ] must-fail-with

{ LH{ { "name" "John Smith" } } } [
    { { "name" "John Smith" } } "localhost" <post-request> request>string
    string>request data>> params>>
] unit-test

! multipart/form-data
STRING: test-multipart/form-data
POST / HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 151
Content-Type: multipart/form-data; boundary=768de80194d942619886d23f1337aa15
Host: localhost:8000
User-Agent: HTTPie/0.9.0-dev

--768de80194d942619886d23f1337aa15
Content-Disposition: form-data; name="text"; filename="upload.txt"

hello
--768de80194d942619886d23f1337aa15--

;
{
    "upload.txt"
    H{
        { "content-disposition"
          "form-data; name=\"text\"; filename=\"upload.txt\"" }
    }
} [
    test-multipart/form-data lf>crlf string>request
    data>> params>> "text" of [ filename>> ] [ headers>> ] bi
] unit-test

! Exercise quoted boundary extraction through the complete HTTP parser.
{ "upload.txt" } [
    test-multipart/form-data lf>crlf
    "boundary=768de80194d942619886d23f1337aa15"
    "charset=UTF-8; boundary=\"768de80194d942619886d23f1337aa15\""
    replace string>request data>> params>> "text" of filename>>
] unit-test

! Error handling
! If the incoming request is not valid, read-request should throw an
! appropriate error.
STRING: test-multipart/form-data-missing-boundary
POST / HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 151
Content-Type: multipart/form-data; abcd
Host: localhost:8000
User-Agent: HTTPie/0.9.0-dev

--768de80194d942619886d23f1337aa15
Content-Disposition: form-data; name="text"; filename="upload.txt"

hello
--768de80194d942619886d23f1337aa15--

;
[ test-multipart/form-data-missing-boundary string>request ]
[ no-boundary? ] must-fail-with

! A complete MIME delimiter does not excuse missing HTTP body bytes.
[
    test-multipart/form-data lf>crlf
    "Content-Length: 151" "Content-Length: 251" replace string>request
] [ incomplete-request? ] must-fail-with

: sized-multipart-request ( n suffix -- request )
    [
        "--x\r\nContent-Disposition: form-data; name=\"v\"\r\n\r\n"
        swap CHAR: a <string> append "\r\n--x--" append
    ] dip append
    dup length number>string
    "POST / HTTP/1.1\r\nContent-Type: multipart/form-data; boundary=x\r\nContent-Length: "
    swap append "\r\n\r\n" append swap append string>request ;

! Exercise every position of the closing marker around a buffer boundary.
{ t } [
    { 65480 65481 65482 65483 65484 65485 65486 } [
        dup "\r\n" sized-multipart-request data>> params>> "v" of length =
    ] all?
] unit-test

{ 5 5 5 } [
    5 "" sized-multipart-request data>> params>> "v" of length
    5 " \t\r\nepilogue" sized-multipart-request data>> params>> "v" of length
    5 "\r\n" 70000 CHAR: e <string> append sized-multipart-request
    data>> params>> "v" of length
] unit-test

[
    5 "junk" sized-multipart-request
] [ bad-request-body? ] must-fail-with

! Relative urls are invalid.
[ "GET foo HTTP/1.1" string>request ] [ path>> "foo" = ] must-fail-with

! Empty request lines
[ "" string>request ] [ parse-error>> parse-error? ] must-fail-with

! An incomplete TLS record must be rejected without waiting for more
! input. A finite string alone would not catch the blocking-read bug.
TUPLE: incomplete-tls-stream read? ;

M: incomplete-tls-stream stream-read1
    dup read?>> [ drop "Read past TLS record type" throw ] [
        t >>read? drop 0x16
    ] if ;

M: incomplete-tls-stream stream-read-until
    nip dup stream-read1 drop stream-read1 drop f f ;

[
    incomplete-tls-stream new [ <request> read-request-line ]
    with-input-stream*
] [ bad-request-line? ] must-fail-with

{ "GET" "GET" } [
    "\n\nGET / HTTP/1.0\n\n" string>request method>>
    "\tGET / HTTP/1.0\r\n\r\n" string>request method>>
] unit-test

! Missing content-length is probably not ok. It's plausible
! transfer-length could replace it, but we don't handle it atm anyway.
[
    { { "foo" "bar" } } "localhost" <post-request> request>string
    "content-length" "foo" replace string>request
] [ content-length-missing? ] must-fail-with

! Non-numeric content-length is ofc crap.
[
    { { "foo" "bar" } } "localhost" <post-request> request>string
    "7" "i am not a number!" replace string>request
] [
    [ invalid-content-length? ]
    [ content-length>> "i am not a number!" = ] bi and
] must-fail-with

! Content-Length permits decimal digits only.
[ "0x7" content-length>request ] [
    [ invalid-content-length? ]
    [ content-length>> "0x7" = ] bi and
] must-fail-with

[ "+7" content-length>request ] [
    [ invalid-content-length? ]
    [ content-length>> "+7" = ] bi and
] must-fail-with

[ "7.0" content-length>request ] [
    [ invalid-content-length? ]
    [ content-length>> "7.0" = ] bi and
] must-fail-with

! Negative is it too.
[ "-1234" content-length>request ] [
    [ invalid-content-length? ]
    [ content-length>> "-1234" = ] bi and
] must-fail-with

! And too big
[
    { { "foo" "bar" } } "localhost" <post-request> request>string
    "7" upload-limit get 1 + number>string replace string>request
] [
    [ invalid-content-length? ]
    [ content-length>> upload-limit get 1 + = ] bi and
] must-fail-with


! RFC 2616: Section 4.1
! In the interest of robustness, servers SHOULD ignore any empty
! line(s) received where a Request-Line is expected. In other words, if
! the server is reading the protocol stream at the beginning of a
! message and receives a CRLF first, it should ignore the CRLF.
{
    T{ request
        { method "GET" }
        { url URL" /" }
        { proxy-url URL" " }
        { version "1.0" }
        { header H{ } }
        { cookies V{ } }
        { redirects 10 }
    }
} [
    "\r\n\r\n\r\nGET / HTTP/1.0\r\n\r\n" [ read-request ] with-string-reader
] unit-test

! RFC 2616: Section 19.3
! The line terminator for message-header fields is the sequence CRLF.
! However, we recommend that applications, when parsing such headers,
! recognize a single LF as a line terminator and ignore the leading CR.
{ t } [
    {
        "GET / HTTP/1.1"
        "connection: close"
        "host: 127.0.0.1:55532"
        "user-agent: Factor http.client"
        "" ""
    } [ join-lines ] [ "\r\n" join ] bi
    [ string>request ] same?
] unit-test
