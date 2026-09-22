USING: combinators io.directories io.encodings.utf8 io.files io.files.temp kernel
mason.common mason.config mason.report math.parser namespaces
sequences splitting tools.test xml xml.writer ;
IN: mason.report.tests

{ 0 0 } [ [ ] with-report ] must-infer-as

{ "" } [ { } failure-excerpt ] unit-test
{ "one\ntwo" } [ { "one" "two" } failure-excerpt ] unit-test

{ t t f } [
    "fatal_error: Double fault: 0x1234" crash-line?
    "critical_error: bad pointer" crash-line?
    "Unit Test: { \"fatal_error: expected\" }" crash-line?
] unit-test

{ t } [
    500 <iota> [ number>string ] map
    dup 400 tail* join-lines swap failure-excerpt =
] unit-test

! Reproduce a fatal error buried by hundreds of context-stack lines.
{ t t t t } [
    { "Loading failing-tests.factor" "Unit Test: crash" "fatal_error: Double fault" }
    1000 "  Datastack: ..." <repetition> append
    { "last log line" } append failure-excerpt split-lines
    {
        [ "Loading failing-tests.factor" swap member? ]
        [ "Unit Test: crash" swap member? ]
        [ "fatal_error: Double fault" swap member? ]
        [ last "last log line" = ]
    } cleave
] unit-test

! A crash already in the tail should not duplicate any output.
{ t } [
    450 "context" <repetition>
    { "fatal_error: Double fault" "last log line" } append
    dup 400 tail* join-lines swap failure-excerpt =
] unit-test

! Adjacent context and tail windows should join without an omission marker.
{ t } [
    { "fatal_error: Double fault" } 400 "context" <repetition> append
    dup join-lines swap failure-excerpt =
] unit-test

{ t } [
    { "fatal_error: first" }
    200 "context" <repetition> append
    { "fatal_error: second" }
    append 1000 "context" <repetition> append
    failure-excerpt split-lines
    [ "fatal_error: second" swap member? ]
    [ "fatal_error: first" swap member? not ] bi and
] unit-test

: verify-report ( -- )
    [ t ] [ "report" file-exists? ] unit-test
    [ ] [ "report" file>xml drop ] unit-test
    [ ] [ "report" delete-file ] unit-test ;

"builds" temp-file builds-dir [
    [
        "resource:extra/mason/report/fake-data/" "." copy-tree

        [ ] [
            timings-table pprint-xml
        ] unit-test

        [ ] [ successful-report ] unit-test
        verify-report

        [ status-error ] [ 1234 compile-failed ] unit-test
        verify-report

        [ status-error ] [ 1235 boot-failed ] unit-test
        verify-report

        [ status-error ] [ 1236 test-failed ] unit-test
        verify-report

        [ status-error ] [
            { "Mason phase: test-all" "fatal_error: bad <pointer> & data" }
            1000 "  Datastack: ..." <repetition> append
            "test-log" utf8 set-file-lines
            1237 test-failed
        ] unit-test
        { t t } [
            "report" utf8 file-contents
            [ "Mason phase: test-all" subseq-of? ]
            [ "fatal_error: bad &lt;pointer&gt; &amp; data" subseq-of? ] bi
        ] unit-test
        verify-report

    ] with-temp-directory
] with-variable
