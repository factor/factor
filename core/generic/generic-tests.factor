USING: alien arrays definitions generic generic.standard
generic.math assocs hashtables io kernel math namespaces parser
prettyprint sequences strings tools.test vectors words
quotations classes classes.algebra continuations layouts
classes.union sorting compiler.units ;
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

GENERIC: bool>str ( x -- y )
M: general-t bool>str drop "true" ;
M: f bool>str drop "false" ;

: str>bool
    H{
        { "true" t }
        { "false" f }
    } at ;

[ t ] [ t bool>str str>bool ] unit-test
[ f ] [ f bool>str str>bool ] unit-test

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

DEFER: complement-test
FORGET: complement-test
GENERIC: complement-test ( x -- y )

M: f         complement-test drop "f" ;
M: general-t complement-test drop "general-t" ;

[ "general-t" ] [ 5 complement-test ] unit-test
[ "f" ] [ f complement-test ] unit-test

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
"IN: generic.tests GENERIC: unhappy ( x -- x )" eval
[
    "IN: generic.tests M: dictionary unhappy ;" eval
] must-fail
[ ] [ "IN: generic.tests GENERIC: unhappy ( x -- x )" eval ] unit-test

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

TUPLE: delegating ;

[ T{ shit f } "shit" ] [ T{ shit f } big-generic-test ] unit-test
[ T{ shit f } "shit" ] [ T{ delegating T{ shit f } } big-generic-test ] unit-test

[ t ] [ \ + math-generic? ] unit-test

! Test math-combination
[ [ [ >float ] dip ] ] [ \ real \ float math-upgrade ] unit-test
[ [ >float ] ] [ \ float \ real math-upgrade ] unit-test
[ [ [ >bignum ] dip ] ] [ \ fixnum \ bignum math-upgrade ] unit-test
[ [ >float ] ] [ \ float \ integer math-upgrade ] unit-test
[ number ] [ \ number \ float math-class-max ] unit-test
[ float ] [ \ real \ float math-class-max ] unit-test
[ fixnum ] [ \ fixnum \ null math-class-max ] unit-test

[ t ] [ { hashtable equal? } method-spec? ] unit-test
[ f ] [ { word = } method-spec? ] unit-test

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

! Hooks
SYMBOL: my-var
HOOK: my-hook my-var ( -- x )

M: integer my-hook "an integer" ;
M: string my-hook "a string" ;

[ "an integer" ] [ 3 my-var set my-hook ] unit-test
[ "a string" ] [ my-hook my-var set my-hook ] unit-test
[ 1.0 my-var set my-hook ] [ T{ no-method f 1.0 my-hook } = ] must-fail-with

GENERIC: tag-and-f ( x -- x x )

M: fixnum tag-and-f 1 ;

M: bignum tag-and-f 2 ;

M: float tag-and-f 3 ;

M: f tag-and-f 4 ;

[ f 4 ] [ f tag-and-f ] unit-test

[ 3.4 3 ] [ 3.4 tag-and-f ] unit-test

! define-class hashing issue
TUPLE: debug-combination ;

M: debug-combination make-default-method
    2drop [ "Oops" throw ] ;

M: debug-combination perform-combination
    drop
    order [ dup class-hashes ] { } map>assoc sort-keys
    1quotation ;

SYMBOL: redefinition-test-generic

[
    redefinition-test-generic
    T{ debug-combination }
    define-generic
] with-compilation-unit

TUPLE: redefinition-test-tuple ;

"IN: generic.tests M: redefinition-test-tuple redefinition-test-generic ;" eval

[ t ] [
    [
        redefinition-test-generic ,
        "IN: generic.tests TUPLE: redefinition-test-tuple ;" eval
        redefinition-test-generic ,
    ] { } make all-equal?
] unit-test

! Issues with forget
GENERIC: generic-forget-test-1

M: integer generic-forget-test-1 / ;

[ t ] [
    \ / usage [ word? ] subset
    [ word-name "generic-forget-test-1/integer" = ] contains?
] unit-test

[ ] [
    [ \ generic-forget-test-1 forget ] with-compilation-unit
] unit-test

[ f ] [
    \ / usage [ word? ] subset
    [ word-name "generic-forget-test-1/integer" = ] contains?
] unit-test

GENERIC: generic-forget-test-2

M: sequence generic-forget-test-2 = ;

[ t ] [
    \ = usage [ word? ] subset
    [ word-name "generic-forget-test-2/sequence" = ] contains?
] unit-test

[ ] [
    [ { sequence generic-forget-test-2 } forget ] with-compilation-unit
] unit-test

[ f ] [
    \ = usage [ word? ] subset
    [ word-name "generic-forget-test-2/sequence" = ] contains?
] unit-test

GENERIC: generic-forget-test-3

M: f generic-forget-test-3 ;

[ ] [ \ f \ generic-forget-test-3 method "m" set ] unit-test

[ ] [ [ "m" get forget ] with-compilation-unit ] unit-test

[ ] [ "IN: generic.tests M: f generic-forget-test-3 ;" eval ] unit-test

[ ] [ [ "m" get forget ] with-compilation-unit ] unit-test

[ f ] [ f generic-forget-test-3 ] unit-test

: a-word ;

GENERIC: a-generic

M: integer a-generic a-word ;

[ ] [ \ integer \ a-generic method "m" set ] unit-test

[ t ] [ "m" get \ a-word usage memq? ] unit-test

[ ] [ "IN: generic.tests : a-generic ;" eval ] unit-test

[ f ] [ "m" get \ a-word usage memq? ] unit-test
