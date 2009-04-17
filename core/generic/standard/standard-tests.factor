IN: generic.standard.tests
USING: tools.test math math.functions math.constants
generic.standard strings sequences arrays kernel accessors words
specialized-arrays.double byte-arrays bit-arrays parser
namespaces make quotations stack-checker vectors growable
hashtables sbufs prettyprint byte-vectors bit-vectors
specialized-vectors.double definitions generic sets graphs assocs
grouping see ;

GENERIC: lo-tag-test ( obj -- obj' )

M: integer lo-tag-test 3 + ;

M: float lo-tag-test 4 - ;

M: rational lo-tag-test 2 - ;

M: complex lo-tag-test sq ;

[ 8 ] [ 5 >bignum lo-tag-test ] unit-test
[ 0.0 ] [ 4.0 lo-tag-test ] unit-test
[ -1/2 ] [ 1+1/2 lo-tag-test ] unit-test
[ -16 ] [ C{ 0 4 } lo-tag-test ] unit-test

GENERIC: hi-tag-test ( obj -- obj' )

M: string hi-tag-test ", in bed" append ;

M: integer hi-tag-test 3 + ;

M: array hi-tag-test [ hi-tag-test ] map ;

M: sequence hi-tag-test reverse ;

[ B{ 3 2 1 } ] [ B{ 1 2 3 } hi-tag-test ] unit-test

[ { 6 9 12 } ] [ { 3 6 9 } hi-tag-test ] unit-test

[ "i like monkeys, in bed" ] [ "i like monkeys" hi-tag-test ] unit-test

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

[ 12 ] [ 4 3 <rectangle> area ] unit-test
[ 12 ] [ 4 3 2 <parallelogram> area ] unit-test
[ t ] [ 2 <circle> area 4 pi * = ] unit-test

GENERIC: perimiter ( shape -- n )

: rectangle-perimiter ( l w -- n ) + 2 * ;

M: rectangle perimiter
    [ width>> ] [ height>> ] bi
    rectangle-perimiter ;

: hypotenuse ( a b -- c ) [ sq ] bi@ + sqrt ;

M: parallelogram perimiter
    [ width>> ]
    [ [ height>> ] [ skew>> ] bi hypotenuse ] bi
    rectangle-perimiter ;

M: circle perimiter 2 * pi * ;

[ 14 ] [ 4 3 <rectangle> perimiter ] unit-test
[ 30.0 ] [ 10 4 3 <parallelogram> perimiter ] unit-test

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

[ "integer" ] [ 3 big-mix-test ] unit-test
[ "float" ] [ 5.0 big-mix-test ] unit-test
[ "complex" ] [ -1 sqrt big-mix-test ] unit-test
[ "sequence" ] [ double-array{ 1.0 2.0 3.0 } big-mix-test ] unit-test
[ "sequence" ] [ B{ 1 2 3 } big-mix-test ] unit-test
[ "sequence" ] [ ?{ t f t } big-mix-test ] unit-test
[ "sequence" ] [ SBUF" hello world" big-mix-test ] unit-test
[ "sequence" ] [ V{ "a" "b" } big-mix-test ] unit-test
[ "sequence" ] [ BV{ 1 2 } big-mix-test ] unit-test
[ "sequence" ] [ ?V{ t t f f } big-mix-test ] unit-test
[ "sequence" ] [ double-vector{ -0.3 4.6 } big-mix-test ] unit-test
[ "string" ] [ "hello" big-mix-test ] unit-test
[ "rectangle" ] [ 1 2 <rectangle> big-mix-test ] unit-test
[ "parallelogram" ] [ 10 4 3 <parallelogram> big-mix-test ] unit-test
[ "circle" ] [ 100 <circle> big-mix-test ] unit-test
[ "tuple" ] [ H{ } big-mix-test ] unit-test
[ "object" ] [ \ + big-mix-test ] unit-test

GENERIC: small-lo-tag ( obj -- obj )

M: fixnum small-lo-tag drop "fixnum" ;

M: string small-lo-tag drop "string" ;

M: array small-lo-tag drop "array" ;

M: double-array small-lo-tag drop "double-array" ;

M: byte-array small-lo-tag drop "byte-array" ;

[ "fixnum" ] [ 3 small-lo-tag ] unit-test

[ "double-array" ] [ double-array{ 1.0 } small-lo-tag ] unit-test

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
    #! Intentional mistake.
    call-next-method ;

M: employee salary drop 24000 ;

M: manager salary call-next-method 12000 + ;

M: middle-manager salary call-next-method 5000 + ;

M: senior-manager salary call-next-method 15000 + ;

M: executive salary call-next-method 2 * ;

M: ceo salary
    #! Intentional error.
    drop 5 call-next-method 3 * ;

[ salary ] must-infer

[ 24000 ] [ employee boa salary ] unit-test

[ 24000 ] [ tape-monkey boa salary ] unit-test

[ 36000 ] [ junior-manager boa salary ] unit-test

[ 41000 ] [ middle-manager boa salary ] unit-test

[ 51000 ] [ senior-manager boa salary ] unit-test

[ 102000 ] [ executive boa salary ] unit-test

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

[ { "b" "x" "z" } ] [ T{ b } funky ] unit-test

[ { "c" "y" "z" } ] [ T{ c } funky ] unit-test

[ t ] [
    T{ a } funky
    { { "a" "x" "z" } { "a" "y" "z" } } member?
] unit-test

! Hooks
SYMBOL: my-var
HOOK: my-hook my-var ( -- x )

M: integer my-hook "an integer" ;
M: string my-hook "a string" ;

[ "an integer" ] [ 3 my-var set my-hook ] unit-test
[ "a string" ] [ my-hook my-var set my-hook ] unit-test
[ 1.0 my-var set my-hook ] [ T{ no-method f 1.0 my-hook } = ] must-fail-with

HOOK: my-tuple-hook my-var ( -- x )

M: sequence my-tuple-hook my-hook ;

TUPLE: m-t-h-a ;

M: m-t-h-a my-tuple-hook "foo" ;

TUPLE: m-t-h-b < m-t-h-a ;

M: m-t-h-b my-tuple-hook "bar" ;

[ f ] [
    \ my-tuple-hook [ "engines" word-prop ] keep prefix
    [ 1quotation infer ] map all-equal?
] unit-test

HOOK: call-next-hooker my-var ( -- x )

M: sequence call-next-hooker "sequence" ;

M: array call-next-hooker call-next-method "array " prepend ;

M: vector call-next-hooker call-next-method "vector " prepend ;

M: growable call-next-hooker call-next-method "growable " prepend ;

[ "vector growable sequence" ] [
    V{ } my-var [ call-next-hooker ] with-variable
] unit-test

! Cross-referencing with generic words
TUPLE: xref-tuple-1 ;
TUPLE: xref-tuple-2 < xref-tuple-1 ;

: (xref-test) ( obj -- ) drop ;

GENERIC: xref-test ( obj -- )

M: xref-tuple-1 xref-test (xref-test) ;
M: xref-tuple-2 xref-test (xref-test) ;

[ t ] [
    \ xref-test
    \ xref-tuple-1 \ xref-test method [ usage unique ] closure key?
] unit-test

[ t ] [
    \ xref-test
    \ xref-tuple-2 \ xref-test method [ usage unique ] closure key?
] unit-test

[ t ] [
    { } \ nth effective-method nip \ sequence \ nth method eq?
] unit-test

[ t ] [
    \ + \ nth effective-method nip dup \ nth "default-method" word-prop eq? and
] unit-test
