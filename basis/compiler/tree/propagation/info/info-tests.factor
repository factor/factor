USING: accessors alien byte-arrays classes.struct math math.intervals sequences
classes.algebra kernel tools.test compiler.tree.propagation.info arrays ;
IN: compiler.tree.propagation.info.tests

{ f } [ 0.0 -0.0 eql? ] unit-test

{ t t } [
    0 10 [a,b] <interval-info>
    5 20 [a,b] <interval-info>
    value-info-intersect
    [ class>> real class= ]
    [ interval>> 5 10 [a,b] = ]
    bi
] unit-test

{ float 10.0 t } [
    10.0 <literal-info>
    10.0 <literal-info>
    value-info-intersect
    [ class>> ] [ >literal< ] bi
] unit-test

{ null } [
    10 <literal-info>
    10.0 <literal-info>
    value-info-intersect
    class>>
] unit-test

{ fixnum 10 t } [
    10 <literal-info>
    10 <literal-info>
    value-info-union
    [ class>> ] [ >literal< ] bi
] unit-test

{ 3.0 t } [
    3 3 [a,b] <interval-info> float <class-info>
    value-info-intersect >literal<
] unit-test

{ 3 t } [
    2 3 (a,b] <interval-info> fixnum <class-info>
    value-info-intersect >literal<
] unit-test

{ T{ value-info-state f null empty-interval f f } } [
    fixnum -10 0 [a,b] <class/interval-info>
    fixnum 19 29 [a,b] <class/interval-info>
    value-info-intersect
] unit-test

{ 3 t } [
    3 <literal-info>
    null-info value-info-union >literal<
] unit-test

{ } [ { } value-infos-union drop ] unit-test

TUPLE: test-tuple { x read-only } ;

{ t } [
    f f 3 <literal-info> 3array test-tuple <tuple-info> dup
    object-info value-info-intersect =
] unit-test

{ t t } [
    f <literal-info>
    fixnum 0 40 [a,b] <class/interval-info>
    value-info-union
    \ f class-not <class-info>
    value-info-intersect
    [ class>> fixnum class= ]
    [ interval>> 0 40 [a,b] = ] bi
] unit-test

! interval>literal
{ 10 t } [
    fixnum 10 10 [a,b]  interval>literal
] unit-test

STRUCT: self { s self* } ;

! value-info<=
{ t t t t t t } [
    byte-array <class-info> c-ptr <class-info> value-info<=
    null-info 3 <literal-info> value-info<=
    null-info null-info value-info<=
    alien <class-info> c-ptr <class-info> value-info<=

    20 <literal-info> fixnum <class-info> value-info<=

    ! A byte-array is a kind of c-ptr
    f byte-array <class-info> 2array self <tuple-info>
    f c-ptr <class-info> 2array self <tuple-info>
    value-info<=
] unit-test

{ f f f f f } [
    ! Checking intervals
    fixnum <class-info> 20 <literal-info> value-info<=

    ! Mutable literals
    [ "foo" ] <literal-info> [ "foo" ] <literal-info> value-info<=
    ! Strings should be immutable but they aren't. :/
    "hey" <literal-info> "hey" <literal-info> value-info<=

    f c-ptr <class-info> 2array self <tuple-info>
    f byte-array <class-info> 2array self <tuple-info>
    value-info<=

    ! If one value-info has a slot specified and the other doesn't,
    ! then it can't be smaller because that other slot could be
    ! anything!
    self <class-info>
    f byte-array <class-info> 2array self <tuple-info> value-info<=
] unit-test

{ t f } [
    10 <literal-info> f value-info<=
    f 10 <literal-info> value-info<=
] unit-test
