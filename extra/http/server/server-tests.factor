USING: http.server tools.test kernel namespaces accessors
new-slots io http math sequences assocs ;
IN: http.server.tests

TUPLE: mock-responder path ;

C: <mock-responder> mock-responder

M: mock-responder call-responder
    2nip
    path>> on
    "text/plain" <content> ;

: check-dispatch ( tag path -- ? )
    over off
    <request> swap default-host get call-responder
    write-response get ;

[
    <dispatcher>
        "foo" <mock-responder> "foo" add-responder
        "bar" <mock-responder> "bar" add-responder
        <dispatcher>
            "123" <mock-responder> "123" add-responder
            "default" <mock-responder> >>default
        "baz" add-responder
    default-host set

    [ "foo" ] [
        "foo" default-host get find-responder path>> nip
    ] unit-test

    [ "bar" ] [
        "bar" default-host get find-responder path>> nip
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
        "baz" default-host get call-responder
        dup code>> 300 399 between? >r
        header>> "location" swap at "baz/" tail? r> and
    ] unit-test
] with-scope
