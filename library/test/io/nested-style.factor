IN: temporary
USING: io kernel math namespaces styles test ;

[ ">> + <<" ] [
    [
        [
            H{ { highlight t } } [
                H{ } [ "+" write ] with-nesting
            ] with-style
        ] string-out
    ] with-scope
] unit-test

[ "+" ] [
    [
        [
            H{ } [
                H{ { highlight t } } [ "+" write ] with-nesting
            ] with-style
        ] string-out
    ] with-scope
] unit-test
