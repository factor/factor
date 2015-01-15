USING: accessors combinators.short-circuit compiler continuations
continuations.private fry generic generic.hook grouping io.backend
io.encodings.utf8 io.files io.files.temp kernel kernel.private math namespaces
parser sequences sorting splitting tools.test vocabs words ;
IN: compiler.tests.stack-trace

: symbolic-stack-trace ( -- newseq )
    error-continuation get call>> callstack>array
    3 group flip first ;

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

! #1265: Checks that the quotation index never is f (it's -1 instead).
{ f } [
    [ normalize-path ] ignore-errors error-continuation get
    call>> callstack>array [ f = ] any?
] unit-test

! Crashes factor if compiled in debug mode.
[ ] [
    "USING: continuations io.backend ; [ normalize-path ] ignore-errors f"
    "weird.factor" temp-file [ utf8 set-file-contents ] keep run-file
] unit-test
