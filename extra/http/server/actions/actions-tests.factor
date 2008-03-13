IN: http.server.actions.tests
USING: http.server.actions tools.test math math.parser
multiline namespaces http io.streams.string http.server
sequences accessors ;

<action>
    [ "a" get "b" get + ] >>display
    { { "a" [ string>number ] } { "b" [ string>number ] } } >>get-params
"action-1" set

STRING: action-request-test-1
GET http://foo/bar?a=12&b=13 HTTP/1.1

blah
;

[ 25 ] [
    action-request-test-1 [ read-request ] with-string-reader
    request set
    "/blah"
    "action-1" get call-responder
] unit-test

<action>
    [ +path+ get "xxx" get "X" <repetition> concat append ] >>submit
    { { +path+ [ ] } { "xxx" [ string>number ] } } >>post-params
"action-2" set

STRING: action-request-test-2
POST http://foo/bar/baz HTTP/1.1
content-length: 5

xxx=4
;

[ "/blahXXXX" ] [
    action-request-test-2 [ read-request ] with-string-reader
    request set
    "/blah"
    "action-2" get call-responder
] unit-test
