USING: accessors alien arrays definitions generic generic.standard
generic.math assocs hashtables io kernel math namespaces parser
prettyprint sequences strings tools.test vectors words
quotations classes classes.algebra classes.tuple continuations
layouts classes.union sorting compiler.units eval multiline
io.streams.string ;
IN: generic.tests

GENERIC: foobar ( x -- y )
M: object foobar drop "Hello world" ;
M: fixnum foobar drop "Goodbye cruel world" ;

GENERIC: class-of ( x -- y )

M: fixnum class-of drop "fixnum" ;
M: word   class-of drop "word"   ;

[ "fixnum" ] [ 5 class-of ] unit-test
[ "word" ] [ \ class-of class-of ] unit-test
[ 3.4 class-of ] must-fail

[ "Hello world" ] [ 4 foobar foobar ] unit-test
[ "Goodbye cruel world" ] [ 4 foobar ] unit-test

! Testing unions
UNION: funnies quotation float complex ;

GENERIC: funny ( x -- y )
M: funnies funny drop 2 ;
M: object funny drop 0 ;

[ 2 ] [ [ { } ] funny ] unit-test
[ 0 ] [ { } funny ] unit-test

PREDICATE: very-funny < funnies number? ;

GENERIC: gooey ( x -- y )
M: very-funny gooey sq ;

[ 0.25 ] [ 0.5 gooey ] unit-test

GENERIC: empty-method-test ( x -- y )
M: object empty-method-test ;
TUPLE: for-arguments-sake ;
C: <for-arguments-sake> for-arguments-sake

M: for-arguments-sake empty-method-test drop "Hi" ;

TUPLE: another-one ;
C: <another-one> another-one

[ "Hi" ] [ <for-arguments-sake> empty-method-test empty-method-test ] unit-test
[ T{ another-one f } ] [ <another-one> empty-method-test ] unit-test

! Weird bug
GENERIC: stack-underflow ( x y -- )
M: object stack-underflow 2drop ;
M: word stack-underflow 2drop ;

GENERIC: union-containment ( x -- y )
M: integer union-containment drop 1 ;
M: number union-containment drop 2 ;

[ 1 ] [ 1 union-containment ] unit-test
[ 2 ] [ 1.0 union-containment ] unit-test

! Testing recovery from bad method definitions
"IN: generic.tests GENERIC: unhappy ( x -- x )" eval( -- )
[
    "IN: generic.tests M: dictionary unhappy ;" eval( -- )
] must-fail
[ ] [ "IN: generic.tests GENERIC: unhappy ( x -- x )" eval( -- ) ] unit-test

GENERIC# complex-combination 1 ( a b -- c )
M: string complex-combination drop ;
M: object complex-combination nip ;

[ "hi" ] [ "hi" 3 complex-combination ] unit-test
[ "hi" ] [ 3 "hi" complex-combination ] unit-test

TUPLE: shit ;

M: shit complex-combination 2array ;
[ { T{ shit f } 5 } ] [ T{ shit f } 5 complex-combination ] unit-test

[ t ] [ \ complex-combination generic? >boolean ] unit-test

GENERIC: big-generic-test ( x -- x y )
M: fixnum big-generic-test "fixnum" ;
M: bignum big-generic-test "bignum" ;
M: ratio big-generic-test "ratio" ;
M: string big-generic-test "string" ;
M: shit big-generic-test "shit" ;

[ T{ shit f } "shit" ] [ T{ shit f } big-generic-test ] unit-test

[ t ] [ \ + math-generic? ] unit-test

! Regression
TUPLE: first-one ;
TUPLE: second-one ;
UNION: both first-one union-class ;

GENERIC: wii ( x -- y )
M: both wii drop 3 ;
M: second-one wii drop 4 ;
M: tuple-class wii drop 5 ;
M: integer wii drop 6 ;

[ 3 ] [ T{ first-one } wii ] unit-test

GENERIC: tag-and-f ( x -- x x )

M: fixnum tag-and-f 1 ;

M: bignum tag-and-f 2 ;

M: float tag-and-f 3 ;

M: f tag-and-f 4 ;

[ f 4 ] [ f tag-and-f ] unit-test

[ 3.4 3 ] [ 3.4 tag-and-f ] unit-test

! Issues with forget
GENERIC: generic-forget-test ( a -- b )

M: f generic-forget-test ;

[ ] [ \ f \ generic-forget-test method "m" set ] unit-test

[ ] [ [ "m" get forget ] with-compilation-unit ] unit-test

[ ] [ "IN: generic.tests M: f generic-forget-test ;" eval( -- ) ] unit-test

[ ] [ [ "m" get forget ] with-compilation-unit ] unit-test

[ f ] [ f generic-forget-test ] unit-test

! erg's regression
[ ] [
    <"
    IN: compiler.tests

    GENERIC: jeah ( a -- b )
    TUPLE: boii ;
    M: boii jeah ;
    GENERIC: jeah* ( a -- b )
    M: boii jeah* jeah ;
    "> eval( -- )

    <"
    IN: compiler.tests
    FORGET: boii
    "> eval( -- )
    
    <"
    IN: compiler.tests
    TUPLE: boii ;
    M: boii jeah ;
    "> eval( -- )
] unit-test

! call-next-method cache test
GENERIC: c-n-m-cache ( a -- b )

! Force it to be unoptimized
M: fixnum c-n-m-cache { } [ ] like call( -- ) call-next-method ;
M: integer c-n-m-cache 1 + ;
M: number c-n-m-cache ;

[ 3 ] [ 2 c-n-m-cache ] unit-test

[ ] [ [ M\ integer c-n-m-cache forget ] with-compilation-unit ] unit-test

[ 2 ] [ 2 c-n-m-cache ] unit-test

! Moving a method from one vocab to another doesn't always work
GENERIC: move-method-generic ( a -- b )

[ ] [ "IN: generic.tests.a USE: strings USE: generic.tests M: string move-method-generic ;" <string-reader> "move-method-test-1" parse-stream drop ] unit-test

[ ] [ "IN: generic.tests.b USE: strings USE: generic.tests M: string move-method-generic ;" <string-reader> "move-method-test-2" parse-stream drop ] unit-test

[ ] [ "IN: generic.tests.a" <string-reader> "move-method-test-1" parse-stream drop ] unit-test

[ { string } ] [ \ move-method-generic order ] unit-test
