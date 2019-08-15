USING: arrays compiler.units math math.intervals.predicates
math.intervals.predicates.private math.intervals sequences tools.test words ;

IN: math.intervals.predicates.tests

{ t } [
    -42 666 [a,b]
    empty-interval
    full-interval
    [-inf,inf] 4array
    [ valid-interval? ] all?
] unit-test

{ f } [ "foo" valid-interval? ] unit-test

{ T{ interval { from { 0 t } } { to { 5 t } } } } [
    [ 0 5 [a,b] ] evaluate-interval
] unit-test

[ [ 1 2 3 ] evaluate-interval ] [ invalid-interval-definition? ] must-fail-with
[ [ 0 [-inf,inf] ] evaluate-interval ] [ invalid-interval-definition? ] must-fail-with


SYMBOL: test-class

{ T{ interval { from { 0 f } } { to { 5 f } } } } [ [
        test-class fixnum 0 5 (a,b) define-interval-predicate-class
    ] with-compilation-unit
        test-class "declared-interval" word-prop
] unit-test

INTERVAL-PREDICATE: test-natural < fixnum 0 [a,inf] ;

{ t } [ 0 test-natural? ] unit-test
{ f } [ -1 test-natural? ] unit-test
{ t } [ 5 test-natural? ] unit-test
{ f } [ 5.1 test-natural? ] unit-test
