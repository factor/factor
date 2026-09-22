USING: continuations kernel namespaces prettyprint.config tools.test ;
IN: prettyprint.config.tests

! Restore caller settings even when code run with defaults throws.
{ 10 16 } [
    16 number-base [
        [ [ number-base get throw ] with-default-pprint-config ] [ ] recover
        number-base get
    ] with-variable
] unit-test
