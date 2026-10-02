USING: environment io.streams.string kernel namespaces tools.test
tools.test.ffi ;
IN: tools.test.ffi.tests

: sample-ffi-report ( -- )
    "small" 0 report-ffi-coverage
    "small" "unsupported-toolchain-or-cpu" report-ffi-skip ;

! Ordinary runs are quiet, but explicit diagnostics preserve their format.
{ "" } [
    "0" "FACTOR_FFI_REPORT" [
        f ffi-report? [ f silent-tests? [
            [ sample-ffi-report ] with-string-writer
        ] with-variable ] with-variable
    ] with-os-env
] unit-test

{ "FFI-COVERAGE small executed=0\nFFI-SKIP small reason=unsupported-toolchain-or-cpu\n" } [
    "0" "FACTOR_FFI_REPORT" [
        t ffi-report? [ f silent-tests? [
            [ sample-ffi-report ] with-string-writer
        ] with-variable ] with-variable
    ] with-os-env
] unit-test

{ "FFI-COVERAGE small executed=0\nFFI-SKIP small reason=unsupported-toolchain-or-cpu\n" } [
    "1" "FACTOR_FFI_REPORT" [
        f ffi-report? [ f silent-tests? [
            [ sample-ffi-report ] with-string-writer
        ] with-variable ] with-variable
    ] with-os-env
] unit-test

! Silent test runs override both explicit diagnostic switches.
{ "" } [
    "1" "FACTOR_FFI_REPORT" [
        t ffi-report? [ t silent-tests? [
            [ sample-ffi-report ] with-string-writer
        ] with-variable ] with-variable
    ] with-os-env
] unit-test
