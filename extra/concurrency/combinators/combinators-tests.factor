IN: concurrency.combinators.tests
USING: concurrency.combinators tools.test random kernel math 
concurrency.mailboxes threads sequences accessors ;

[ [ drop ] parallel-each ] must-infer
[ [ ] parallel-map ] must-infer
[ [ ] parallel-subset ] must-infer

[ { 1 4 9 } ] [ { 1 2 3 } [ sq ] parallel-map ] unit-test

[ { 1 4 9 } ] [ { 1 2 3 } [ 1000 random sleep sq ] parallel-map ] unit-test

[ { 1 2 3 } [ dup 2 mod 0 = [ "Even" throw ] when ] parallel-map ]
[ error>> "Even" = ] must-fail-with

[ V{ 0 3 6 9 } ]
[ 10 [ 3 mod zero? ] parallel-subset ] unit-test

[ 10 ]
[
    V{ } clone
    10 over [ push ] curry parallel-each
    length
] unit-test
