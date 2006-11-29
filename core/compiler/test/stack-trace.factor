IN: temporary
USING: errors compiler test namespaces sequences kernel-internals ;

: foo 3 throw 7 ;
: bar foo 4 ;
: baz bar 5 ;
\ baz compile
[ 3 ] [ [ baz ] catch ] unit-test
[ { foo bar baz } ] [
    error-stack-trace get symbolic-stack-trace
    [ second ] map [ ] subset
] unit-test
