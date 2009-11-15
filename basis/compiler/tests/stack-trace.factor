USING: compiler tools.test namespaces sequences
kernel.private kernel math continuations continuations.private
words splitting grouping sorting accessors ;
IN: compiler.tests.stack-trace

: symbolic-stack-trace ( -- newseq )
    error-continuation get call>> callstack>array
    2 group flip first ;

: foo ( -- * ) 3 throw 7 ;
: bar ( -- * ) foo 4 ;
: baz ( -- * ) bar 5 ;
[ baz ] [ 3 = ] must-fail-with
[ t ] [
    symbolic-stack-trace
    2 head*
    { baz bar foo } tail?
] unit-test

: bleh ( seq -- seq' ) [ 3 + ] map [ 0 > ] filter ;

: stack-trace-any? ( word -- ? ) symbolic-stack-trace member-eq? ;

[ t ] [
    [ { 1 "hi" } bleh ] ignore-errors \ + stack-trace-any?
] unit-test

[ t f ] [
    [ { "hi" } bleh ] ignore-errors
    \ + stack-trace-any?
    \ > stack-trace-any?
] unit-test
