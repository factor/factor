USING: definitions generic kernel kernel.private math
math.constants parser sequences tools.test words assocs
namespaces quotations sequences.private classes continuations
generic.standard effects classes.tuple classes.tuple.private
arrays vectors strings compiler.units accessors classes.algebra
calendar prettyprint io.streams.string splitting inspector ;
IN: classes.tuple.tests

TUPLE: rect x y w h ;
: <rect> rect boa ;

: move ( x rect -- rect )
    [ + ] change-x ;

[ f ] [ 10 20 30 40 <rect> dup clone 5 swap move = ] unit-test

[ t ] [ 10 20 30 40 <rect> dup clone 0 swap move = ] unit-test

! Make sure we handle tuple class redefinition
TUPLE: redefinition-test ;

C: <redefinition-test> redefinition-test

<redefinition-test> "redefinition-test" set

[ t ] [ "redefinition-test" get redefinition-test? ] unit-test

"IN: classes.tuple.tests TUPLE: redefinition-test ;" eval

[ t ] [ "redefinition-test" get redefinition-test? ] unit-test

! Make sure we handle changing shapes!
TUPLE: point x y ;

C: <point> point

[ ] [ 100 200 <point> "p" set ] unit-test

! Use eval to sequence parsing explicitly
[ ] [ "IN: classes.tuple.tests TUPLE: point x y z ;" eval ] unit-test

[ 100 ] [ "p" get x>> ] unit-test
[ 200 ] [ "p" get y>> ] unit-test
[ f ] [ "p" get "z>>" "accessors" lookup execute ] unit-test

[ ] [ "p" get 300 ">>z" "accessors" lookup execute drop ] unit-test

[ 4 ] [ "p" get tuple-size ] unit-test

[ 300 ] [ "p" get "z>>" "accessors" lookup execute ] unit-test

[ ] [ "IN: classes.tuple.tests TUPLE: point z y ;" eval ] unit-test

[ 3 ] [ "p" get tuple-size ] unit-test

[ "p" get x>> ] must-fail
[ 200 ] [ "p" get y>> ] unit-test
[ 300 ] [ "p" get "z>>" "accessors" lookup execute ] unit-test

TUPLE: predicate-test ;

C: <predicate-test> predicate-test

: predicate-test drop f ;

[ t ] [ <predicate-test> predicate-test? ] unit-test

PREDICATE: silly-pred < tuple
    class \ rect = ;

GENERIC: area
M: silly-pred area dup w>> swap h>> * ;

TUPLE: circle radius ;
M: circle area radius>> sq pi * ;

[ 200 ] [ T{ rect f 0 0 10 20 } area ] unit-test

! Hashcode breakage
TUPLE: empty ;

C: <empty> empty

[ t ] [ <empty> hashcode fixnum? ] unit-test

! Compiler regression
[ t length ] [ object>> t eq? ] must-fail-with

[ "<constructor-test>" ]
[ "TUPLE: constructor-test ; C: <constructor-test> constructor-test" eval word word-name ] unit-test

TUPLE: size-test a b c d ;

[ t ] [
    T{ size-test } tuple-size
    size-test tuple-size =
] unit-test

GENERIC: <yo-momma>

TUPLE: yo-momma ;

"IN: classes.tuple.tests C: <yo-momma> yo-momma" eval

[ f ] [ \ <yo-momma> generic? ] unit-test

! Test forget
[
    [ t ] [ \ yo-momma class? ] unit-test
    [ ] [ \ yo-momma forget ] unit-test
    [ f ] [ \ yo-momma update-map get values memq? ] unit-test

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
    "IN: classes.tuple.tests C: <not-a-tuple-class> not-a-tuple-class"
    eval
] must-fail

[ t ] [
    "not-a-tuple-class" "classes.tuple.tests" lookup symbol?
] unit-test

! Missing check
[ not-a-tuple-class boa ] must-fail
[ not-a-tuple-class new ] must-fail

TUPLE: erg's-reshape-problem a b c d ;

C: <erg's-reshape-problem> erg's-reshape-problem

! We want to make sure constructors are recompiled when
! tuples are reshaped
: cons-test-1 \ erg's-reshape-problem new ;
: cons-test-2 \ erg's-reshape-problem boa ;

"IN: classes.tuple.tests TUPLE: erg's-reshape-problem a b c d e f ;" eval

[ ] [ 1 2 3 4 5 6 cons-test-2 "a" set ] unit-test

[ t ] [ cons-test-1 tuple-size "a" get tuple-size = ] unit-test

[
    "IN: classes.tuple.tests SYMBOL: not-a-class C: <not-a-class> not-a-class" eval
] [ error>> no-tuple-class? ] must-fail-with

! Inheritance
TUPLE: computer cpu ram ;
C: <computer> computer

[ "TUPLE: computer cpu ram ;" ] [
    [ \ computer see ] with-string-writer string-lines second
] unit-test

TUPLE: laptop < computer battery ;
C: <laptop> laptop

[ t ] [ laptop tuple-class? ] unit-test
[ t ] [ laptop tuple class< ] unit-test
[ t ] [ laptop computer class< ] unit-test
[ t ] [ laptop computer classes-intersect? ] unit-test

[ ] [ "Pentium" 128 3 hours <laptop> "laptop" set ] unit-test
[ t ] [ "laptop" get laptop? ] unit-test
[ t ] [ "laptop" get computer? ] unit-test
[ t ] [ "laptop" get tuple? ] unit-test

: test-laptop-slot-values
    [ laptop ] [ "laptop" get class ] unit-test
    [ "Pentium" ] [ "laptop" get cpu>> ] unit-test
    [ 128 ] [ "laptop" get ram>> ] unit-test
    [ t ] [ "laptop" get battery>> 3 hours = ] unit-test ;

test-laptop-slot-values

[ laptop ] [
    "laptop" get tuple-layout
    dup layout-echelon swap
    layout-superclasses nth
] unit-test

[ "TUPLE: laptop < computer battery ;" ] [
    [ \ laptop see ] with-string-writer string-lines second
] unit-test

[ { tuple computer laptop } ] [ laptop superclasses ] unit-test

TUPLE: server < computer rackmount ;
C: <server> server

[ t ] [ server tuple-class? ] unit-test
[ t ] [ server tuple class< ] unit-test
[ t ] [ server computer class< ] unit-test
[ t ] [ server computer classes-intersect? ] unit-test

[ ] [ "PowerPC" 64 "1U" <server> "server" set ] unit-test
[ t ] [ "server" get server? ] unit-test
[ t ] [ "server" get computer? ] unit-test
[ t ] [ "server" get tuple? ] unit-test

: test-server-slot-values
    [ server ] [ "server" get class ] unit-test
    [ "PowerPC" ] [ "server" get cpu>> ] unit-test
    [ 64 ] [ "server" get ram>> ] unit-test
    [ "1U" ] [ "server" get rackmount>> ] unit-test ;

test-server-slot-values

[ f ] [ "server" get laptop? ] unit-test
[ f ] [ "laptop" get server? ] unit-test

[ f ] [ server laptop class< ] unit-test
[ f ] [ laptop server class< ] unit-test
[ f ] [ laptop server classes-intersect? ] unit-test

[ f ] [ 1 2 <computer> laptop? ] unit-test
[ f ] [ \ + server? ] unit-test

[ "TUPLE: server < computer rackmount ;" ] [
    [ \ server see ] with-string-writer string-lines second
] unit-test

[
    "IN: classes.tuple.tests TUPLE: bad-superclass < word ;" eval
] must-fail

! Dynamically changing inheritance hierarchy
TUPLE: electronic-device ;

[ ] [ "IN: classes.tuple.tests TUPLE: computer < electronic-device cpu ram ;" eval ] unit-test

[ f ] [ electronic-device laptop class< ] unit-test
[ t ] [ server electronic-device class< ] unit-test
[ t ] [ laptop server class-or electronic-device class< ] unit-test

[ t ] [ "laptop" get electronic-device? ] unit-test
[ t ] [ "laptop" get computer? ] unit-test
[ t ] [ "laptop" get laptop? ] unit-test
[ f ] [ "laptop" get server? ] unit-test

[ t ] [ "server" get electronic-device? ] unit-test
[ t ] [ "server" get computer? ] unit-test
[ f ] [ "server" get laptop? ] unit-test
[ t ] [ "server" get server? ] unit-test

[ ] [ "IN: classes.tuple.tests TUPLE: computer cpu ram ;" eval ] unit-test

[ f ] [ "laptop" get electronic-device? ] unit-test
[ t ] [ "laptop" get computer? ] unit-test

[ ] [ "IN: classes.tuple.tests TUPLE: computer < electronic-device cpu ram disk ;" eval ] unit-test

test-laptop-slot-values
test-server-slot-values

[ ] [ "IN: classes.tuple.tests TUPLE: electronic-device voltage ;" eval ] unit-test

test-laptop-slot-values
test-server-slot-values

TUPLE: make-me-some-accessors voltage grounded? ;

[ f ] [ "laptop" get voltage>> ] unit-test
[ f ] [ "server" get voltage>> ] unit-test

[ ] [ "laptop" get 220 >>voltage drop ] unit-test
[ ] [ "server" get 110 >>voltage drop ] unit-test

[ ] [ "IN: classes.tuple.tests TUPLE: electronic-device voltage grounded? ;" eval ] unit-test

test-laptop-slot-values
test-server-slot-values

[ 220 ] [ "laptop" get voltage>> ] unit-test
[ 110 ] [ "server" get voltage>> ] unit-test

[ ] [ "IN: classes.tuple.tests TUPLE: electronic-device grounded? voltage ;" eval ] unit-test

test-laptop-slot-values
test-server-slot-values

[ 220 ] [ "laptop" get voltage>> ] unit-test
[ 110 ] [ "server" get voltage>> ] unit-test

! Reshaping superclass and subclass simultaneously
"IN: classes.tuple.tests TUPLE: electronic-device voltage ; TUPLE: computer < electronic-device cpu ram ;" eval

test-laptop-slot-values
test-server-slot-values

[ 220 ] [ "laptop" get voltage>> ] unit-test
[ 110 ] [ "server" get voltage>> ] unit-test

! Reshape crash
TUPLE: test1 a ; TUPLE: test2 < test1 b ;

C: <test2> test2

"a" "b" <test2> "test" set

: test-a/b
    [ "a" ] [ "test" get a>> ] unit-test
    [ "b" ] [ "test" get b>> ] unit-test ;

test-a/b

[ ] [ "IN: classes.tuple.tests TUPLE: test1 a x ; TUPLE: test2 < test1 b y ;" eval ] unit-test

test-a/b

[ ] [ "IN: classes.tuple.tests TUPLE: test1 a ; TUPLE: test2 < test1 b ;" eval ] unit-test

test-a/b

! Twice in the same compilation unit
[
    test1 tuple { "a" "x" "y" } define-tuple-class
    test1 tuple { "a" "y" } define-tuple-class
] with-compilation-unit

test-a/b

! Moving slots up and down
TUPLE: move-up-1 a b ;
TUPLE: move-up-2 < move-up-1 c ;

T{ move-up-2 f "a" "b" "c" } "move-up" set

: test-move-up
    [ "a" ] [ "move-up" get a>> ] unit-test
    [ "b" ] [ "move-up" get b>> ] unit-test
    [ "c" ] [ "move-up" get c>> ] unit-test ;

test-move-up

[ ] [ "IN: classes.tuple.tests TUPLE: move-up-1 a b c ; TUPLE: move-up-2 < move-up-1 ;" eval ] unit-test

test-move-up

[ ] [ "IN: classes.tuple.tests TUPLE: move-up-1 a c ; TUPLE: move-up-2 < move-up-1 b ;" eval ] unit-test

test-move-up

[ ] [ "IN: classes.tuple.tests TUPLE: move-up-1 c ; TUPLE: move-up-2 < move-up-1 b a ;" eval ] unit-test

test-move-up

[ ] [ "IN: classes.tuple.tests TUPLE: move-up-1 ; TUPLE: move-up-2 < move-up-1 a b c ;" eval ] unit-test

! Constructors must be recompiled when changing superclass
TUPLE: constructor-update-1 xxx ;

TUPLE: constructor-update-2 < constructor-update-1 yyy zzz ;

C: <constructor-update-2> constructor-update-2

{ 3 1 } [ <constructor-update-2> ] must-infer-as

[ ] [ "IN: classes.tuple.tests TUPLE: constructor-update-1 xxx ttt www ;" eval ] unit-test

{ 5 1 } [ <constructor-update-2> ] must-infer-as

[ { f 1 2 3 4 5 } ] [ 1 2 3 4 5 <constructor-update-2> tuple-slots ] unit-test

! Redefinition problem
TUPLE: redefinition-problem ;

UNION: redefinition-problem' redefinition-problem integer ;

[ t ] [ 3 redefinition-problem'? ] unit-test

TUPLE: redefinition-problem-2 ;

"IN: classes.tuple.tests TUPLE: redefinition-problem < redefinition-problem-2 ;" eval

[ t ] [ 3 redefinition-problem'? ] unit-test

! Hardcore unit tests
USE: threads

\ thread slot-names "slot-names" set

[ ] [
    [
        \ thread tuple { "xxx" } "slot-names" get append
        define-tuple-class
    ] with-compilation-unit

    [ 1337 sleep ] "Test" spawn drop

    [
        \ thread tuple "slot-names" get
        define-tuple-class
    ] with-compilation-unit
] unit-test

USE: vocabs

\ vocab slot-names "slot-names" set

[ ] [
    [
        \ vocab tuple { "xxx" } "slot-names" get append
        define-tuple-class
    ] with-compilation-unit

    all-words drop

    [
        \ vocab tuple "slot-names" get
        define-tuple-class
    ] with-compilation-unit
] unit-test

[ "USE: words T{ word }" eval ] [ error>> no-method? ] must-fail-with

! Accessors not being forgotten...
[ [ ] ] [
    "IN: classes.tuple.tests TUPLE: forget-accessors-test x y z ;"
    <string-reader>
    "forget-accessors-test" parse-stream
] unit-test

[ t ] [ "forget-accessors-test" "classes.tuple.tests" lookup class? ] unit-test

: accessor-exists? ( class name -- ? )
    >r "forget-accessors-test" "classes.tuple.tests" lookup r>
    ">>" append "accessors" lookup method >boolean ;

[ t ] [ "x" accessor-exists? ] unit-test
[ t ] [ "y" accessor-exists? ] unit-test
[ t ] [ "z" accessor-exists? ] unit-test

[ [ ] ] [
    "IN: classes.tuple.tests GENERIC: forget-accessors-test"
    <string-reader>
    "forget-accessors-test" parse-stream
] unit-test

[ f ] [ "forget-accessors-test" "classes.tuple.tests" lookup class? ] unit-test

[ f ] [ "x" accessor-exists? ] unit-test
[ f ] [ "y" accessor-exists? ] unit-test
[ f ] [ "z" accessor-exists? ] unit-test

TUPLE: another-forget-accessors-test ;


[ [ ] ] [
    "IN: classes.tuple.tests GENERIC: another-forget-accessors-test"
    <string-reader>
    "another-forget-accessors-test" parse-stream
] unit-test

[ t ] [ \ another-forget-accessors-test class? ] unit-test

! Shadowing test
[ f ] [
    t parser-notes? [
        [
            "IN: classes.tuple.tests TUPLE: shadow-1 a b ; TUPLE: shadow-2 < shadow-1 a b ;" eval
        ] with-string-writer empty?
    ] with-variable
] unit-test

! Missing error check
[ "IN: tuples.test USE: words TUPLE: wrong-superclass < word ;" eval ] must-fail
