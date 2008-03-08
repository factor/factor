IN: http.server.sessions.tests
USING: tools.test http.server.sessions math namespaces
kernel accessors ;

: with-session \ session swap with-variable ; inline

TUPLE: foo ;

C: <foo> foo

M: foo init-session drop 0 "x" sset ;

"1234" f <session> [
    [ ] [ 3 "x" sset ] unit-test
    
    [ 9 ] [ "x" sget sq ] unit-test
    
    [ ] [ "x" [ 1- ] schange ] unit-test
    
    [ 4 ] [ "x" sget sq ] unit-test
] with-session

[ t ] [ f <url-sessions> url-sessions? ] unit-test
[ t ] [ f <cookie-sessions> cookie-sessions? ] unit-test

[ ] [
    <foo> <url-sessions>
    "manager" set
] unit-test

[ { 5 0 } ] [
    [
        "manager" get new-session
        dup "manager" get get-session [ 5 "a" sset ] with-session
        dup "manager" get get-session [ "a" sget , ] with-session
        dup "manager" get get-session [ "x" sget , ] with-session
        "manager" get get-session delete-session
    ] { } make
] unit-test
