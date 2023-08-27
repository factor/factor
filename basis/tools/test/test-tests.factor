IN: tools.test.tests
USING: continuations debugger io.streams.string kernel namespaces
sequences tools.test tools.test.private ;

{ 1 } [
    [
        [ "OOPS" ] must-fail
    ] fake-unit-test length
] unit-test

: create-test-failure ( -- error )
    [ "hello" throw ] [
        f "path" 25 error-continuation get test-failure boa
    ] recover ;

! Just verifies that the presented output contains a callstack.
{ t } [
    create-test-failure [ error. ] with-string-writer
    "OBJ-CURRENT-THREAD" subseq-of?
] unit-test
