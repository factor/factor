USING: kernel furnace.actions validators
tools.test math math.parser multiline namespaces http
io.streams.string http.server sequences splitting accessors ;
IN: furnace.actions.tests

<action>
    [ "a" param "b" param [ string>number ] bi@ + ] >>display
"action-1" set

: lf>crlf ( string -- string' ) "\n" split "\r\n" join ;

STRING: action-request-test-1
GET http://foo/bar?a=12&b=13 HTTP/1.1

blah
;

[ 25 ] [
    action-request-test-1 lf>crlf
    [ read-request ] with-string-reader
    init-request
    { } "action-1" get call-responder
] unit-test

<action>
    "a" >>rest
    [ "a" param string>number sq ] >>display
"action-2" set

STRING: action-request-test-2
GET http://foo/bar/123 HTTP/1.1

blah
;

[ 25 ] [
    action-request-test-2 lf>crlf
    [ read-request ] with-string-reader
    init-request
    { "5" } "action-2" get call-responder
] unit-test
