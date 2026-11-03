USING: accessors arrays backoff continuations kernel locals math
math.order sequences tools.test vectors ;
IN: backoff.tests

{ { 25 25 25 } } [
    25 <constant-backoff> <backoff>
    [ next-backoff ] curry 3 swap replicate
] unit-test

{ { 10 15 20 22 22 } } [
    10 22 5 <linear-backoff> <backoff>
    [ next-backoff ] curry 5 swap replicate
] unit-test

{ { 100.0 200.0 400.0 800.0 1600.0 3200.0 6400.0 10000 10000 } } [
    <default-backoff> <backoff>
    [ next-backoff ] curry 9 swap replicate
] unit-test

{ 10000 } [ 1000000000 <default-backoff> backoff-delay ] unit-test
{ 10 } [ 100 10 20 1 f <exponential-backoff> backoff-delay ] unit-test
{ 0 } [ 100 0 20 2 f <exponential-backoff> backoff-delay ] unit-test
{ 5 } [ 0 10 5 2 f <exponential-backoff> backoff-delay ] unit-test

{ 0 100.0 } [
    <default-backoff> <backoff>
    dup next-backoff drop dup reset-backoff
    [ attempts>> ] [ next-backoff ] bi
] unit-test

{ t } [
    1000 [ 8 100 1000 2 t <exponential-backoff> backoff-delay
        100 1000 between? ] replicate [ ] all?
] unit-test

{ 42 } [ [ 42 ] <default-backoff> 0 retry-backoff ] unit-test
{ f } [ [ f ] <default-backoff> 0 retry-backoff ] unit-test

:: retry-test ( -- result delays calls )
    0 :> calls!
    V{ } clone :> delays
    [ calls 1 + calls! calls 3 < [ "transient" throw ] [ 42 ] if ]
    [ "transient" = ] [ delays push ]
    10 100 2 f <exponential-backoff> 3 retry-backoff-with
    delays >array calls ;

{ 42 { 10.0 20.0 } 3 } [ retry-test ] unit-test

:: exhausted-test ( -- error calls delays )
    0 :> calls!
    V{ } clone :> delays
    [
        [ calls 1 + calls! "last-error" throw ]
        [ drop t ] [ delays push ] 0 <constant-backoff> 2
        retry-backoff-with
    ] [ ] recover
    calls delays >array ;

{ "last-error" 3 { 0 0 } } [ exhausted-test ] unit-test

{ "fatal" } [
    [ [ "fatal" throw ] [ drop f ] [ "unexpected-wait" throw ]
        <default-backoff> 5 retry-backoff-with ] [ ] recover
] unit-test

[ [ 1 ] <default-backoff> -1 retry-backoff ]
[ invalid-retry-count? ] must-fail-with

{ "wait-error" } [
    [ [ "operation-error" throw ] [ drop t ]
        [ drop "wait-error" throw ] <default-backoff> 1
        retry-backoff-with ] [ ] recover
] unit-test

{ "predicate-error" } [
    [ [ "operation-error" throw ] [ drop "predicate-error" throw ]
        [ drop ] <default-backoff> 1 retry-backoff-with ] [ ] recover
] unit-test

{ 0 } [
    <default-backoff> dup <backoff> next-backoff drop
    <backoff> attempts>>
] unit-test

[ [ 1 ] <default-backoff> 1/2 retry-backoff ]
[ invalid-retry-count? ] must-fail-with
