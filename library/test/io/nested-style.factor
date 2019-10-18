IN: temporary
USING: io kernel math namespaces styles test ;

[ "A" ] [
    [
        [
            H{ { highlight t } } [
                H{ } [ "a" write ] with-nesting
            ] with-style
        ] string-out
    ] with-scope
] unit-test

[ "a" ] [
    [
        [
            H{ } [
                H{ { highlight t } } [ "a" write ] with-nesting
            ] with-style
        ] string-out
    ] with-scope
] unit-test
