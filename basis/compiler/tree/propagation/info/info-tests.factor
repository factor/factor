USING: accessors alien arrays byte-arrays classes classes.private classes.algebra classes.algebra.private
classes.builtin classes.mixin classes.predicate classes.singleton classes.tuple
classes.union compiler.units continuations locals words
classes.struct compiler.tree.propagation.copy
compiler.tree.propagation.info io.encodings.utf8 kernel literals math
math.intervals layouts namespaces sequences sequences.private tools.test ;
IN: compiler.tree.propagation.info.tests

{ f } [ 0.0 -0.0 eql? ] unit-test

! value-info-intersect
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

! refine-value-info
{
    $[ fixnum array-capacity-interval <class/interval-info> ]
} [
    H{ { 1234 1234 } } copies set
    {
        H{
            { 1234 $[ fixnum <class-info> ] }
        }
    } value-infos set
    integer array-capacity-interval <class/interval-info> 1234
    refine-value-info
    1234 value-info
] unit-test

! value-info-union

{ 3 t } [
    3 <literal-info>
    null-info value-info-union >literal<
] unit-test

[ { } value-infos-union ] must-not-fail

! interval>literal
{ 10 t } [
    fixnum 10 10 [a,b]  interval>literal
] unit-test

STRUCT: self { s self* } ;

TUPLE: tup1 foo ;

TUPLE: tup2 < tup1 bar ;

: make-slotted-info ( slot-classes class -- info )
    [ [ dup [ <class-info> ] when ] map ] dip <tuple-info> ;

! slots<=
{ t t f } [
    null-info null-info slots<=
    { byte-array } self make-slotted-info self <class-info> slots<=
    self <class-info> { byte-array } self make-slotted-info slots<=
] unit-test

! value-info<=
! ------------

! Comparing classes
{ t t } [
    byte-array c-ptr [ <class-info> ] bi@ value-info<=
    alien c-ptr [ <class-info> ] bi@ value-info<=
] unit-test

! Literals vs. classes
{ t f } [
    20 <literal-info> fixnum <class-info> value-info<=
    fixnum <class-info> 20 <literal-info> value-info<=
] unit-test

! Nulls vs. literals
{ t f } [
    null-info 3 <literal-info> value-info<=
    3 <literal-info> null-info value-info<=
] unit-test

! Fulls vs. literal
{ t } [
    10 <literal-info> f value-info<=
] unit-test

! Same class, different slots
{ t t f } [
    { byte-array } self make-slotted-info
    { c-ptr } self make-slotted-info
    value-info<=

    { byte-array byte-array } self make-slotted-info
    { } self make-slotted-info
    value-info<=

    { } self make-slotted-info
    { byte-array byte-array } self make-slotted-info
    value-info<=
] unit-test

! Slots with literals
{ f } [
    10 <literal-info> 1array array <tuple-info>
    20 <literal-info> 1array array <tuple-info>
    value-info<=
] unit-test

! Slots, but different classes
{ t } [
    null-info { f c-ptr } self make-slotted-info value-info<=
] unit-test

! Null vs. null vs. full
{ t t f } [
    null-info null-info value-info<=
    null-info f value-info<=
    f null-info value-info<=
] unit-test

! Same class, intervals
{ t f } [
    fixnum 20 30 [a,b] <class/interval-info>
    fixnum 0 100 [a,b] <class/interval-info>
    value-info<=
    fixnum 0 100 [a,b] <class/interval-info>
    fixnum 20 30 [a,b] <class/interval-info>
    value-info<=
] unit-test

! Different classes, intervals
{ t f f } [
    fixnum 20 30 [a,b] <class/interval-info>
    real 0 100 [a,b] <class/interval-info>
    value-info<=

    real 5 10 [a,b] <class/interval-info>
    integer 0 20 [a,b] <class/interval-info>
    value-info<=

    integer 0 20 [a,b] <class/interval-info>
    real 5 10 [a,b] <class/interval-info>
    value-info<=
] unit-test

! Mutable literals
{ f f } [
    [ "foo" ] <literal-info> [ "foo" ] <literal-info> value-info<=
    "hey" <literal-info> "hey" <literal-info> value-info<=
] unit-test

! Tuples
{ t f } [
    tup2 <class-info> tup1 <class-info> value-info<=
    tup1 <class-info> tup2 <class-info> value-info<=
] unit-test

! <class-info>
{ utf8 } [ utf8 <class-info> class>> ] unit-test

! init-interval
{
    T{ value-info-state
       { class array-capacity }
       { interval $[ array-capacity-interval ] }
    }
} [
    <value-info> -100 100 [a,b] >>interval array-capacity >>class
    init-interval
] unit-test

! wrap-interval
${
    full-interval
    empty-interval
    fixnum-interval
    array-capacity-interval
    array-capacity-interval
    -100 100 [a,b]
} [
    full-interval integer wrap-interval
    empty-interval integer wrap-interval
    full-interval fixnum wrap-interval
    fixnum-interval array-capacity wrap-interval
    -100 100 [a,b] array-capacity wrap-interval
    -100 100 [a,b] integer wrap-interval
] unit-test

! Singleton integer intervals must retain values outside the fixnum range.
{ t t } [
    integer 100 2^ [a,a] <class/interval-info> >literal<
    [ 100 2^ = ] dip
] unit-test
{ t t } [
    integer 100 2^ neg [a,a] <class/interval-info> >literal<
    [ 100 2^ neg = ] dip
] unit-test
{ t t } [
    integer 3 >bignum [a,a] <class/interval-info> >literal<
    [ fixnum? ] dip
] unit-test


! Preserve an independent invocation of the original constructor rather
! than comparing two paths through the specialized class-only entrypoint.
: original-class-info ( class -- info ) f <class/interval-info> ;

PREDICATE: info-even < integer even? ;
UNION: info-empty ;
UNION: info-redefined fixnum ;
MIXIN: info-mixin
SINGLETON: info-singleton

: named-info-cases ( -- classes )
    { object null fixnum bignum integer real float number array-capacity
      integer-array-capacity array byte-array string sequence tuple word
      test-tuple tup1 tup2 self utf8 info-even info-empty info-mixin
      info-singleton class builtin-class tuple-class union-class
      predicate-class mixin-class singleton-class } ;

{ t } [
    named-info-cases [ [ <class-info> ] [ original-class-info ] bi = ] all?
] unit-test

! The two bounded intervals are closed, integral and have more than one
! point. These are the only non-special class-interval results.
{ t } [
    { fixnum array-capacity integer-array-capacity } [
        [ class-interval dup integral-closure = ]
        [ class-interval interval-length 0 > ] bi and
    ] all?
] unit-test

: anonymous-info-cases ( -- classes )
    { }
    { integer string } anonymous-union boa suffix
    { object integer } anonymous-intersection boa suffix
    { } anonymous-union boa suffix
    { } anonymous-intersection boa suffix
    object anonymous-complement boa suffix
    integer [ even? ] anonymous-predicate boa suffix ;

! Equal anonymous objects can participate in structural cache interning.
! Prime the old path, then verify a distinct equal input on the new path,
! including later class-algebra queries on the resulting class descriptor.
{ t } [
    anonymous-info-cases [ [ [let
        init-caches
        dup original-class-info :> primed
        clone dup original-class-info :> expected
        <class-info> :> actual
        expected actual =
        primed class>> expected class>> class<=
        primed class>> actual class>> class<= = and
        expected class>> primed class>> class<=
        actual class>> primed class>> class<= = and
    ] ] with-scope ] all?
] unit-test

:: class-info-mutation-independent? ( class -- ? )
    class <class-info> :> first
    class <class-info> :> second
    first second eq? not
    first null >>class empty-interval >>interval
        123 >>literal t >>literal? { object-info } >>slots drop
    second class original-class-info = and ;

{ t } [ named-info-cases [ class-info-mutation-independent? ] all? ] unit-test

SYMBOL: redefined-info-input

: redefined-info-agrees? ( -- ? )
    redefined-info-input get [ <class-info> ] [ original-class-info ] bi = ;

! Named class identity persists across redefinition. Read it dynamically
! so the test exercises constructor execution instead of a folded literal.
{ t t t } [ [
    info-redefined redefined-info-input set
    [
        redefined-info-agrees?
        [ info-redefined { } define-union-class ] with-compilation-unit
        redefined-info-agrees?
        redefined-info-input get <class-info> class>> null eq? and
        [ info-redefined { string integer } define-union-class ] with-compilation-unit
        redefined-info-agrees?
        redefined-info-input get <class-info> class>> info-redefined eq? and
    ] [ [ info-redefined { fixnum } define-union-class ] with-compilation-unit ] finally
] with-scope ] unit-test


! The finite interval tuple has read-only fields but its endpoint arrays
! are mutable. Preserve the original constructor's independent endpoints.
:: class-info-interval-independent? ( class -- ? )
    class <class-info> interval>> :> first
    class <class-info> interval>> :> second
    first second eq? not
    first from>> second from>> eq? not and
    0 first from>> set-first
    second class original-class-info interval>> = and ;

{ t } [
    { fixnum array-capacity integer-array-capacity }
    [ class-info-interval-independent? ] all?
] unit-test
