USING: accessors effects eval kernel layouts math quotations tools.test typed words ;
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

TUPLE: unboxable
    { x fixnum read-only }
    { y fixnum read-only } ;

TUPLE: unboxable2
    { u unboxable read-only }
    { xy fixnum read-only } ;

TYPED: unboxy ( in: unboxable -- out: unboxable2 )
    dup [ x>> ] [ y>> ] bi - unboxable2 boa ;

[ (( in: fixnum in: fixnum -- out: fixnum out: fixnum out: fixnum )) ]
[ \ unboxy "typed-word" word-prop stack-effect ] unit-test

[ T{ unboxable2 { u T{ unboxable { x 12 } { y 3 } } } { xy 9 } } ]
[ T{ unboxable { x 12 } { y 3 } } unboxy ] unit-test

[ 9 ]
[
"""
USING: kernel math ;
IN: typed.tests

TUPLE: unboxable
    { x fixnum read-only }
    { y fixnum read-only }
    { z float read-only } ;
""" eval( -- )

"""
USING: accessors kernel math ;
IN: typed.tests
T{ unboxable f 12 3 4.0 } unboxy xy>>
""" eval( -- xy )
] unit-test
