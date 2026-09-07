USING: classes classes.union compiler.units definitions eval generic
kernel math tools.test words ;
IN: generic.tests

! Static dispatch must follow changes after a lookup has been cached.
GENERIC: cached-method ( obj -- value )
M: object cached-method drop 1 ;

: cached-call ( -- value ) 3 cached-method ;

{ t t 1 } [
    fixnum \ cached-method method-for-class M\ object cached-method eq?
    real \ cached-method method-for-class M\ object cached-method eq?
    cached-call
] unit-test

{ } [
    "IN: generic.tests USING: kernel math ;
    M: integer cached-method drop 2 ;" eval( -- )
] unit-test

{ t f 2 } [
    fixnum \ cached-method method-for-class integer \ cached-method lookup-method eq?
    real \ cached-method method-for-class
    cached-call
] unit-test

! Redefining the same method must still recompile its callers.
{ } [
    "IN: generic.tests USING: kernel math ;
    M: integer cached-method drop 5 ;" eval( -- )
] unit-test

{ t 5 } [
    fixnum \ cached-method method-for-class integer \ cached-method lookup-method eq?
    cached-call
] unit-test

{ } [ [ integer \ cached-method lookup-method forget ] with-compilation-unit ] unit-test

{ t t 1 } [
    fixnum \ cached-method method-for-class M\ object cached-method eq?
    real \ cached-method method-for-class M\ object cached-method eq?
    cached-call
] unit-test

! Both successful and unsuccessful lookups depend on class definitions.
UNION: cached-class integer ;
GENERIC: cached-union-method ( obj -- value )
M: cached-class cached-union-method drop 3 ;

{ t f } [
    fixnum \ cached-union-method method-for-class
    M\ cached-class cached-union-method eq?
    float \ cached-union-method method-for-class
] unit-test

{ } [
    "IN: generic.tests USE: math UNION: cached-class float ;" eval( -- )
] unit-test

{ f t } [
    fixnum \ cached-union-method method-for-class
    float \ cached-union-method method-for-class
    M\ cached-class cached-union-method eq?
] unit-test

! A failed lookup must not hide a subsequently added method.
{ f } [ integer \ cached-union-method method-for-class ] unit-test

{ } [
    "IN: generic.tests USING: kernel math ;
    M: integer cached-union-method drop 4 ;" eval( -- )
] unit-test

{ t } [
    integer \ cached-union-method method-for-class
    integer \ cached-union-method lookup-method eq?
] unit-test
