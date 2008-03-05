IN: http.server.actions.tests
USING: http.server.actions tools.test math math.parser
multiline namespaces http io.streams.string http.server
sequences ;

[ + ]
{ { "a" [ string>number ] } { "b" [ string>number ] } }
"GET" <action> "action-1" set

STRING: action-request-test-1
GET http://foo/bar?a=12&b=13 HTTP/1.1

blah
;

[ 25 ] [
    action-request-test-1 [ read-request ] with-string-reader
    "/blah"
    "action-1" get call-responder
] unit-test

[ "X" <repetition> concat append ]
{ { +path+ [ ] } { "xxx" [ string>number ] } }
"POST" <action> "action-2" set

STRING: action-request-test-2
POST http://foo/bar/baz HTTP/1.1
content-length: 5

xxx=4
;

[ "/blahXXXX" ] [
    action-request-test-2 [ read-request ] with-string-reader
    "/blah"
    "action-2" get call-responder
] unit-test
