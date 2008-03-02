IN: compiler.tests
USING: compiler tools.test namespaces sequences
kernel.private kernel math continuations continuations.private
words splitting sorting ;

: symbolic-stack-trace ( -- newseq )
    error-continuation get continuation-call callstack>array
    2 group flip first ;

: foo 3 throw 7 ;
: bar foo 4 ;
: baz bar 5 ;
[ baz ] [ 3 = ] must-fail-with
[ t ] [
    symbolic-stack-trace
    [ word? ] subset
    { baz bar foo throw } tail?
] unit-test

: bleh [ 3 + ] map [ 0 > ] subset ;

: stack-trace-contains? symbolic-stack-trace memq? ;

[ t ] [
    [ { 1 "hi" } bleh ] ignore-errors \ + stack-trace-contains?
] unit-test
    
[ t f ] [
    [ { "hi" } bleh ] ignore-errors
    \ + stack-trace-contains?
    \ > stack-trace-contains?
] unit-test

: quux { 1 2 3 } [ "hi" throw ] sort ;

[ t ] [
    [ 10 quux ] ignore-errors
    \ sort stack-trace-contains?
] unit-test
