USING: definitions generic kernel kernel.private math
math.constants parser sequences tools.test words assocs
namespaces quotations sequences.private classes continuations
generic.standard effects tuples tuples.private arrays vectors
strings ;
IN: temporary

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
"IN: temporary TUPLE: point x y z ; do-parse-hook" eval

[ 100 ] [ "p" get point-x ] unit-test
[ 200 ] [ "p" get point-y ] unit-test
[ f ] [ "p" get "point-z" "temporary" lookup execute ] unit-test

300 "p" get "set-point-z" "temporary" lookup execute

"IN: temporary TUPLE: point z y ; do-parse-hook" eval

[ "p" get point-x ] unit-test-fails
[ 200 ] [ "p" get point-y ] unit-test
[ 300 ] [ "p" get "point-z" "temporary" lookup execute ] unit-test

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

[ ] [ "IN: temporary  SYMBOL: #x  TUPLE: #x ;" eval ] unit-test

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
[ t ] [ [ t length ] catch no-method-object ] unit-test

[ "<constructor-test>" ]
[ "TUPLE: constructor-test ; C: <constructor-test> constructor-test" eval word word-name ] unit-test

TUPLE: size-test a b c d ;

[ t ] [
    T{ size-test } array-capacity
    size-test tuple-size =
] unit-test

GENERIC: <yo-momma>

TUPLE: yo-momma ;

"IN: temporary C: <yo-momma> yo-momma" eval

[ f ] [ \ <yo-momma> generic? ] unit-test

! Test forget
[ t ] [ \ yo-momma class? ] unit-test
[ ] [ \ yo-momma forget ] unit-test
[ f ] [ \ yo-momma typemap get values memq? ] unit-test

[ f ] [ \ yo-momma interned? ] unit-test

TUPLE: loc-recording ;

[ f ] [ \ loc-recording where not ] unit-test

! 'forget' wasn't robust enough

TUPLE: forget-robustness ;

GENERIC: forget-robustness-generic

M: forget-robustness forget-robustness-generic ;

M: integer forget-robustness-generic ;

[ ] [ \ forget-robustness-generic forget ] unit-test
[ ] [ \ forget-robustness forget ] unit-test
[ ] [ { forget-robustness forget-robustness-generic } forget ] unit-test

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
    "IN: temporary C: <not-a-tuple-class> not-a-tuple-class"
    eval
] unit-test-fails

[ t ] [
    "not-a-tuple-class" "temporary" lookup symbol?
] unit-test

! Missing check
[ not-a-tuple-class construct-boa ] unit-test-fails
[ not-a-tuple-class construct-empty ] unit-test-fails

! Reshaping bug. It's only an issue when optimizer compiler is
! enabled.
parse-hook get [
    TUPLE: erg's-reshape-problem a b c ;

    C: <erg's-reshape-problem> erg's-reshape-problem

    [ ] [
        "IN: temporary TUPLE: erg's-reshape-problem a b c d ;" eval
    ] unit-test


    [ 1 2 ] [
        ! <erg's-reshape-problem> hasn't been recompiled yet, so
        ! we just created a tuple using an obsolete layout
        1 2 3 <erg's-reshape-problem>

        ! that's ok, but... this shouldn't fail:
        "IN: temporary TUPLE: erg's-reshape-problem a b d c ;" eval

        { erg's-reshape-problem-a erg's-reshape-problem-b }
        get-slots
    ] unit-test
] when

! We want to make sure constructors are recompiled when
! tuples are reshaped
: cons-test-1 \ erg's-reshape-problem construct-empty ;
: cons-test-2 \ erg's-reshape-problem construct-boa ;
: cons-test-3
    { erg's-reshape-problem-a }
    \ erg's-reshape-problem construct ;

"IN: temporary TUPLE: erg's-reshape-problem a b c d e f ;" eval

[ t ] [
    {
        <erg's-reshape-problem>
        cons-test-1
        cons-test-2
        cons-test-3
    } [ changed-words get key? ] all?
] unit-test
