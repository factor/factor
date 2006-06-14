IN: temporary
USING: io kernel math namespaces styles test ;

! Make sure everything here works...

[ ">> + <<" ] [
    [
        [
            H{ { highlight t } } [
                H{ } [ "+" write ] with-nesting
            ] with-style
        ] string-out
    ] with-scope
] unit-test
