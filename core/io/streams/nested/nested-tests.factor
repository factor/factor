USING: io io.streams.string io.streams.nested kernel math
namespaces io.styles tools.test ;
IN: temporary

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
