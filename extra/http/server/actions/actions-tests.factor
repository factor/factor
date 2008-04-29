USING: http.server.actions http.server.validators
tools.test math math.parser multiline namespaces http
io.streams.string http.server sequences splitting accessors ;
IN: http.server.actions.tests

[
    "a" [ v-number ] { { "a" "123" } } validate-param
    [ 123 ] [ "a" get ] unit-test
] with-scope

<action>
    [ "a" get "b" get + ] >>display
    { { "a" [ v-number ] } { "b" [ v-number ] } } >>get-params
"action-1" set

: lf>crlf "\n" split "\r\n" join ;

STRING: action-request-test-1
GET http://foo/bar?a=12&b=13 HTTP/1.1

blah
;

[ 25 ] [
    init-request
    action-request-test-1 lf>crlf
    [ read-request ] with-string-reader
    request set
    { } "action-1" get call-responder
] unit-test
