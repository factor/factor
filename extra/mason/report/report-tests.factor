IN: mason.report.tests
USING: io.files io.files.temp io.directories io.directories.hierarchy kernel
mason.report mason.common mason.config namespaces tools.test xml xml.writer ;

{ 0 0 } [ [ ] with-report ] must-infer-as

: verify-report ( -- )
     [ t ] [ "report" exists? ] unit-test
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

    ] with-temp-directory
] with-variable
