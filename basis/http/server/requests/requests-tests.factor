USING: accessors assocs continuations http http.client
http.client.private http.server http.server.requests io.crlf
io.streams.limited io.streams.string linked-assocs kernel math
math.parser multiline namespaces peg sequences splitting
tools.test urls ;
IN: http.server.requests.tests

: request>string ( request -- string )
    [ write-request ] with-string-writer ;

: string>request ( str -- request )
    [ request-limit get limited-input read-request ] with-string-reader ;

! POST requests
{ "foo=bar" "7" } [
    "foo=bar" "localhost" <post-request> request>string string>request
    [ post-data>> data>> ] [ header>> "content-length" of ] bi
] unit-test

{ f "0" } [
    "" "localhost" <post-request> request>string string>request
    [ post-data>> data>> ] [ header>> "content-length" of ] bi
] unit-test

! Incorrect content-length works fine
{ LH{ { "foo" "bar" } } } [
    { { "foo" "bar" } } "localhost" <post-request> request>string
    "7" "190" replace string>request post-data>> params>>
] unit-test

{ LH{ { "name" "John Smith" } } } [
    { { "name" "John Smith" } } "localhost" <post-request> request>string
    string>request post-data>> params>>
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
    post-data>> params>> "text" of [ filename>> ] [ headers>> ] bi
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

! Relative urls are invalid.
[ "GET foo HTTP/1.1" string>request ] [ path>> "foo" = ] must-fail-with

! Empty request lines
[ "" string>request ] [ parse-error>> parse-error? ] must-fail-with

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

! Negative is it too.
[
    { { "foo" "bar" } } "localhost" <post-request> request>string
    "7" "-1234" replace string>request
] [
    [ invalid-content-length? ]
    [ content-length>> -1234 = ] bi and
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
    } [ join-lines ] [ "\r\n" join ] bi
    [ string>request ] same?
] unit-test
