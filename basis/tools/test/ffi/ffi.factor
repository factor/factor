USING: environment io kernel math namespaces prettyprint tools.test ;
IN: tools.test.ffi

SYMBOL: general-abi-cases
SYMBOL: small-abi-cases
SYMBOL: ffi-report?

: general-abi-case ( -- ) general-abi-cases [ 1 + ] change-global ;
: small-abi-case ( -- ) small-abi-cases [ 1 + ] change-global ;
: required-small-floats? ( -- ? ) "FACTOR_REQUIRE_SMALL_FLOATS" os-env "1" = ;
: ffi-report-enabled? ( -- ? )
    silent-tests? get not
    ffi-report? get "FACTOR_FFI_REPORT" os-env "1" = or and ;
: report-ffi-coverage ( group count -- )
    ffi-report-enabled? [
        "FFI-COVERAGE " write swap write " executed=" write . flush
    ] [ 2drop ] if ;

: report-ffi-skip ( group reason -- )
    ffi-report-enabled? [
        "FFI-SKIP " write swap write " reason=" write print flush
    ] [ 2drop ] if ;
