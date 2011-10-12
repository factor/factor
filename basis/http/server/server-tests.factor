USING: accessors continuations http http.server
io.encodings.utf8 io.encodings.binary io.streams.string kernel
math sequences tools.test ;
IN: http.server.tests

[ t ] [ [ \ + first ] [ <500> ] recover response? ] unit-test

[ "text/plain; charset=ASCII" ] [
    <response>
        "text/plain" >>content-type
        "ASCII" >>content-charset
    unparse-content-type
] unit-test

[ "text/xml; charset=UTF-8" ] [
    <response>
        "text/xml" >>content-type
    unparse-content-type
] unit-test

[ "image/jpeg" ] [
    <response>
        "image/jpeg" >>content-type
    unparse-content-type
] unit-test

[ "application/octet-stream" ] [
    <response>
    unparse-content-type
] unit-test

[ t ] [
    {
        "GET / HTTP/1.1"
        "connection: close"
        "host: 127.0.0.1:55532"
        "user-agent: Factor http.client"
    } [ "\n" join ] [ "\r\n" join ] bi
    [ [ read-request ] with-string-reader ] bi@ =
] unit-test
