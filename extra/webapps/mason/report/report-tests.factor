USING: accessors stack-checker tools.test webapps.mason.report ;
IN: webapps.mason.report.tests

! <build-report-action>
{ ( -- x ) } [
    <build-report-action> display>> infer
] unit-test
