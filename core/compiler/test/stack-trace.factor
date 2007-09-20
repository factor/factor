IN: temporary
USING: compiler tools.test namespaces sequences
kernel.private kernel math continuations continuations.private
words ;

: symbolic-stack-trace ( -- newseq )
    error-continuation get continuation-call callstack>array ;

: foo 3 throw 7 ;
: bar foo 4 ;
: baz bar 5 ;
\ baz compile
[ 3 ] [ [ baz ] catch ] unit-test
[ { baz bar foo throw } ] [
    symbolic-stack-trace [ word? ] subset
] unit-test

: bleh [ 3 + ] map [ 0 > ] subset ;
\ bleh compile

: stack-trace-contains? symbolic-stack-trace memq? ;
    
[ t ] [
    [ { 1 "hi" } bleh ] catch drop \ + stack-trace-contains?
] unit-test
    
[ f t ] [
    [ { C{ 1 2 } } bleh ] catch drop
    \ + stack-trace-contains?
    \ > stack-trace-contains?
] unit-test

: quux [ t [ "hi" throw ] when ] times ;
\ quux compile

[ t ] [
    [ 10 quux ] catch drop
    \ (each-integer) stack-trace-contains?
] unit-test
