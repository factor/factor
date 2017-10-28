IN: core-foundation.arrays.tests
USING: core-foundation core-foundation.arrays
core-foundation.strings destructors sequences tools.test ;

{ { "1" "2" "3" } } [
    [
        { "1" "2" "3" }
        [ <CFString> &CFRelease ] map
        <CFArray> CFString>string-array
    ] with-destructors
] unit-test
