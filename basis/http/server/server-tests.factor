USING: accessors assocs continuations http http.server
http.server.requests http.server.responses io.encodings.utf8 io.encodings.binary
io.streams.string kernel math peg sequences tools.test urls
splitting ;
FROM: http.server => <500> ;

! Bodyless status codes and HEAD must not invoke a response template.
! Both numeric and string status codes are used by response constructors.
{ t } [
    { 100 101 199 204 205 304 "100" "204" "205" "304" } [
        <response> swap >>code "Test" >>message
        [ "Body must not be called" throw ] >>body
        <request> "GET" >>method swap
        [ write-full-response ] with-string-writer
        "\r\n\r\n" split1 nip empty?
    ] all?
] unit-test

{ "" } [
    <request> "HEAD" >>method
    [ "Body must not be called" throw ] <text-content>
    [ write-full-response ] with-string-writer "\r\n\r\n" split1 nip
] unit-test

{ "body" } [
    <request> "GET" >>method "body" <text-content>
    [ write-full-response ] with-string-writer "\r\n\r\n" split1 nip
] unit-test

{ "" } [
    <request> "GET" >>method <304>
    [ write-full-response ] with-string-writer "\r\n\r\n" split1 nip
] unit-test

{ t } [ [ \ + first ] [ <500> ] recover response? ] unit-test

{ "text/plain; charset=ASCII" } [
    <response>
        "text/plain" >>content-type
        "ASCII" >>content-charset
    unparse-content-type
] unit-test

{ "text/xml; charset=UTF-8" } [
    <response>
        "text/xml" >>content-type
    unparse-content-type
] unit-test

{ "image/jpeg" } [
    <response>
        "image/jpeg" >>content-type
    unparse-content-type
] unit-test

{ "application/octet-stream" } [
    <response>
    unparse-content-type
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
    [ [ read-request ] with-string-reader ] same?
] unit-test

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
    "\r\n\r\n\r\nGET / HTTP/1.0\r\n\r\n"
    [ read-request ] with-string-reader
] unit-test

! RFC 1945; Section 4.1
! Implement a version of Simple-Request, although rather than
! parse version 0.9, we parse 1.0 to return a Full-Response.
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
    "\r\n\r\n\r\nGET /\r\n\r\n"
    [ read-request ] with-string-reader
] unit-test

! Don't rethrow parse-errors with an empty request string. They are
! expected from certain browsers when the server serves a certificate
! that the browser can't verify.
{ } [
    0 "" f <parse-error> \ bad-request-line boa handle-client-error
] unit-test

[
    0 "not empty" f <parse-error> handle-client-error
] [ parse-error? ] must-fail-with
