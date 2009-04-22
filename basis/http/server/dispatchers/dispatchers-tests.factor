USING: http.server http.server.dispatchers http.server.responses
tools.test kernel namespaces accessors io http math sequences
assocs arrays classes words urls ;
IN: http.server.dispatchers.tests

TUPLE: mock-responder path ;

C: <mock-responder> mock-responder

M: mock-responder call-responder*
    nip
    path>> on
    [ ] "text/plain" <content> ;

: check-dispatch ( tag path -- ? )
    V{ } clone responder-nesting set
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
    >array "text/plain" <content> ;

[ { "c" } ] [
    V{ } clone responder-nesting set

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
