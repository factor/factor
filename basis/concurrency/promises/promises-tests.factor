USING: vectors concurrency.promises kernel threads sequences
tools.test ;
IN: concurrency.promises.tests

{ V{ 50 50 50 } } [
    0 <vector>
    <promise>
    [ ?promise swap push ] in-thread
    [ ?promise swap push ] in-thread
    [ ?promise swap push ] in-thread
    50 swap fulfill
] unit-test

[ 5 <promise> [ fulfill ] 2keep fulfill ]
[ promise-already-fulfilled? ] must-fail-with

{ f } [ <promise> promise-fulfilled? ] unit-test 
{ t } [
    5 <promise> [ fulfill ] keep promise-fulfilled?
] unit-test 
