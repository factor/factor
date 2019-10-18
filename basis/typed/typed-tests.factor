USING: accessors compiler.units effects eval kernel kernel.private layouts
literals math namespaces quotations tools.test typed words words.symbol
combinators.short-circuit compiler.tree.debugger prettyprint definitions
sequences classes.intersection strings classes.union ;
IN: typed.tests

TYPED: f+ ( a: float b: float -- c: float )
    + ;

{ 3.5 }
[ 2 1+1/2 f+ ] unit-test

TYPED: fix+ ( a: fixnum b: fixnum -- c: fixnum )
    + ;

! XXX: As of .97, we don't require that the output is a fixnum.
! most-positive-fixnum neg 1 - 1quotation
! [ most-positive-fixnum 1 fix+ ] unit-test

! XXX: Check that we throw an error. This used to underflow to the least-positive-fixnum.
[ most-positive-fixnum 1 fix+ ] [ ${ KERNEL-ERROR 7 } head? ] must-fail-with

TUPLE: tweedle-dee ; final
TUPLE: tweedle-dum ; final

TYPED: dee ( x: tweedle-dee -- y )
    drop \ tweedle-dee ;

TYPED: dum ( x: tweedle-dum -- y )
    drop \ tweedle-dum ;

[ \ tweedle-dum new dee ]
[ { [ input-mismatch-error? ] [ expected-type>> tweedle-dee = ] [ value>> tweedle-dum? ] } 1&& ] must-fail-with

[ \ tweedle-dee new dum ]
[ { [ input-mismatch-error? ] [ expected-type>> tweedle-dum = ] [ value>> tweedle-dee? ] } 1&& ] must-fail-with

TYPED: dumdum ( x -- y: tweedle-dum )
    drop \ tweedle-dee new ;

[ f dumdum ]
[ { [ output-mismatch-error? ] [ expected-type>> tweedle-dum = ] [ value>> tweedle-dee? ] } 1&& ] must-fail-with

TYPED:: f+locals ( a: float b: float -- c: float )
    a b + ;

{ 3.5 } [ 2 1+1/2 f+locals ] unit-test

TUPLE: unboxable
    { x fixnum read-only }
    { y fixnum read-only } ; final

TUPLE: unboxable2
    { u unboxable read-only }
    { xy fixnum read-only } ; final

TYPED: unboxy ( in: unboxable -- out: unboxable2 )
    dup [ x>> ] [ y>> ] bi - unboxable2 boa ;

{ ( in: fixnum in: fixnum -- out: fixnum out: fixnum out: fixnum ) }
[ \ unboxy "typed-word" word-prop stack-effect ] unit-test

{ T{ unboxable2 { u T{ unboxable { x 12 } { y 3 } } } { xy 9 } } }
[ T{ unboxable { x 12 } { y 3 } } unboxy ] unit-test

{ 9 }
[
"
USING: kernel math ;
IN: typed.tests

TUPLE: unboxable
    { x fixnum read-only }
    { y fixnum read-only }
    { z float read-only } ; final
" eval( -- )

"
USING: accessors kernel math ;
IN: typed.tests
T{ unboxable f 12 3 4.0 } unboxy xy>>
" eval( -- xy )
] unit-test

TYPED: no-inputs ( -- out: integer )
    1 ;

{ 1 } [ no-inputs ] unit-test

TUPLE: unboxable3
    { x read-only } ; final

TYPED: no-inputs-unboxable-output ( -- out: unboxable3 )
    T{ unboxable3 } ;

{ T{ unboxable3 } } [ no-inputs-unboxable-output ] unit-test

{ f } [ no-inputs-unboxable-output no-inputs-unboxable-output eq? ] unit-test

SYMBOL: buh

TYPED: no-outputs ( x: integer -- )
    buh set ;

{ 2 } [ 2 no-outputs buh get ] unit-test

TYPED: no-outputs-unboxable-input ( x: unboxable3 -- )
    buh set ;

{ T{ unboxable3 } } [ T{ unboxable3 } no-outputs-unboxable-input buh get ] unit-test

{ f } [
    T{ unboxable3 } no-outputs-unboxable-input buh get
    T{ unboxable3 } no-outputs-unboxable-input buh get
    eq?
] unit-test

! Reported by littledan
TUPLE: superclass { x read-only } ;
TUPLE: subclass < superclass { y read-only } ; final

TYPED: unbox-fail ( a: superclass -- ? ) subclass? ;

{ t } [ subclass new unbox-fail ] unit-test

! If a final class becomes non-final, typed words need to be recompiled
TYPED: recompile-fail ( a: subclass -- ? ) buh get eq? ;

{ f } [ subclass new [ buh set ] [ recompile-fail ] bi ] unit-test

{ } [ "IN: typed.tests TUPLE: subclass < superclass { y read-only } ;" eval( -- ) ] unit-test

{ t } [ subclass new [ buh set ] [ recompile-fail ] bi ] unit-test

! Make sure that foldable and flushable work on typed words
TYPED: add ( a: integer b: integer -- c: integer ) + ; foldable

{ [ 3 ] } [ [ 1 2 add ] cleaned-up-tree nodes>quot ] unit-test

TYPED: flush-test ( s: symbol -- ? ) on t ; flushable

: flush-print-1 ( symbol -- ) flush-test drop ;
: flush-print-2 ( symbol -- ) flush-test . ;

SYMBOL: a-symbol

{ f } [
    f a-symbol [
        a-symbol flush-print-1
        a-symbol get
    ] with-variable
] unit-test

{ t } [
    f a-symbol [
        a-symbol flush-print-2
        a-symbol get
    ] with-variable
] unit-test

! Forgetting an unboxed final class should work
TUPLE: forget-class { x read-only } ; final

TYPED: forget-fail ( a: forget-class -- ) drop ;

{ } [ [ \ forget-class forget ] with-compilation-unit ] unit-test

{ } [ [ \ forget-fail forget ] with-compilation-unit ] unit-test

TYPED: typed-maybe ( x: maybe{ integer } -- ? ) >boolean ;

{ f } [ f typed-maybe ] unit-test
{ t } [ 30 typed-maybe ] unit-test
[ 30.0 typed-maybe ] [ input-mismatch-error? ] must-fail-with

TYPED: typed-union ( x: union{ integer string } -- ? ) >boolean ;

{ t } [ 3 typed-union ] unit-test
{ t } [ "asdf" typed-union ] unit-test
[ 3.3 typed-union ] [ input-mismatch-error? ] must-fail-with

TYPED: typed-intersection ( x: intersection{ integer bignum } -- ? ) >boolean ;

{ t } [ 5555555555555555555555555555555555555555555555555555 typed-intersection ] unit-test
[ 0 typed-intersection ] [ input-mismatch-error? ] must-fail-with

[
    "IN: test123 USE: typed TYPED: foo ( x -- y ) ;" eval( -- )
] [ error>> no-types-specified? ] must-fail-with
