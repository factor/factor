IN: tools.test.tests
USING: tools.test tools.test.private namespaces kernel sequences ;

\ test-all must-infer

: fake-unit-test ( quot -- )
    [
        "fake" file set
        V{ } clone test-failures set
        call
        test-failures get
    ] with-scope ; inline

[ 1 ] [
    [
        [ "OOPS" ] must-fail
    ] fake-unit-test length
] unit-test