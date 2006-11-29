IN: temporary
USING: test namespaces furnace math kernel sequences ;

[
    123 f
] [
    H{ { "foo" "123" } } { "foo" v-number } action-param
] unit-test

: validation-fails
    [ action-param nip not ] append [ f ] swap unit-test ;

[ H{ { "foo" "12X3" } } { "foo" v-number } ] validation-fails

[ H{ { "foo" "" } } { "foo" 4 v-min-length } ] validation-fails

[ "ABCD" f ]
[ H{ { "foo" "ABCD" } } { "foo" 4 v-min-length } action-param ]
unit-test

[ H{ { "foo" "ABCD" } } { "foo" 2 v-max-length } ]
validation-fails

[ "AB" f ]
[ H{ { "foo" "AB" } } { "foo" 2 v-max-length } action-param ]
unit-test

[ "AB" f ]
[ H{ { "foo" f } } { "foo" "AB" v-default } action-param ]
unit-test
