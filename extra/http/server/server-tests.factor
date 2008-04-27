USING: http.server tools.test kernel namespaces accessors
io http math sequences assocs arrays classes words ;
IN: http.server.tests

\ find-responder must-infer

[
    <request>
    "www.apple.com" >>host
    "/xxx/bar" >>path
    { { "a" "b" } } >>query
    request set

    [ ] link-hook set

    [ "http://www.apple.com:80/xxx/bar?a=b" ] [ f f derive-url ] unit-test
    [ "http://www.apple.com:80/xxx/baz?a=b" ] [ "baz" f derive-url ] unit-test
    [ "http://www.apple.com:80/xxx/baz?c=d" ] [ "baz" { { "c" "d" } } derive-url ] unit-test
    [ "http://www.apple.com:80/xxx/bar?c=d" ] [ f { { "c" "d" } } derive-url ] unit-test
    [ "http://www.apple.com:80/flip?a=b" ] [ "/flip" f derive-url ] unit-test
    [ "http://www.apple.com:80/flip?c=d" ] [ "/flip" { { "c" "d" } } derive-url ] unit-test
    [ "http://www.jedit.org" ] [ "http://www.jedit.org" f derive-url ] unit-test
    [ "http://www.jedit.org?a=b" ] [ "http://www.jedit.org" { { "a" "b" } } derive-url ] unit-test
] with-scope

TUPLE: mock-responder path ;

C: <mock-responder> mock-responder

M: mock-responder call-responder*
    nip
    path>> on
    "text/plain" <content> ;

: check-dispatch ( tag path -- ? )
    H{ } clone base-paths set
    over off
    split-path
    main-responder get call-responder
    write-response get ;

[
    <dispatcher>
        "foo" <mock-responder> "foo" add-responder
        "bar" <mock-responder> "bar" add-responder
        <dispatcher>
            "123" <mock-responder> "123" add-responder
            "default" <mock-responder> >>default
        "baz" add-responder
    main-responder set

    [ "foo" ] [
        { "foo" } main-responder get find-responder path>> nip
    ] unit-test

    [ "bar" ] [
        { "bar" } main-responder get find-responder path>> nip
    ] unit-test

    [ t ] [ "foo" "foo" check-dispatch ] unit-test
    [ f ] [ "foo" "bar" check-dispatch ] unit-test
    [ t ] [ "bar" "bar" check-dispatch ] unit-test
    [ t ] [ "default" "baz/xxx" check-dispatch ] unit-test
    [ t ] [ "default" "baz/xxx//" check-dispatch ] unit-test
    [ t ] [ "default" "/baz/xxx//" check-dispatch ] unit-test
    [ t ] [ "123" "baz/123" check-dispatch ] unit-test
    [ t ] [ "123" "baz///123" check-dispatch ] unit-test

] with-scope

[
    <dispatcher>
        "default" <mock-responder> >>default
    main-responder set

    [ "/default" ] [ "/default" main-responder get find-responder drop ] unit-test
] with-scope

! Make sure path for default responder isn't chopped
TUPLE: path-check-responder ;

C: <path-check-responder> path-check-responder

M: path-check-responder call-responder*
    drop
    "text/plain" <content> swap >array >>body ;

[ { "c" } ] [
    H{ } clone base-paths set

    { "b" "c" }
    <dispatcher>
        <dispatcher>
            <path-check-responder> >>default
        "b" add-responder
    call-responder
    body>>
] unit-test

! Test that "" dispatcher works with default>>
[ ] [
    <dispatcher>
        "" <mock-responder> "" add-responder
        "bar" <mock-responder> "bar" add-responder
        "baz" <mock-responder> >>default
    main-responder set

    [ t ] [ "" "" check-dispatch ] unit-test
    [ f ] [ "" "quux" check-dispatch ] unit-test
    [ t ] [ "baz" "quux" check-dispatch ] unit-test
    [ f ] [ "foo" "bar" check-dispatch ] unit-test
    [ t ] [ "bar" "bar" check-dispatch ] unit-test
    [ t ] [ "baz" "xxx" check-dispatch ] unit-test
] unit-test

TUPLE: funny-dispatcher < dispatcher ;

: <funny-dispatcher> funny-dispatcher new-dispatcher ;

TUPLE: base-path-check-responder ;

C: <base-path-check-responder> base-path-check-responder

M: base-path-check-responder call-responder*
    2drop
    "$funny-dispatcher" resolve-base-path
    "text/plain" <content> swap >>body ;

[ ] [
    <dispatcher>
        <dispatcher>
            <funny-dispatcher>
                <base-path-check-responder> "c" add-responder
            "b" add-responder
        "a" add-responder
    main-responder set
] unit-test

[ "/a/b/" ] [
    "a/b/c" split-path main-responder get call-responder body>>
] unit-test
