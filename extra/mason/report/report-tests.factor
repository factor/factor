USING: io.directories io.encodings.utf8 io.files io.files.temp kernel
mason.common mason.config mason.report math.parser namespaces
sequences splitting strings tools.test xml xml.writer ;
IN: mason.report.tests

{ 0 0 } [ [ ] with-report ] must-infer-as

! Exercise empty, short, exact-capacity, and long tails from disk.
{ t } [
    [
        { 0 2 400 10000 } [
            <iota> [ number>string ] map
            dup "tail-log" utf8 set-file-lines
            400 index-or-length tail* join-lines
            "tail-log" file-tail =
        ] all?
        "tail-log" delete-file
    ] with-temp-directory
] unit-test

! An oversized line must not be read in full or hide the following crash.
{ t } [
    [
        100000 CHAR: x <string> "\nfatal_error: huge log\n" append
        "tail-log" utf8 set-file-contents
        "tail-log" file-tail
        "... (earlier log bytes omitted) ...\nfatal_error: huge log" =
        "tail-log" delete-file
    ] with-temp-directory
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
            20 "  Datastack: ..." <repetition> append
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
