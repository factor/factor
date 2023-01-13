USING: eval tools.test compiler.units vocabs words kernel
definitions sequences math classes classes.mixin kernel.private ;
IN: compiler.tests.redefine10

! Mixin redefinition should update predicate call sites

MIXIN: my-mixin
INSTANCE: fixnum my-mixin
: my-inline-1 ( a -- b ) dup my-mixin instance? [ 1 + ] when ;
: my-inline-2 ( a -- b ) dup my-mixin? [ 1 + ] when ;
: my-inline-3 ( a -- b ) dup my-mixin? [ float? ] [ drop f ] if ;
: my-inline-4 ( a -- b ) dup float? [ my-mixin? ] [ drop f ] if ;
: my-inline-5 ( a -- b ) dup my-mixin? [ fixnum? ] [ drop f ] if ;
: my-inline-6 ( a -- b ) dup fixnum? [ my-mixin? ] [ drop f ] if ;

GENERIC: fake-float? ( obj -- ? )

M: float fake-float? drop t ;
M: object fake-float? drop f ;

: my-fake-inline-3 ( a -- b ) dup my-mixin? [ fake-float? ] [ drop f ] if ;

: my-baked-inline-3 ( a -- b ) { my-mixin } declare fake-float? ;

{ f } [ 5 my-inline-3 ] unit-test

{ f } [ 5 my-fake-inline-3 ] unit-test

{ f } [ 5 my-baked-inline-3 ] unit-test

{ f } [ 5 my-inline-4 ] unit-test

{ t } [ 5 my-inline-5 ] unit-test

{ t } [ 5 my-inline-6 ] unit-test

{ } [ [ float my-mixin add-mixin-instance ] with-compilation-unit ] unit-test

{ 2.0 } [ 1.0 my-inline-1 ] unit-test

{ 2.0 } [ 1.0 my-inline-2 ] unit-test

{ t } [ 1.0 my-inline-3 ] unit-test

{ t } [ 1.0 my-fake-inline-3 ] unit-test

{ t } [ 1.0 my-baked-inline-3 ] unit-test

{ t } [ 1.0 my-inline-4 ] unit-test

{ f } [ 1.0 my-inline-5 ] unit-test

{ f } [ 1.0 my-inline-6 ] unit-test

{ } [ [ fixnum my-mixin remove-mixin-instance ] with-compilation-unit ] unit-test

{ f } [ 5 my-inline-3 ] unit-test

{ f } [ 5 my-fake-inline-3 ] unit-test

{ f } [ 5 my-baked-inline-3 ] unit-test

{ f } [ 5 my-inline-4 ] unit-test

{ f } [ 5 my-inline-5 ] unit-test

{ f } [ 5 my-inline-6 ] unit-test

{ } [ [ float my-mixin remove-mixin-instance ] with-compilation-unit ] unit-test

{ 1.0 } [ 1.0 my-inline-1 ] unit-test

{ 1.0 } [ 1.0 my-inline-2 ] unit-test

{ f } [ 1.0 my-inline-3 ] unit-test

{ f } [ 1.0 my-fake-inline-3 ] unit-test

{ f } [ 1.0 my-inline-4 ] unit-test

{ f } [ 1.0 my-inline-5 ] unit-test

{ f } [ 1.0 my-inline-6 ] unit-test
