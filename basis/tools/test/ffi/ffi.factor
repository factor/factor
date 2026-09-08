USING: environment io kernel math namespaces prettyprint system ;
IN: tools.test.ffi

SYMBOL: general-abi-cases
SYMBOL: small-abi-cases

: general-abi-case ( -- ) general-abi-cases [ 1 + ] change-global ;
: small-abi-case ( -- ) small-abi-cases [ 1 + ] change-global ;
: required-small-floats? ( -- ? ) "FACTOR_REQUIRE_SMALL_FLOATS" os-env "1" = ;
: report-ffi-coverage ( group count -- )
    "FFI-COVERAGE " write swap write " executed=" write . flush ;
