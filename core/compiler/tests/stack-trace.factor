IN: compiler.tests
USING: compiler tools.test namespaces sequences
kernel.private kernel math continuations continuations.private
words splitting grouping sorting ;

: symbolic-stack-trace ( -- newseq )
    error-continuation get continuation-call callstack>array
    2 group flip first ;

: foo ( -- * ) 3 throw 7 ;
: bar ( -- * ) foo 4 ;
: baz ( -- * ) bar 5 ;
[ baz ] [ 3 = ] must-fail-with
[ t ] [
    symbolic-stack-trace
    [ word? ] filter
    { baz bar foo throw } tail?
] unit-test

: bleh ( seq -- seq' ) [ 3 + ] map [ 0 > ] filter ;

: stack-trace-contains? ( word -- ? ) symbolic-stack-trace memq? ;

[ t ] [
    [ { 1 "hi" } bleh ] ignore-errors \ + stack-trace-contains?
] unit-test
    
[ t f ] [
    [ { "hi" } bleh ] ignore-errors
    \ + stack-trace-contains?
    \ > stack-trace-contains?
] unit-test

: quux ( -- seq ) { 1 2 3 } [ "hi" throw ] sort ;

[ t ] [
    [ 10 quux ] ignore-errors
    \ sort stack-trace-contains?
] unit-test
