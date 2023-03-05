USING: accessors arrays assocs bit-arrays bit-vectors
byte-arrays classes.tuple classes.union compiler.crossref
compiler.units definitions eval generic generic.single
generic.standard io.streams.string kernel make math
math.constants math.functions namespaces parser quotations
sequences specialized-vectors strings tools.test words ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-VECTOR: c:double
IN: generic.standard.tests

GENERIC: class-of ( x -- y )

M: fixnum class-of drop "fixnum" ;
M: word   class-of drop "word"   ;

{ "fixnum" } [ 5 class-of ] unit-test
{ "word" } [ \ class-of class-of ] unit-test
[ 3.4 class-of ] must-fail

GENERIC: foobar ( x -- y )
M: object foobar drop "Hello world" ;
M: fixnum foobar drop "Goodbye cruel world" ;

{ "Hello world" } [ 4 foobar foobar ] unit-test
{ "Goodbye cruel world" } [ 4 foobar ] unit-test

GENERIC: lo-tag-test ( obj -- obj' )

M: integer lo-tag-test 3 + ;
M: float lo-tag-test 4 - ;
M: rational lo-tag-test 2 - ;
M: complex lo-tag-test sq ;

{ 8 } [ 5 >bignum lo-tag-test ] unit-test
{ 0.0 } [ 4.0 lo-tag-test ] unit-test
{ -1/2 } [ 1+1/2 lo-tag-test ] unit-test
{ -16 } [ C{ 0 4 } lo-tag-test ] unit-test

GENERIC: hi-tag-test ( obj -- obj' )

M: string hi-tag-test ", in bed" append ;
M: integer hi-tag-test 3 + ;
M: array hi-tag-test [ hi-tag-test ] map ;
M: sequence hi-tag-test reverse ;

{ B{ 3 2 1 } } [ B{ 1 2 3 } hi-tag-test ] unit-test

{ { 6 9 12 } } [ { 3 6 9 } hi-tag-test ] unit-test

{ "i like monkeys, in bed" } [ "i like monkeys" hi-tag-test ] unit-test

UNION: funnies quotation float complex ;

GENERIC: funny ( x -- y )
M: funnies funny drop 2 ;
M: object funny drop 0 ;

GENERIC: union-containment ( x -- y )
M: integer union-containment drop 1 ;
M: number union-containment drop 2 ;

{ 1 } [ 1 union-containment ] unit-test
{ 2 } [ 1.0 union-containment ] unit-test

{ 2 } [ [ { } ] funny ] unit-test
{ 0 } [ { } funny ] unit-test

TUPLE: shape ;

TUPLE: abstract-rectangle < shape width height ;

TUPLE: rectangle < abstract-rectangle ;

C: <rectangle> rectangle

TUPLE: parallelogram < abstract-rectangle skew ;

C: <parallelogram> parallelogram

TUPLE: circle < shape radius ;

C: <circle> circle

GENERIC: area ( shape -- n )

M: abstract-rectangle area [ width>> ] [ height>> ] bi * ;

M: circle area radius>> sq pi * ;

{ 12 } [ 4 3 <rectangle> area ] unit-test
{ 12 } [ 4 3 2 <parallelogram> area ] unit-test
{ t } [ 2 <circle> area 4 pi * = ] unit-test

GENERIC: perimeter ( shape -- n )

: rectangle-perimeter ( l w -- n ) + 2 * ;

M: rectangle perimeter
    [ width>> ] [ height>> ] bi
    rectangle-perimeter ;

: hypotenuse ( a b -- c ) [ sq ] bi@ + sqrt ;

M: parallelogram perimeter
    [ width>> ]
    [ [ height>> ] [ skew>> ] bi hypotenuse ] bi
    rectangle-perimeter ;

M: circle perimeter 2 * pi * ;

{ 14 } [ 4 3 <rectangle> perimeter ] unit-test
{ 30.0 } [ 10 4 3 <parallelogram> perimeter ] unit-test

PREDICATE: very-funny < funnies number? ;

GENERIC: gooey ( x -- y )
M: very-funny gooey sq ;

{ 0.25 } [ 0.5 gooey ] unit-test

GENERIC: empty-method-test ( x -- y )
M: object empty-method-test ;
TUPLE: for-arguments-sake ;
C: <for-arguments-sake> for-arguments-sake

M: for-arguments-sake empty-method-test drop "Hi" ;

TUPLE: another-one ;
C: <another-one> another-one

{ "Hi" } [ <for-arguments-sake> empty-method-test empty-method-test ] unit-test
{ T{ another-one f } } [ <another-one> empty-method-test ] unit-test

GENERIC: big-mix-test ( obj -- obj' )

M: object big-mix-test drop "object" ;

M: tuple big-mix-test drop "tuple" ;

M: integer big-mix-test drop "integer" ;

M: float big-mix-test drop "float" ;

M: complex big-mix-test drop "complex" ;

M: string big-mix-test drop "string" ;

M: array big-mix-test drop "array" ;

M: sequence big-mix-test drop "sequence" ;

M: rectangle big-mix-test drop "rectangle" ;

M: parallelogram big-mix-test drop "parallelogram" ;

M: circle big-mix-test drop "circle" ;

{ "integer" } [ 3 big-mix-test ] unit-test
{ "float" } [ 5.0 big-mix-test ] unit-test
{ "complex" } [ -1 sqrt big-mix-test ] unit-test
{ "sequence" } [ B{ 1 2 3 } big-mix-test ] unit-test
{ "sequence" } [ ?{ t f t } big-mix-test ] unit-test
{ "sequence" } [ SBUF" hello world" big-mix-test ] unit-test
{ "sequence" } [ V{ "a" "b" } big-mix-test ] unit-test
{ "sequence" } [ BV{ 1 2 } big-mix-test ] unit-test
{ "sequence" } [ ?V{ t t f f } big-mix-test ] unit-test
{ "string" } [ "hello" big-mix-test ] unit-test
{ "rectangle" } [ 1 2 <rectangle> big-mix-test ] unit-test
{ "parallelogram" } [ 10 4 3 <parallelogram> big-mix-test ] unit-test
{ "circle" } [ 100 <circle> big-mix-test ] unit-test
{ "tuple" } [ H{ } big-mix-test ] unit-test
{ "object" } [ \ + big-mix-test ] unit-test

GENERIC: small-lo-tag ( obj -- obj )

M: fixnum small-lo-tag drop "fixnum" ;

M: string small-lo-tag drop "string" ;

M: array small-lo-tag drop "array" ;

M: double-array small-lo-tag drop "double-array" ;

M: byte-array small-lo-tag drop "byte-array" ;

{ "fixnum" } [ 3 small-lo-tag ] unit-test

{ "double-array" } [ double-array{ 1.0 } small-lo-tag ] unit-test

! Testing recovery from bad method definitions
"IN: generic.standard.tests GENERIC: unhappy ( x -- x )" eval( -- )
[
    "IN: generic.standard.tests M: dictionary unhappy ;" eval( -- )
] must-fail
{ } [ "IN: generic.standard.tests GENERIC: unhappy ( x -- x )" eval( -- ) ] unit-test

GENERIC#: complex-combination 1 ( a b -- c )
M: string complex-combination drop ;
M: object complex-combination nip ;

{ "hi" } [ "hi" 3 complex-combination ] unit-test
{ "hi" } [ 3 "hi" complex-combination ] unit-test

! Regression
TUPLE: first-one ;
TUPLE: second-one ;
UNION: both first-one union-class ;

GENERIC: wii ( x -- y )
M: both wii drop 3 ;
M: second-one wii drop 4 ;
M: tuple-class wii drop 5 ;
M: integer wii drop 6 ;

{ 3 } [ T{ first-one } wii ] unit-test

GENERIC: tag-and-f ( x -- x x )

M: fixnum tag-and-f 1 ;

M: bignum tag-and-f 2 ;

M: float tag-and-f 3 ;

M: f tag-and-f 4 ;

{ f 4 } [ f tag-and-f ] unit-test

{ 3.4 3 } [ 3.4 tag-and-f ] unit-test

! Issues with forget
GENERIC: generic-forget-test ( a -- b )

M: f generic-forget-test ;

{ } [ \ f \ generic-forget-test lookup-method "m" set ] unit-test

{ } [ [ "m" get forget ] with-compilation-unit ] unit-test

{ } [ "IN: generic.standard.tests M: f generic-forget-test ;" eval( -- ) ] unit-test

{ } [ [ "m" get forget ] with-compilation-unit ] unit-test

{ f } [ f generic-forget-test ] unit-test

! erg's regression
{ } [
    "IN: generic.standard.tests

    GENERIC: jeah ( a -- b )
    TUPLE: boii ;
    M: boii jeah ;
    GENERIC: jeah* ( a -- b )
    M: boii jeah* jeah ;" eval( -- )

    "IN: generic.standard.tests
    FORGET: boii" eval( -- )

    "IN: generic.standard.tests
    TUPLE: boii ;
    M: boii jeah ;" eval( -- )
] unit-test

! Testing next-method
TUPLE: person ;

TUPLE: intern < person ;

TUPLE: employee < person ;

TUPLE: tape-monkey < employee ;

TUPLE: manager < employee ;

TUPLE: junior-manager < manager ;

TUPLE: middle-manager < manager ;

TUPLE: senior-manager < manager ;

TUPLE: executive < senior-manager ;

TUPLE: ceo < executive ;

GENERIC: salary ( person -- n )

M: intern salary
    ! Intentional mistake.
    call-next-method ;

M: employee salary drop 24000 ;

M: manager salary call-next-method 12000 + ;

M: middle-manager salary call-next-method 5000 + ;

M: senior-manager salary call-next-method 15000 + ;

M: executive salary call-next-method 2 * ;

M: ceo salary
    ! Intentional error.
    drop 5 call-next-method 3 * ;

[ salary ] must-infer

{ 24000 } [ employee boa salary ] unit-test

{ 24000 } [ tape-monkey boa salary ] unit-test

{ 36000 } [ junior-manager boa salary ] unit-test

{ 41000 } [ middle-manager boa salary ] unit-test

{ 51000 } [ senior-manager boa salary ] unit-test

{ 102000 } [ executive boa salary ] unit-test

[ ceo boa salary ]
[ T{ inconsistent-next-method f ceo salary } = ] must-fail-with

[ intern boa salary ]
[ no-next-method? ] must-fail-with

! Weird shit
TUPLE: a ;
TUPLE: b ;
TUPLE: c ;

UNION: x a b ;
UNION: y a c ;

UNION: z x y ;

GENERIC: funky* ( obj -- )

M: z funky* "z" , drop ;

M: x funky* "x" , call-next-method ;

M: y funky* "y" , call-next-method ;

M: a funky* "a" , call-next-method ;

M: b funky* "b" , call-next-method ;

M: c funky* "c" , call-next-method ;

: funky ( obj -- seq ) [ funky* ] { } make ;

{ { "b" "x" "z" } } [ T{ b } funky ] unit-test

{ { "c" "y" "z" } } [ T{ c } funky ] unit-test

{ t } [
    T{ a } funky
    { { "a" "x" "z" } { "a" "y" "z" } } member?
] unit-test

! Changing method combination should not fail
{ } [ "IN: generic.standard.tests GENERIC: xyz ( a -- b )" eval( -- ) ] unit-test
{ } [ "IN: generic.standard.tests MATH: xyz ( a b -- c )" eval( -- ) ] unit-test

{ f } [ "xyz" "generic.standard.tests" lookup-word pic-def>> ] unit-test
{ f } [ "xyz" "generic.standard.tests" lookup-word "decision-tree" word-prop ] unit-test

! Corner cases
[ "IN: generic.standard.tests GENERIC: broken-generic ( -- )" eval( -- ) ]
[ error>> bad-dispatch-position? ]
must-fail-with
[ "IN: generic.standard.tests GENERIC#: broken-generic# -1 ( a -- b )" eval( -- ) ]
[ error>> bad-dispatch-position? ]
must-fail-with
[ "IN: generic.standard.tests GENERIC#: broken-generic# 1 ( a -- b )" eval( -- ) ]
[ error>> bad-dispatch-position? ]
must-fail-with
[ "IN: generic.standard.tests GENERIC#: broken-generic# 2/3 ( a b c -- )" eval( -- ) ]
[ error>> bad-dispatch-position? ]
must-fail-with

! Generic words cannot be inlined
{ } [ "IN: generic.standard.tests GENERIC: foo ( x -- x )" eval( -- ) ] unit-test
[ "IN: generic.standard.tests GENERIC: foo ( x -- x ) inline" eval( -- ) ] must-fail

! Moving a method from one vocab to another didn't always work
GENERIC: move-method-generic ( a -- b )

[ "IN: generic.standard.tests.a USE: strings USE: generic.standard.tests M: string move-method-generic ;" <string-reader> "move-method-test-1" parse-stream ] must-not-fail

[ "IN: generic.standard.tests.b USE: strings USE: generic.standard.tests M: string move-method-generic ;" <string-reader> "move-method-test-2" parse-stream ] must-not-fail

[ "IN: generic.standard.tests.a" <string-reader> "move-method-test-1" parse-stream ] must-not-fail

{ { string } } [ \ move-method-generic dispatch-order ] unit-test

! FORGET: on method wrappers
GENERIC: forget-test ( a -- b )

M: integer forget-test 3 + ;

{ } [ "IN: generic.standard.tests USE: math FORGET: M\\ integer forget-test" eval( -- ) ] unit-test

{ { } } [
    \ + all-dependencies-of keys [ method? ] filter
    [ "method-generic" word-prop \ forget-test eq? ] filter
] unit-test

[ 10 forget-test ] [ no-method? ] must-fail-with

! Declarations on methods
GENERIC: flushable-generic ( a -- b ) flushable
M: integer flushable-generic ;

{ t } [ \ flushable-generic flushable? ] unit-test
{ t } [ M\ integer flushable-generic flushable? ] unit-test

GENERIC: non-flushable-generic ( a -- b )
M: integer non-flushable-generic ; flushable

{ f } [ \ non-flushable-generic flushable? ] unit-test
{ t } [ M\ integer non-flushable-generic flushable? ] unit-test

! method-for-object, method-for-class, effective-method
GENERIC: foozul ( a -- b )
M: reversed foozul ;
M: integer foozul ;
M: slice foozul ;

{ } [ reversed \ foozul method-for-class M\ reversed foozul assert= ] unit-test
{ } [ { 1 2 3 } <reversed> \ foozul method-for-object M\ reversed foozul assert= ] unit-test
[ { 1 2 3 } <reversed> \ foozul effective-method M\ reversed foozul assert= ] must-not-fail

{ } [ fixnum \ foozul method-for-class M\ integer foozul assert= ] unit-test
{ } [ 13 \ foozul method-for-object M\ integer foozul assert= ] unit-test
[ 13 \ foozul effective-method M\ integer foozul assert= ] must-not-fail

! Ensure dynamic and static dispatch match in ambiguous cases
UNION: amb-union-1a integer float ;
UNION: amb-union-1b float string ;

GENERIC: amb-generic-1 ( a -- b )

M: amb-union-1a amb-generic-1 drop "a" ;
M: amb-union-1b amb-generic-1 drop "b" ;

{ } [
    5.0 amb-generic-1
    5.0 \ amb-generic-1 effective-method execute( a -- b ) assert=
] unit-test

{ } [
    5.0 amb-generic-1
    5.0 float \ amb-generic-1 method-for-class execute( a -- b ) assert=
] unit-test

UNION: amb-union-2a float string ;
UNION: amb-union-2b integer float ;

GENERIC: amb-generic-2 ( a -- b )

M: amb-union-2a amb-generic-2 drop "a" ;
M: amb-union-2b amb-generic-2 drop "b" ;

{ } [
    5.0 amb-generic-1
    5.0 \ amb-generic-1 effective-method execute( a -- b ) assert=
] unit-test

{ } [
    5.0 amb-generic-1
    5.0 float \ amb-generic-1 method-for-class execute( a -- b ) assert=
] unit-test

TUPLE: amb-tuple-a x ;
TUPLE: amb-tuple-b < amb-tuple-a ;
PREDICATE: amb-tuple-c < amb-tuple-a x>> 3 = ;

GENERIC: amb-generic-3 ( a -- b )

M: amb-tuple-b amb-generic-3 drop "b" ;
M: amb-tuple-c amb-generic-3 drop "c" ;

{ } [
    T{ amb-tuple-b f 3 } amb-generic-3
    T{ amb-tuple-b f 3 } \ amb-generic-3 effective-method execute( a -- b ) assert=
] unit-test

TUPLE: amb-tuple-d ;
UNION: amb-union-4 amb-tuple-a amb-tuple-d ;

GENERIC: amb-generic-4 ( a -- b )

M: amb-tuple-b amb-generic-4 drop "b" ;
M: amb-union-4 amb-generic-4 drop "4" ;

{ } [
    T{ amb-tuple-b f 3 } amb-generic-4
    T{ amb-tuple-b f 3 } \ amb-generic-4 effective-method execute( a -- b ) assert=
] unit-test

{ } [
    T{ amb-tuple-b f 3 } amb-generic-4
    T{ amb-tuple-b f 3 } amb-tuple-b \ amb-generic-4 method-for-class execute( a -- b ) assert=
] unit-test

MIXIN: amb-mixin-5
INSTANCE: amb-tuple-a amb-mixin-5
INSTANCE: amb-tuple-d amb-mixin-5

GENERIC: amb-generic-5 ( a -- b )

M: amb-tuple-b amb-generic-5 drop "b" ;
M: amb-mixin-5 amb-generic-5 drop "5" ;

{ } [
    T{ amb-tuple-b f 3 } amb-generic-5
    T{ amb-tuple-b f 3 } \ amb-generic-5 effective-method execute( a -- b ) assert=
] unit-test

{ } [
    T{ amb-tuple-b f 3 } amb-generic-5
    T{ amb-tuple-b f 3 } amb-tuple-b \ amb-generic-5 method-for-class execute( a -- b ) assert=
] unit-test

UNION: amb-union-6 amb-tuple-b amb-tuple-d ;

GENERIC: amb-generic-6 ( a -- b )

M: amb-tuple-a amb-generic-6 drop "a" ;
M: amb-union-6 amb-generic-6 drop "6" ;

{ } [
    T{ amb-tuple-b f 3 } amb-generic-6
    T{ amb-tuple-b f 3 } \ amb-generic-6 effective-method execute( a -- b ) assert=
] unit-test

{ } [
    T{ amb-tuple-b f 3 } amb-generic-6
    T{ amb-tuple-b f 3 } amb-tuple-b \ amb-generic-6 method-for-class execute( a -- b ) assert=
] unit-test

MIXIN: amb-mixin-7
INSTANCE: amb-tuple-b amb-mixin-7
INSTANCE: amb-tuple-d amb-mixin-7

GENERIC: amb-generic-7 ( a -- b )

M: amb-tuple-a amb-generic-7 drop "a" ;
M: amb-mixin-7 amb-generic-7 drop "7" ;

{ } [
    T{ amb-tuple-b f 3 } amb-generic-7
    T{ amb-tuple-b f 3 } \ amb-generic-7 effective-method execute( a -- b ) assert=
] unit-test

{ } [
    T{ amb-tuple-b f 3 } amb-generic-7
    T{ amb-tuple-b f 3 } amb-tuple-b \ amb-generic-7 method-for-class execute( a -- b ) assert=
] unit-test

! Same thing as above but with predicate classes
PREDICATE: amb-predicate-a < integer 10 mod even? ;
PREDICATE: amb-predicate-b < amb-predicate-a 10 mod 4 = ;

UNION: amb-union-8 amb-predicate-b string ;

GENERIC: amb-generic-8 ( a -- b )

M: amb-union-8 amb-generic-8 drop "8" ;
M: amb-predicate-a amb-generic-8 drop "a" ;

{ } [
    4 amb-generic-8
    4 \ amb-generic-8 effective-method execute( a -- b ) assert=
] unit-test
