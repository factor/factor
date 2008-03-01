USING: http.server tools.test kernel namespaces accessors
new-slots assocs.lib io http math sequences ;
IN: temporary

TUPLE: mock-responder ;

: <mock-responder> ( path -- responder )
    <responder> mock-responder construct-delegate ;

M: mock-responder do-responder
    2nip
    path>> on
    [ "Hello world" print ]
    "text/plain" <content> ;

: check-dispatch ( tag path -- ? )
    over off
    <request> swap default-host get call-responder
    write-response call get ;

[
    "" <dispatcher>
        "foo" <mock-responder> add-responder
        "bar" <mock-responder> add-responder
        "baz/" <dispatcher>
            "123" <mock-responder> add-responder
            "default" <mock-responder> >>default
        add-responder
    default-host set

    [ t ] [ "foo" "foo" check-dispatch ] unit-test
    [ f ] [ "foo" "bar" check-dispatch ] unit-test
    [ t ] [ "bar" "bar" check-dispatch ] unit-test
    [ t ] [ "default" "baz/xxx" check-dispatch ] unit-test
    [ t ] [ "123" "baz/123" check-dispatch ] unit-test

    [ t ] [
        <request>
        "baz" >>path
        "baz" default-host get call-responder
        dup code>> 300 399 between? >r
        header>> "location" peek-at "baz/" tail? r> and
        nip
    ] unit-test
] with-scope
