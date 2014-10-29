USING: accessors assocs http http.server http.server.requests
io.streams.limited io.streams.string kernel multiline namespaces sequences
splitting tools.test urls ;
IN: http.server.requests.tests

: normalize-nl ( str -- str' )
    "\n" "\r\n" replace ;

: string>request ( str -- request )
    normalize-nl
    [ request-limit get limited-input read-request ] with-string-reader ;

! POST requests
STRING: test-post-no-content-type
POST / HTTP/1.1
connection: close
host: 127.0.0.1:55532
user-agent: Factor http.client
content-length: 7

foo=bar
;
{ "foo=bar" "7" } [
    test-post-no-content-type string>request
    [ post-data>> data>> ] [ header>> "content-length" of ] bi
] unit-test

STRING: test-post-0-content-length
POST / HTTP/1.1
connection: close
host: 127.0.0.1:55532
user-agent: Factor http.client
content-length: 0


;
{ f "0" } [
    test-post-0-content-length string>request
    [ post-data>> data>> ] [ header>> "content-length" of ] bi
] unit-test

! Should work no problem.
STRING: test-post-wrong-content-length
POST / HTTP/1.1
connection: close
host: 127.0.0.1:55532
user-agent: Factor http.client
Content-Type: application/x-www-form-urlencoded; charset=utf-8
content-length: 190

foo=bar
;
{ H{ { "foo" "bar" } } } [
    test-post-wrong-content-length string>request post-data>> params>>
] unit-test

STRING: test-post-urlencoded
POST / HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 15
Content-Type: application/x-www-form-urlencoded; charset=utf-8
Host: news.ycombinator.com
User-Agent: HTTPie/0.9.0-dev

name=John+Smith
;
{ H{ { "name" "John Smith" } } } [
    test-post-urlencoded string>request post-data>> params>>
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
    test-multipart/form-data string>request post-data>> params>> "text" of
    [ filename>> ] [ headers>> ] bi
] unit-test

! RFC 2616: Section 4.1
! In the interest of robustness, servers SHOULD ignore any empty
! line(s) received where a Request-Line is expected. In other words, if
! the server is reading the protocol stream at the beginning of a
! message and receives a CRLF first, it should ignore the CRLF.
[
    T{ request
        { method "GET" }
        { url URL" /" }
        { version "1.0" }
        { header H{ } }
        { cookies V{ } }
        { redirects 10 }
    }
] [
    "\r\n\r\n\r\nGET / HTTP/1.0\r\n\r\n"
    [ read-request ] with-string-reader
] unit-test

! RFC 2616: Section 19.3
! The line terminator for message-header fields is the sequence CRLF.
! However, we recommend that applications, when parsing such headers,
! recognize a single LF as a line terminator and ignore the leading CR.
[ t ] [
    {
        "GET / HTTP/1.1"
        "connection: close"
        "host: 127.0.0.1:55532"
        "user-agent: Factor http.client"
    } [ "\n" join ] [ "\r\n" join ] bi
    [ [ read-request ] with-string-reader ] same?
] unit-test
