USING: alien arrays definitions generic generic.standard
generic.math assocs hashtables io kernel math namespaces parser
prettyprint sequences strings tools.test vectors words
quotations classes continuations layouts classes.union sorting ;
IN: temporary

GENERIC: foobar ( x -- y )
M: object foobar drop "Hello world" ;
M: fixnum foobar drop "Goodbye cruel world" ;

GENERIC: class-of ( x -- y )

M: fixnum class-of drop "fixnum" ;
M: word   class-of drop "word"   ;

[ "fixnum" ] [ 5 class-of ] unit-test
[ "word" ] [ \ class-of class-of ] unit-test
[ 3.4 class-of ] unit-test-fails

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
UNION: funnies quotation ratio complex ;

GENERIC: funny ( x -- y )
M: funnies funny drop 2 ;
M: object funny drop 0 ;

[ 2 ] [ [ { } ] funny ] unit-test
[ 0 ] [ { } funny ] unit-test

PREDICATE: funnies very-funny number? ;

GENERIC: gooey ( x -- y )
M: very-funny gooey sq ;

[ 1/4 ] [ 1/2 gooey ] unit-test

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
"IN: temporary GENERIC: unhappy ( x -- x )" eval
[
    "IN: temporary M: dictionary unhappy ;" eval
] unit-test-fails
[ ] [ "IN: temporary GENERIC: unhappy ( x -- x )" eval ] unit-test

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

[ "SYMBOL: not-a-class C: not-a-class ;" parse ] unit-test-fails

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
[ T{ no-method f 1.0 my-hook } ] [
    1.0 my-var set [ my-hook ] catch
] unit-test

GENERIC: tag-and-f ( x -- x x )

M: fixnum tag-and-f 1 ;

M: bignum tag-and-f 2 ;

M: float tag-and-f 3 ;

M: f tag-and-f 4 ;

[ f 4 ] [ f tag-and-f ] unit-test

[ 3.4 3 ] [ 3.4 tag-and-f ] unit-test

! define-class hashing issue
TUPLE: debug-combination ;

M: debug-combination perform-combination
    drop
    order [ dup class-hashes ] { } map>assoc sort-keys
    1quotation ;

SYMBOL: redefinition-test-generic

redefinition-test-generic T{ debug-combination } define-generic

TUPLE: redefinition-test-tuple ;

"IN: temporary M: redefinition-test-tuple redefinition-test-generic ;" eval

[ t ] [
    [
        redefinition-test-generic ,
        "IN: temporary TUPLE: redefinition-test-tuple ;" eval
        redefinition-test-generic ,
    ] { } make all-equal?
] unit-test
