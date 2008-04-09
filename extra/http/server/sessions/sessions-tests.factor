IN: http.server.sessions.tests
USING: tools.test http http.server.sessions
http.server.sessions.storage http.server.sessions.storage.assoc
http.server.actions http.server math namespaces kernel accessors
prettyprint io.streams.string splitting destructors sequences ;

[ H{ } ] [ H{ } add-session-id ] unit-test

: with-session \ session swap with-variable ; inline

TUPLE: foo ;

C: <foo> foo

M: foo init-session* drop 0 "x" sset ;

M: foo call-responder
    2drop
    "x" [ 1+ ] schange
    "text/html" <content> [ "x" sget pprint ] >>body ;

[
    "123" session-id set
    H{ } clone session set
    session-changed? off

    [ H{ { "factorsessid" "123" } } ] [ H{ } add-session-id ] unit-test

    [ ] [ 3 "x" sset ] unit-test
    
    [ 9 ] [ "x" sget sq ] unit-test
    
    [ ] [ "x" [ 1- ] schange ] unit-test
    
    [ 4 ] [ "x" sget sq ] unit-test

    [ t ] [ session-changed? get ] unit-test
] with-scope

[ t ] [ f <url-sessions> url-sessions? ] unit-test
[ t ] [ f <cookie-sessions> cookie-sessions? ] unit-test

[ ] [
    <foo> <url-sessions>
        <sessions-in-memory> >>sessions
    "manager" set
] unit-test

[ { 5 0 } ] [
    [
        "manager" get begin-session drop
        dup "manager" get sessions>> get-session [ 5 "a" sset ] with-session
        dup "manager" get sessions>> get-session [ "a" sget , ] with-session
        dup "manager" get sessions>> get-session [ "x" sget , ] with-session
        "manager" get sessions>> get-session
        "manager" get sessions>> delete-session
    ] { } make
] unit-test

[ ] [
    <request>
        "GET" >>method
    request set
    "/etc" "manager" get call-responder
    response set
] unit-test

[ 307 ] [ response get code>> ] unit-test

[ ] [ response get "location" header "=" split1 nip "id" set ] unit-test

: url-responder-mock-test
    [
        <request>
            "GET" >>method
            "id" get session-id-key set-query-param
            "/" >>path
        request set
        "/" "manager" get call-responder
        [ write-response-body drop ] with-string-writer
    ] with-destructors ;

[ "1" ] [ url-responder-mock-test ] unit-test
[ "2" ] [ url-responder-mock-test ] unit-test
[ "3" ] [ url-responder-mock-test ] unit-test
[ "4" ] [ url-responder-mock-test ] unit-test

[ ] [
    <foo> <cookie-sessions>
        <sessions-in-memory> >>sessions
    "manager" set
] unit-test

[
    <request>
    "GET" >>method
    "/" >>path
    request set
    "/etc" "manager" get call-responder response set
    [ "1" ] [ [ response get write-response-body drop ] with-string-writer ] unit-test
    response get
] with-destructors
response set

[ ] [ response get cookies>> "cookies" set ] unit-test

: cookie-responder-mock-test
    [
        <request>
            "GET" >>method
            "cookies" get >>cookies
            "/" >>path
        request set
        "/" "manager" get call-responder
        [ write-response-body drop ] with-string-writer
    ] with-destructors ;

[ "2" ] [ cookie-responder-mock-test ] unit-test
[ "3" ] [ cookie-responder-mock-test ] unit-test
[ "4" ] [ cookie-responder-mock-test ] unit-test

: <exiting-action>
    <action>
        [
            "text/plain" <content> exit-with
        ] >>display ;

[
    [ ] [
        <request>
            "GET" >>method
            "id" get session-id-key set-query-param
            "/" >>path
        request set

        [
            "/" <exiting-action> <cookie-sessions>
            call-responder
        ] with-destructors response set
    ] unit-test

    [ "text/plain" ] [ response get "content-type" header ] unit-test

    [ f ] [ response get cookies>> empty? ] unit-test
] with-scope
