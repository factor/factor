USING: http http.server math sequences continuations tools.test
io.encodings.utf8 io.encodings.binary accessors ;
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