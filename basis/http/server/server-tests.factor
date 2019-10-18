USING: http http.server math sequences continuations tools.test
io.encodings.utf8 io.encodings.binary accessors ;
IN: http.server.tests

[ t ] [ [ \ + first ] [ <500> ] recover response? ] unit-test

[ "text/plain; charset=UTF-8" ] [
    <response>
        "text/plain" >>content-type
        utf8 >>content-charset
    unparse-content-type
] unit-test

[ "text/xml" ] [
    <response>
        "text/xml" >>content-type
        binary >>content-charset
    unparse-content-type
] unit-test