IN: tools.test.tests
USING: continuations debugger io.streams.string kernel namespaces
sequences tools.test tools.test.private prettyprint.config ;

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

! GitHub issue #2053: listener print settings must not affect test files.
{ t 16 } [
    H{
        { number-base 16 }
        { boa-tuples? t }
        { qualified-names? t }
        { nesting-limit 0 }
        { length-limit 1 }
    } [
        [
            [ "resource:basis/tools/test/printer-settings.factor" run-test-file ]
            with-string-writer drop
        ] fake-unit-test empty?
        number-base get
    ] with-variables
] unit-test
