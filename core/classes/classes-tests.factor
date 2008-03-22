USING: alien arrays definitions generic assocs hashtables io
kernel math namespaces parser prettyprint sequences strings
tools.test vectors words quotations classes
classes.private classes.union classes.mixin classes.predicate
vectors definitions source-files compiler.units ;
IN: classes.tests

H{ } "s" set

[ ] [ 1 2 "s" get push-at ] unit-test
[ 1 ] [ 2 "s" get at first ] unit-test
[ ] [ 1 2 "s" get pop-at ] unit-test
[ t ] [ 2 "s" get at empty? ] unit-test

[ object ] [ object object class-and ] unit-test
[ fixnum ] [ fixnum object class-and ] unit-test
[ fixnum ] [ object fixnum class-and ] unit-test
[ fixnum ] [ fixnum fixnum class-and ] unit-test
[ fixnum ] [ fixnum integer class-and ] unit-test
[ fixnum ] [ integer fixnum class-and ] unit-test
[ null ] [ vector fixnum class-and ] unit-test
[ number ] [ number object class-and ] unit-test
[ number ] [ object number class-and ] unit-test
[ null ] [ slice reversed class-and ] unit-test
[ null ] [ general-t \ f class-and ] unit-test
[ object ] [ general-t \ f class-or ] unit-test

TUPLE: first-one ;
TUPLE: second-one ;
UNION: both first-one union-class ;

[ t ] [ both tuple classes-intersect? ] unit-test
[ null ] [ vector virtual-sequence class-and ] unit-test
[ f ] [ vector virtual-sequence classes-intersect? ] unit-test

[ t ] [ \ fixnum \ integer class< ] unit-test
[ t ] [ \ fixnum \ fixnum class< ] unit-test
[ f ] [ \ integer \ fixnum class< ] unit-test
[ t ] [ \ integer \ object class< ] unit-test
[ f ] [ \ integer \ null class< ] unit-test
[ t ] [ \ null \ object class< ] unit-test

[ t ] [ \ generic \ word class< ] unit-test
[ f ] [ \ word \ generic class< ] unit-test

[ f ] [ \ reversed \ slice class< ] unit-test
[ f ] [ \ slice \ reversed class< ] unit-test

PREDICATE: word no-docs "documentation" word-prop not ;

UNION: no-docs-union no-docs integer ;

[ t ] [ no-docs no-docs-union class< ] unit-test
[ f ] [ no-docs-union no-docs class< ] unit-test

TUPLE: a ;
TUPLE: b ;
UNION: c a b ;

[ t ] [ \ c \ tuple class< ] unit-test
[ f ] [ \ tuple \ c class< ] unit-test

! DEFER: bah
! FORGET: bah
UNION: bah fixnum alien ;
[ bah ] [ \ bah? "predicating" word-prop ] unit-test

! Test redefinition of classes
UNION: union-1 fixnum float ;

GENERIC: generic-update-test ( x -- y )

M: union-1 generic-update-test drop "union-1" ;

[ f ] [ bignum union-1 class< ] unit-test
[ t ] [ union-1 number class< ] unit-test
[ "union-1" ] [ 1.0 generic-update-test ] unit-test

[ union-1 ] [ fixnum float class-or ] unit-test

"IN: classes.tests USE: math USE: arrays UNION: union-1 rational array ;" eval

[ t ] [ bignum union-1 class< ] unit-test
[ f ] [ union-1 number class< ] unit-test
[ "union-1" ] [ { 1.0 } generic-update-test ] unit-test

[ object ] [ fixnum float class-or ] unit-test

"IN: classes.tests USE: math PREDICATE: integer union-1 even? ;" eval

[ f ] [ union-1 union-class? ] unit-test
[ t ] [ union-1 predicate-class? ] unit-test
[ "union-1" ] [ 8 generic-update-test ] unit-test
[ -7 generic-update-test ] must-fail

! Test mixins
MIXIN: sequence-mixin

INSTANCE: array sequence-mixin
INSTANCE: vector sequence-mixin
INSTANCE: slice sequence-mixin

MIXIN: assoc-mixin

INSTANCE: hashtable assoc-mixin

GENERIC: collection-size ( x -- y )

M: sequence-mixin collection-size length ;

M: assoc-mixin collection-size assoc-size ;

[ t ] [ array sequence-mixin class< ] unit-test
[ t ] [ { 1 2 3 } sequence-mixin? ] unit-test
[ 3 ] [ { 1 2 3 } collection-size ] unit-test
[ f ] [ H{ { 1 2 } { 2 3 } } sequence-mixin? ] unit-test
[ t ] [ H{ { 1 2 } { 2 3 } } assoc-mixin? ] unit-test
[ 2 ] [ H{ { 1 2 } { 2 3 } } collection-size ] unit-test

! Test mixing in of new classes after the fact
MIXIN: mx1

INSTANCE: integer mx1

[ t ] [ integer mx1 class< ] unit-test
[ t ] [ mx1 integer class< ] unit-test
[ t ] [ mx1 number class< ] unit-test

"IN: classes.tests USE: arrays INSTANCE: array mx1" eval

[ t ] [ array mx1 class< ] unit-test
[ f ] [ mx1 number class< ] unit-test

[ mx1 ] [ array integer class-or ] unit-test

[ \ mx1 forget ] with-compilation-unit

[ f ] [ array integer class-or mx1 = ] unit-test

! Empty unions were causing problems
GENERIC: empty-union-test

UNION: empty-union-1 ;

M: empty-union-1 empty-union-test ;

UNION: empty-union-2 ;

M: empty-union-2 empty-union-test ;

! Redefining a class didn't update containing unions
UNION: redefine-bug-1 fixnum ;

UNION: redefine-bug-2 redefine-bug-1 quotation ;

[ t ] [ fixnum redefine-bug-2 class< ] unit-test
[ t ] [ quotation redefine-bug-2 class< ] unit-test
[ redefine-bug-2 ] [ fixnum quotation class-or ] unit-test

[ ] [ "IN: classes.tests USE: math UNION: redefine-bug-1 bignum ;" eval ] unit-test

[ t ] [ bignum redefine-bug-1 class< ] unit-test
[ f ] [ fixnum redefine-bug-2 class< ] unit-test
[ t ] [ bignum redefine-bug-2 class< ] unit-test
[ f ] [ fixnum quotation class-or redefine-bug-2 eq? ] unit-test
[ redefine-bug-2 ] [ bignum quotation class-or ] unit-test

! Another issue similar to the above
UNION: forget-class-bug-1 integer ;
UNION: forget-class-bug-2 forget-class-bug-1 dll ;

[
    \ forget-class-bug-1 forget
    \ forget-class-bug-2 forget
] with-compilation-unit

[ f ] [ forget-class-bug-1 typemap get values [ memq? ] with contains? ] unit-test

[ f ] [ forget-class-bug-2 typemap get values [ memq? ] with contains? ] unit-test

USE: io.streams.string

2 [
    [ "mixin-forget-test" forget-source ] with-compilation-unit
    
    [ ] [
        {
            "USING: sequences ;"
            "IN: classes.tests"
            "MIXIN: mixin-forget-test"
            "INSTANCE: sequence mixin-forget-test"
            "GENERIC: mixin-forget-test-g ( x -- y )"
            "M: mixin-forget-test mixin-forget-test-g ;"
        } "\n" join <string-reader> "mixin-forget-test"
        parse-stream drop
    ] unit-test
    
    [ { } ] [ { } "mixin-forget-test-g" "classes.tests" lookup execute ] unit-test
    [ H{ } "mixin-forget-test-g" "classes.tests" lookup execute ] must-fail
    
    [ ] [
        {
            "USING: hashtables ;"
            "IN: classes.tests"
            "MIXIN: mixin-forget-test"
            "INSTANCE: hashtable mixin-forget-test"
            "GENERIC: mixin-forget-test-g ( x -- y )"
            "M: mixin-forget-test mixin-forget-test-g ;"
        } "\n" join <string-reader> "mixin-forget-test"
        parse-stream drop
    ] unit-test
    
    [ { } "mixin-forget-test-g" "classes.tests" lookup execute ] must-fail
    [ H{ } ] [ H{ } "mixin-forget-test-g" "classes.tests" lookup execute ] unit-test
] times

! Method flattening interfered with mixin update
MIXIN: flat-mx-1
TUPLE: flat-mx-1-1 ; INSTANCE: flat-mx-1-1 flat-mx-1
TUPLE: flat-mx-1-2 ; INSTANCE: flat-mx-1-2 flat-mx-1
TUPLE: flat-mx-1-3 ; INSTANCE: flat-mx-1-3 flat-mx-1
TUPLE: flat-mx-1-4 ; INSTANCE: flat-mx-1-4 flat-mx-1
MIXIN: flat-mx-2     INSTANCE: flat-mx-2 flat-mx-1
TUPLE: flat-mx-2-1 ; INSTANCE: flat-mx-2-1 flat-mx-2

[ t ] [ T{ flat-mx-2-1 } flat-mx-1? ] unit-test

! Test generic see and parsing
[ "USING: alien math ;\nIN: classes.tests\nUNION: bah fixnum alien ;\n" ]
[ [ \ bah see ] with-string-writer ] unit-test
