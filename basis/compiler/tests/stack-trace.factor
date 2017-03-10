USING: accessors combinators continuations grouping io.backend
io.encodings.utf8 io.files kernel math namespaces parser
sequences tools.test ;
IN: compiler.tests.stack-trace

: symbolic-stack-trace ( -- newseq )
    error-continuation get call>> callstack>array
    3 group flip first ;

: foo ( -- * ) 3 throw 7 ;
: bar ( -- * ) foo 4 ;
: baz ( -- * ) bar 5 ;
[ baz ] [ 3 = ] must-fail-with
{
    { foo bar baz }
} [
    2 5 symbolic-stack-trace subseq
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

! #1265: Checks that the quotation index never is f (it's -1 instead).
{ f } [
    [ normalize-path ] ignore-errors error-continuation get
    call>> callstack>array [ f = ] any?
] unit-test

! #1265: Used to crash factor if compiled in debug mode.
[
    [
        "USING: continuations io.backend ; [ normalize-path ] ignore-errors f"
        swap [ utf8 set-file-contents ] keep run-file
    ] with-test-file
] [ wrong-values? ] must-fail-with
