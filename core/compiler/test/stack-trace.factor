IN: temporary
USING: errors compiler test namespaces sequences
kernel-internals kernel math ;

: nice-stack-trace
    error-stack-trace get symbolic-stack-trace [ second ] map ;

: foo 3 throw 7 ;
: bar foo 4 ;
: baz bar 5 ;
\ baz compile
[ 3 ] [ [ baz ] catch ] unit-test
[ { foo bar baz } ] [ nice-stack-trace ] unit-test

: bleh [ 3 + ] map [ 0 > ] subset ;
\ bleh compile

: stack-trace-contains? nice-stack-trace memq? ;
    
[ t ] [
    [ { 1 "hi" } bleh ] catch drop \ + stack-trace-contains?
] unit-test
    
[ f t ] [
    [ { C{ 1 2 } } bleh ] catch drop
    \ + stack-trace-contains?
    \ > stack-trace-contains?
] unit-test
