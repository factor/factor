USING: definitions generic kernel kernel.private math
math.constants parser sequences tools.test words assocs
namespaces quotations sequences.private classes continuations
generic.standard effects tuples tuples.private arrays vectors
strings compiler.units ;
IN: tuples.tests

[ t ] [ \ tuple-class \ class class< ] unit-test
[ f ] [ \ class \ tuple-class class< ] unit-test

TUPLE: rect x y w h ;
: <rect> rect construct-boa ;

: move ( x rect -- )
    [ rect-x + ] keep set-rect-x ;

[ f ] [ 10 20 30 40 <rect> dup clone 5 swap [ move ] keep = ] unit-test

[ t ] [ 10 20 30 40 <rect> dup clone 0 swap [ move ] keep = ] unit-test

GENERIC: delegation-test
M: object delegation-test drop 3 ;
TUPLE: quux-tuple ;
: <quux-tuple> quux-tuple construct-empty ;
M: quux-tuple delegation-test drop 4 ;
TUPLE: quuux-tuple ;
: <quuux-tuple> { set-delegate } quuux-tuple construct ;

[ 3 ] [ <quux-tuple> <quuux-tuple> delegation-test ] unit-test

GENERIC: delegation-test-2
TUPLE: quux-tuple-2 ;
: <quux-tuple-2> quux-tuple-2 construct-empty ;
M: quux-tuple-2 delegation-test-2 drop 4 ;
TUPLE: quuux-tuple-2 ;
: <quuux-tuple-2> { set-delegate } quuux-tuple-2 construct ;

[ 4 ] [ <quux-tuple-2> <quuux-tuple-2> delegation-test-2 ] unit-test

! Make sure we handle changing shapes!
TUPLE: point x y ;

C: <point> point

100 200 <point> "p" set

! Use eval to sequence parsing explicitly
"IN: tuples.tests TUPLE: point x y z ;" eval

[ 100 ] [ "p" get point-x ] unit-test
[ 200 ] [ "p" get point-y ] unit-test
[ f ] [ "p" get "point-z" "tuples.tests" lookup execute ] unit-test

300 "p" get "set-point-z" "tuples.tests" lookup execute

"IN: tuples.tests TUPLE: point z y ;" eval

[ "p" get point-x ] must-fail
[ 200 ] [ "p" get point-y ] unit-test
[ 300 ] [ "p" get "point-z" "tuples.tests" lookup execute ] unit-test

TUPLE: predicate-test ;

C: <predicate-test> predicate-test

: predicate-test drop f ;

[ t ] [ <predicate-test> predicate-test? ] unit-test

PREDICATE: tuple silly-pred
    class \ rect = ;

GENERIC: area
M: silly-pred area dup rect-w swap rect-h * ;

TUPLE: circle radius ;
M: circle area circle-radius sq pi * ;

[ 200 ] [ T{ rect f 0 0 10 20 } area ] unit-test

! Hashcode breakage
TUPLE: empty ;

C: <empty> empty

[ t ] [ <empty> hashcode fixnum? ] unit-test

TUPLE: delegate-clone ;

[ T{ delegate-clone T{ empty f } } ]
[ T{ delegate-clone T{ empty f } } clone ] unit-test

[ t ] [ \ null \ delegate-clone class< ] unit-test
[ f ] [ \ object \ delegate-clone class< ] unit-test
[ f ] [ \ object \ delegate-clone class< ] unit-test
[ t ] [ \ delegate-clone \ tuple class< ] unit-test
[ f ] [ \ tuple \ delegate-clone class< ] unit-test

! Compiler regression
[ t length ] [ no-method-object t eq? ] must-fail-with

[ "<constructor-test>" ]
[ "TUPLE: constructor-test ; C: <constructor-test> constructor-test" eval word word-name ] unit-test

TUPLE: size-test a b c d ;

[ t ] [
    T{ size-test } array-capacity
    size-test tuple-size =
] unit-test

GENERIC: <yo-momma>

TUPLE: yo-momma ;

"IN: tuples.tests C: <yo-momma> yo-momma" eval

[ f ] [ \ <yo-momma> generic? ] unit-test

! Test forget
[
    [ t ] [ \ yo-momma class? ] unit-test
    [ ] [ \ yo-momma forget ] unit-test
    [ f ] [ \ yo-momma typemap get values memq? ] unit-test

    [ f ] [ \ yo-momma crossref get at ] unit-test
] with-compilation-unit

TUPLE: loc-recording ;

[ f ] [ \ loc-recording where not ] unit-test

! 'forget' wasn't robust enough

TUPLE: forget-robustness ;

GENERIC: forget-robustness-generic

M: forget-robustness forget-robustness-generic ;

M: integer forget-robustness-generic ;

[
    [ ] [ \ forget-robustness-generic forget ] unit-test
    [ ] [ \ forget-robustness forget ] unit-test
    [ ] [ { forget-robustness forget-robustness-generic } forget ] unit-test
] with-compilation-unit

! rapido found this one
GENERIC# m1 0 ( s n -- n )
GENERIC# m2 1 ( s n -- v )

TUPLE: t1 ;

M: t1 m1 drop ;
M: t1 m2 nip ;

TUPLE: t2 ;

M: t2 m1 drop ;
M: t2 m2 nip ;

TUPLE: t3 ;

M: t3 m1 drop ;
M: t3 m2 nip ;

TUPLE: t4 ;

M: t4 m1 drop ;
M: t4 m2 nip ;

C: <t4> t4

[ 1 ] [ 1 <t4> m1 ] unit-test
[ 1 ] [ <t4> 1 m2 ] unit-test

! another combination issue
GENERIC: silly

UNION: my-union slice repetition column array vector reversed ;

M: my-union silly "x" ;

M: array silly "y" ;

M: column silly "fdsfds" ;

M: repetition silly "zzz" ;

M: reversed silly "zz" ;

M: slice silly "tt" ;

M: string silly "t" ;

M: vector silly "z" ;

[ "zz" ] [ 123 <reversed> silly nip ] unit-test

! Typo
SYMBOL: not-a-tuple-class

[
    "IN: tuples.tests C: <not-a-tuple-class> not-a-tuple-class"
    eval
] must-fail

[ t ] [
    "not-a-tuple-class" "tuples.tests" lookup symbol?
] unit-test

! Missing check
[ not-a-tuple-class construct-boa ] must-fail
[ not-a-tuple-class construct-empty ] must-fail

TUPLE: erg's-reshape-problem a b c d ;

C: <erg's-reshape-problem> erg's-reshape-problem

! We want to make sure constructors are recompiled when
! tuples are reshaped
: cons-test-1 \ erg's-reshape-problem construct-empty ;
: cons-test-2 \ erg's-reshape-problem construct-boa ;
: cons-test-3
    { set-erg's-reshape-problem-a }
    \ erg's-reshape-problem construct ;

"IN: tuples.tests TUPLE: erg's-reshape-problem a b c d e f ;" eval

[ ] [ 1 2 3 4 5 6 cons-test-2 "a" set ] unit-test

[ t ] [ cons-test-1 array-capacity "a" get array-capacity = ] unit-test

[ t ] [ 1 cons-test-3 array-capacity "a" get array-capacity = ] unit-test

[
    "IN: tuples.tests SYMBOL: not-a-class C: <not-a-class> not-a-class" eval
] [ [ no-tuple-class? ] is? ] must-fail-with

! Hardcore unit tests
USE: threads

\ thread "slot-names" word-prop "slot-names" set

[ ] [
    [
        \ thread { "xxx" } "slot-names" get append
        define-tuple-class
    ] with-compilation-unit

    [ 1337 sleep ] "Test" spawn drop

    [
        \ thread "slot-names" get
        define-tuple-class
    ] with-compilation-unit
] unit-test

USE: vocabs

\ vocab "slot-names" word-prop "slot-names" set

[ ] [
    [
        \ vocab { "xxx" } "slot-names" get append
        define-tuple-class
    ] with-compilation-unit

    all-words drop

    [
        \ vocab "slot-names" get
        define-tuple-class
    ] with-compilation-unit
] unit-test
