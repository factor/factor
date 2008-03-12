USING: http.server tools.test kernel namespaces accessors
new-slots io http math sequences assocs ;
IN: http.server.tests

[
    <request>
    "www.apple.com" >>host
    "/xxx/bar" >>path
    { { "a" "b" } } >>query
    request set

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

M: mock-responder call-responder
    nip
    path>> on
    "text/plain" <content> ;

: check-dispatch ( tag path -- ? )
    over off
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
        "foo" main-responder get find-responder path>> nip
    ] unit-test

    [ "bar" ] [
        "bar" main-responder get find-responder path>> nip
    ] unit-test

    [ t ] [ "foo" "foo" check-dispatch ] unit-test
    [ f ] [ "foo" "bar" check-dispatch ] unit-test
    [ t ] [ "bar" "bar" check-dispatch ] unit-test
    [ t ] [ "default" "baz/xxx" check-dispatch ] unit-test
    [ t ] [ "default" "baz/xxx//" check-dispatch ] unit-test
    [ t ] [ "default" "/baz/xxx//" check-dispatch ] unit-test
    [ t ] [ "123" "baz/123" check-dispatch ] unit-test
    [ t ] [ "123" "baz///123" check-dispatch ] unit-test

    [ t ] [
        <request>
        "baz" >>path
        request set
        "baz" main-responder get call-responder
        dup code>> 300 399 between? >r
        header>> "location" swap at "baz/" tail? r> and
    ] unit-test
] with-scope

[
    <dispatcher>
        "default" <mock-responder> >>default
    main-responder set

    [ "/default" ] [ "/default" main-responder get find-responder drop ] unit-test
] with-scope
