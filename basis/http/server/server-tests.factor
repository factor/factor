USING: accessors assocs continuations http http.server
http.server.requests io.encodings.utf8 io.encodings.binary io.streams.string
kernel math peg sequences tools.test urls ;
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

! Don't rethrow parse-errors with an empty request string. They are
! expected from certain browsers when the server serves a certificate
! that the browser can't verify.
{ } [
    0 "" f <parse-error> \ bad-request-line boa handle-client-error
] unit-test

[
    0 "not empty" f <parse-error> handle-client-error
] [ parse-error? ] must-fail-with
