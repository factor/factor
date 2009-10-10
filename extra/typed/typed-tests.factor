USING: kernel layouts math quotations tools.test typed ;
IN: typed.tests

TYPED: f+ ( a: float b: float -- c: float )
    + ;

[ 3.5 ]
[ 2 1+1/2 f+ ] unit-test

TYPED: fix+ ( a: fixnum b: fixnum -- c: fixnum )
    + ;

most-positive-fixnum neg 1 - 1quotation
[ most-positive-fixnum 1 fix+ ] unit-test

TUPLE: tweedle-dee ;
TUPLE: tweedle-dum ;

TYPED: dee ( x: tweedle-dee -- y )
    drop \ tweedle-dee ;

TYPED: dum ( x: tweedle-dum -- y )
    drop \ tweedle-dum ;

[ \ tweedle-dum new dee ] [ input-mismatch-error? ] must-fail-with
[ \ tweedle-dee new dum ] [ input-mismatch-error? ] must-fail-with


TYPED: dumdum ( x -- y: tweedle-dum )
    drop \ tweedle-dee new ;

[ f dumdum ] [ output-mismatch-error? ] must-fail-with

TYPED:: f+locals ( a: float b: float -- c: float )
    a b + ;

[ 3.5 ] [ 2 1+1/2 f+locals ] unit-test
