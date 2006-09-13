IN: temporary
USING: test namespaces furnace ;

: foo ;

\ foo { { "foo" "2" } { "bar" f } } define-action

[
    { "2" "hello" }
] [
    [
        H{
            { "bar" "hello" }
        } "query" set

        \ foo query>quot
    ] with-scope
] unit-test

[
    H{ { "foo" "1" } { "bar" "2" } }
] [
    { "1" "2" } \ foo quot>query
] unit-test

[
    "/responder/bar/foo?foo=3"
] [
    [
        "bar" "responder" set
        [ "3" foo ] quot-link
    ] with-scope
] unit-test
