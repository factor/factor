IN: temporary
USE: hashtables
USE: namespaces
USE: generic
USE: test
USE: kernel
USE: math
USE: words
USE: lists
USE: vectors
USE: alien
USE: sequences
USE: prettyprint
USE: io
USE: parser
USE: strings

GENERIC: class-of

M: fixnum class-of drop "fixnum" ;
M: word   class-of drop "word"   ;
M: cons   class-of drop "cons"   ;

[ "fixnum" ] [ 5 class-of ] unit-test
[ "cons" ] [ [ 1 2 3 ] class-of ] unit-test
[ "word" ] [ \ class-of class-of ] unit-test
[ 3.4 class-of ] unit-test-fails

GENERIC: foobar
M: object foobar drop "Hello world" ;
M: fixnum foobar drop "Goodbye cruel world" ;

[ "Hello world" ] [ 4 foobar foobar ] unit-test
[ "Goodbye cruel world" ] [ 4 foobar ] unit-test

GENERIC: bool>str
M: t bool>str drop "true" ;
M: f bool>str drop "false" ;

: str>bool
    [
        [[ "true" t ]]
        [[ "false" f ]]
    ] assoc ;

[ t ] [ t bool>str str>bool ] unit-test
[ f ] [ f bool>str str>bool ] unit-test

PREDICATE: cons nonempty-list list? ;

GENERIC: funny-length
M: cons funny-length drop 0 ;
M: nonempty-list funny-length length ;

[ 0 ] [ [[ 1 [[ 2 3 ]] ]] funny-length ] unit-test
[ 3 ] [ [ 1 2 3 ] funny-length ] unit-test
[ "hello" funny-length ] unit-test-fails

! Testing method sorting
GENERIC: sorting-test
M: fixnum sorting-test drop "fixnum" ;
M: object sorting-test drop "object" ;
[ "fixnum" ] [ 3 sorting-test ] unit-test
[ "object" ] [ f sorting-test ] unit-test

! Testing unions
UNION: funnies cons ratio complex ;

GENERIC: funny
M: funnies funny drop 2 ;
M: object funny drop 0 ;

[ 2 ] [ [ { } ] funny ] unit-test
[ 0 ] [ { } funny ] unit-test

PREDICATE: funnies very-funny number? ;

GENERIC: gooey
M: very-funny gooey sq ;

[ 1/4 ] [ 1/2 gooey ] unit-test

[ object ] [ object object class-and ] unit-test
[ fixnum ] [ fixnum object class-and ] unit-test
[ fixnum ] [ object fixnum class-and ] unit-test
[ fixnum ] [ fixnum fixnum class-and ] unit-test
[ fixnum ] [ fixnum integer class-and ] unit-test
[ fixnum ] [ integer fixnum class-and ] unit-test
[ null ] [ vector fixnum class-and ] unit-test
[ integer ] [ fixnum bignum class-or ] unit-test
[ integer ] [ fixnum integer class-or ] unit-test
[ rational ] [ ratio integer class-or ] unit-test
[ number ] [ number object class-and ] unit-test
[ number ] [ object number class-and ] unit-test

[ cons ] [ [ 1 2 ] class ] unit-test

[ t ] [ \ fixnum \ integer class< ] unit-test
[ t ] [ \ fixnum \ fixnum class< ] unit-test
[ f ] [ \ integer \ fixnum class< ] unit-test
[ t ] [ \ integer \ object class< ] unit-test
[ f ] [ \ integer \ null class< ] unit-test
[ t ] [ \ null \ object class< ] unit-test
[ t ] [ \ list \ general-list class< ] unit-test
[ t ] [ \ list \ object class< ] unit-test
[ t ] [ \ null \ list class< ] unit-test

[ t ] [ \ generic \ compound class< ] unit-test
[ f ] [ \ compound \ generic class< ] unit-test

[ f ] [ \ cons \ list class< ] unit-test
[ f ] [ \ list \ cons class< ] unit-test

[ f ] [ \ mirror \ slice class< ] unit-test
[ f ] [ \ slice \ mirror class< ] unit-test

DEFER: bah
FORGET: bah
UNION: bah fixnum alien ;
[ bah ] [ fixnum alien class-or ] unit-test
[ bah ] [ \ bah? "predicating" word-prop ] unit-test

DEFER: complement-test
FORGET: complement-test
GENERIC: complement-test

M: f         complement-test drop "f" ;
M: general-t complement-test drop "general-t" ;

[ "general-t" ] [ 5 complement-test ] unit-test
[ "f" ] [ f complement-test ] unit-test

GENERIC: empty-method-test
M: object empty-method-test ;
TUPLE: for-arguments-sake ;

M: for-arguments-sake empty-method-test drop "Hi" ;

TUPLE: another-one ;

[ "Hi" ] [ <for-arguments-sake> empty-method-test empty-method-test ] unit-test
[ << another-one f >> ] [ <another-one> empty-method-test ] unit-test

! Test generic see and parsing
[ "IN: temporary\nSYMBOL: bah \nUNION: bah fixnum alien ;\n" ]
[ [ \ bah see ] string-out ] unit-test

[ t ] [
    DEFER: not-fixnum
    "IN: temporary\nSYMBOL: not-fixnum \nCOMPLEMENT: not-fixnum fixnum\n"
    dup eval
    [ \ not-fixnum see ] string-out =
] unit-test

! Weird bug
GENERIC: stack-underflow
M: object stack-underflow 2drop ;
M: word stack-underflow 2drop ;

GENERIC: testing
M: cons testing 2 ;
M: f testing 3 ;
M: sequence testing 4 ;
[ [ 1 2 ] 2 ] [ [ 1 2 ] testing ] unit-test

GENERIC: union-containment
M: integer union-containment drop 1 ;
M: number union-containment drop 2 ;

[ 1 ] [ 1 union-containment ] unit-test
[ 2 ] [ 1.0 union-containment ] unit-test

! Testing recovery from bad method definitions
"GENERIC: unhappy" eval
[ "M: vocabularies unhappy ;" eval ] unit-test-fails
[ ] [ "GENERIC: unhappy" eval ] unit-test

G: complex-combination [ over ] [ standard-combination ] ;
M: string complex-combination drop ;
M: object complex-combination nip ;

[ "hi" ] [ "hi" 3 complex-combination ] unit-test
[ "hi" ] [ 3 "hi" complex-combination ] unit-test

TUPLE: shit ;

M: shit complex-combination cons ;
[ [[ << shit f >> 5 ]] ] [ << shit f >> 5 complex-combination ] unit-test

[ t ] [ \ complex-combination generic? >boolean ] unit-test

! TUPLE: delegating-small-generic ;
! G: small-delegation [ over ] [ type ] ;
! M: shit small-delegation cons ;
! 
! [ [[ << shit f >> 5 ]] ] [ << delegating-small-generic << shit f >> >> 5 small-delegation ] unit-test

GENERIC: big-generic-test
M: fixnum big-generic-test "fixnum" ;
M: bignum big-generic-test "bignum" ;
M: ratio big-generic-test "ratio" ;
M: string big-generic-test "string" ;
M: shit big-generic-test "shit" ;

TUPLE: delegating ;

[ << shit f >> "shit" ] [ << shit f >> big-generic-test ] unit-test
[ << shit f >> "shit" ] [ << delegating << shit f >> >> big-generic-test ] unit-test

[ t ] [ \ = simple-generic? ] unit-test
[ f ] [ \ each simple-generic? ] unit-test
[ f ] [ \ object simple-generic? ] unit-test
[ t ] [ \ + 2generic? ] unit-test
