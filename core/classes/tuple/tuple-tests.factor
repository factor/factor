USING: accessors arrays assocs calendar classes classes.algebra
classes.private classes.tuple classes.tuple.private columns
combinators.short-circuit compiler.errors compiler.units
definitions eval generic generic.single io.streams.string kernel
kernel.private literals math math.constants memory namespaces
parser parser.notes see sequences sequences.private slots
splitting strings threads tools.test vectors vocabs words
words.symbol ;
IN: classes.tuple.tests

TUPLE: rect x y w h ;
: <rect> ( x y w h -- rect ) rect boa ;

: move ( x rect -- rect )
    [ + ] change-x ;

{ f } [ 10 20 30 40 <rect> dup clone 5 swap move = ] unit-test

{ t } [ 10 20 30 40 <rect> dup clone 0 swap move = ] unit-test

! Make sure we handle tuple class redefinition
TUPLE: redefinition-test ;

C: <redefinition-test> redefinition-test

<redefinition-test> "redefinition-test" set

{ t } [ "redefinition-test" get redefinition-test? ] unit-test

"IN: classes.tuple.tests TUPLE: redefinition-test ;" eval( -- )

{ t } [ "redefinition-test" get redefinition-test? ] unit-test

! Make sure we handle changing shapes!
TUPLE: point x y ;

{ } [ 100 200 point boa "p" set ] unit-test

! Use eval to sequence parsing explicitly
{ } [ "IN: classes.tuple.tests TUPLE: point x y z ;" eval( -- ) ] unit-test

{ 100 } [ "p" get x>> ] unit-test
{ 200 } [ "p" get y>> ] unit-test
{ f } [ "p" get "z>>" "accessors" lookup-word execute ] unit-test

[ "p" get 300 ">>z" "accessors" lookup-word execute ] must-not-fail

{ 3 } [ "p" get tuple-size ] unit-test

{ 300 } [ "p" get "z>>" "accessors" lookup-word execute ] unit-test

{ } [ "IN: classes.tuple.tests TUPLE: point z y ;" eval( -- ) ] unit-test

{ 2 } [ "p" get tuple-size ] unit-test

[ "p" get x>> ] must-fail
{ 200 } [ "p" get y>> ] unit-test
{ 300 } [ "p" get "z>>" "accessors" lookup-word execute ] unit-test

TUPLE: slotty a b c ;

{ T{ slotty } } [ H{ } slotty from-slots ] unit-test
{ T{ slotty f 1 2 f } } [ H{ { "a" 1 } { "b" 2 } } slotty from-slots ] unit-test
[ H{ { "d" 0 } } slotty new set-slots ] must-fail

TUPLE: slotty2 { a integer } { b number } c ;

{ T{ slotty2 } } [ H{ } slotty2 from-slots ] unit-test
{ T{ slotty2 f 1 2 f } } [ H{ { "a" 1 } { "b" 2 } } slotty2 from-slots ] unit-test
[ H{ { "a" 1 } { "b" "two" } } slotty2 from-slots ] must-fail
[ H{ { "d" 0 } } slotty2 new set-slots ] must-fail

TUPLE: predicate-test ;

C: <predicate-test> predicate-test

: predicate-test ( a -- ? ) drop f ;

{ t } [ <predicate-test> predicate-test? ] unit-test

PREDICATE: silly-pred < tuple
    class-of \ rect = ;

GENERIC: area ( obj -- n )
M: silly-pred area dup w>> swap h>> * ;

TUPLE: circle radius ;
M: circle area radius>> sq pi * ;

{ 200 } [ T{ rect f 0 0 10 20 } area ] unit-test

! Hashcode breakage
TUPLE: empty ;

C: <empty> empty

{ t } [ <empty> hashcode fixnum? ] unit-test

! Compiler regression
[ t length ] [ object>> t eq? ] must-fail-with

{ "<constructor-test>" }
[ "IN: classes.tuple.test TUPLE: constructor-test ; C: <constructor-test> constructor-test" eval( -- ) last-word name>> ] unit-test

TUPLE: size-test a b c d ;

{ t } [
    T{ size-test } tuple-size
    size-test tuple-layout second =
] unit-test

GENERIC: <yo-momma> ( a -- b )

TUPLE: yo-momma ;

{ } [ "IN: classes.tuple.tests C: <yo-momma> yo-momma" eval( -- ) ] unit-test

{ f } [ \ <yo-momma> generic? ] unit-test

! Test forget
[
    [ t ] [ \ yo-momma class? ] unit-test
    [ ] [ \ yo-momma forget ] unit-test
    [ ] [ \ <yo-momma> forget ] unit-test
    [ f ] [ \ yo-momma update-map get values member-eq? ] unit-test
] with-compilation-unit

TUPLE: loc-recording ;

{ f } [ \ loc-recording where not ] unit-test

! 'forget' wasn't robust enough

TUPLE: forget-robustness ;

GENERIC: forget-robustness-generic ( a -- b )

M: forget-robustness forget-robustness-generic ;

M: integer forget-robustness-generic ;

[
    [ ] [ \ forget-robustness-generic forget ] unit-test
    [ ] [ \ forget-robustness forget ] unit-test
    [ ] [ M\ forget-robustness forget-robustness-generic forget ] unit-test
] with-compilation-unit

! rapido found this one
GENERIC#: m1 0 ( s n -- n )
GENERIC#: m2 1 ( s n -- v )

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

{ 1 } [ 1 <t4> m1 ] unit-test
{ 1 } [ <t4> 1 m2 ] unit-test

! another combination issue
GENERIC: silly ( obj -- obj obj )

UNION: my-union slice repetition column array vector reversed ;

M: my-union silly "x" ;

M: array silly "y" ;

M: column silly "fdsfds" ;

M: repetition silly "zzz" ;

M: reversed silly "zz" ;

M: slice silly "tt" ;

M: string silly "t" ;

M: vector silly "z" ;

[ 123 <reversed> ] must-fail
{ "zz" } [ { 123 } <reversed> silly nip ] unit-test

! Typo
SYMBOL: not-a-tuple-class

! Missing check
[ not-a-tuple-class boa ] must-fail
[ not-a-tuple-class new ] must-fail

TUPLE: erg's-reshape-problem a b c d ;

C: <erg's-reshape-problem> erg's-reshape-problem

! Inheritance
TUPLE: computer cpu ram ;
C: <computer> computer

{ "TUPLE: computer cpu ram ;" } [
    [ \ computer see ] with-string-writer split-lines second
] unit-test

TUPLE: laptop < computer battery ;
C: <laptop> laptop

{ t } [ laptop tuple-class? ] unit-test
{ t } [ laptop tuple class<= ] unit-test
{ t } [ laptop computer class<= ] unit-test
{ t } [ laptop computer classes-intersect? ] unit-test

{ } [ "Pentium" 128 3 hours <laptop> "laptop" set ] unit-test
{ t } [ "laptop" get laptop? ] unit-test
{ t } [ "laptop" get computer? ] unit-test
{ t } [ "laptop" get tuple? ] unit-test

: test-laptop-slot-values ( -- )
    [ laptop ] [ "laptop" get class-of ] unit-test
    [ "Pentium" ] [ "laptop" get cpu>> ] unit-test
    [ 128 ] [ "laptop" get ram>> ] unit-test
    [ t ] [ "laptop" get battery>> 3 hours = ] unit-test ;

test-laptop-slot-values

{ "TUPLE: laptop < computer battery ;" } [
    [ \ laptop see ] with-string-writer split-lines second
] unit-test

{ { tuple computer laptop } } [ laptop superclasses-of ] unit-test

TUPLE: server < computer rackmount ;
C: <server> server

{ t } [ server tuple-class? ] unit-test
{ t } [ server tuple class<= ] unit-test
{ t } [ server computer class<= ] unit-test
{ t } [ server computer classes-intersect? ] unit-test

{ } [ "PowerPC" 64 "1U" <server> "server" set ] unit-test
{ t } [ "server" get server? ] unit-test
{ t } [ "server" get computer? ] unit-test
{ t } [ "server" get tuple? ] unit-test

: test-server-slot-values ( -- )
    [ server ] [ "server" get class-of ] unit-test
    [ "PowerPC" ] [ "server" get cpu>> ] unit-test
    [ 64 ] [ "server" get ram>> ] unit-test
    [ "1U" ] [ "server" get rackmount>> ] unit-test ;

test-server-slot-values

{ f } [ "server" get laptop? ] unit-test
{ f } [ "laptop" get server? ] unit-test

{ f } [ server laptop class<= ] unit-test
{ f } [ laptop server class<= ] unit-test
{ f } [ laptop server classes-intersect? ] unit-test

{ f } [ 1 2 <computer> laptop? ] unit-test
{ f } [ \ + server? ] unit-test

{ "TUPLE: server < computer rackmount ;" } [
    [ \ server see ] with-string-writer split-lines second
] unit-test

[
    "IN: classes.tuple.tests TUPLE: invalid-superclass < word ;" eval( -- )
] must-fail

! Dynamically changing inheritance hierarchy
TUPLE: electronic-device ;

: computer?' ( a -- b ) computer? ;

{ t } [ laptop new computer?' ] unit-test

{ } [ "IN: classes.tuple.tests TUPLE: computer < electronic-device cpu ram ; C: <computer> computer C: <laptop> laptop C: <server> server" eval( -- ) ] unit-test

{ t } [ laptop new computer?' ] unit-test

{ f } [ electronic-device laptop class<= ] unit-test
{ t } [ server electronic-device class<= ] unit-test
{ t } [ laptop server class-or electronic-device class<= ] unit-test

{ t } [ "laptop" get electronic-device? ] unit-test
{ t } [ "laptop" get computer? ] unit-test
{ t } [ "laptop" get laptop? ] unit-test
{ f } [ "laptop" get server? ] unit-test

{ t } [ "server" get electronic-device? ] unit-test
{ t } [ "server" get computer? ] unit-test
{ f } [ "server" get laptop? ] unit-test
{ t } [ "server" get server? ] unit-test

{ } [ "IN: classes.tuple.tests TUPLE: computer cpu ram ; C: <computer> computer C: <laptop> laptop C: <server> server" eval( -- ) ] unit-test

{ f } [ "laptop" get electronic-device? ] unit-test
{ t } [ "laptop" get computer? ] unit-test

{ } [ "IN: classes.tuple.tests TUPLE: computer < electronic-device cpu ram disk ; C: <computer> computer C: <laptop> laptop C: <server> server" eval( -- ) ] unit-test

test-laptop-slot-values
test-server-slot-values

{ } [ "IN: classes.tuple.tests TUPLE: electronic-device voltage ; C: <computer> computer C: <laptop> laptop C: <server> server" eval( -- ) ] unit-test

test-laptop-slot-values
test-server-slot-values

TUPLE: make-me-some-accessors voltage grounded? ;

{ f } [ "laptop" get voltage>> ] unit-test
{ f } [ "server" get voltage>> ] unit-test

[ "laptop" get 220 >>voltage ] must-not-fail
[ "server" get 110 >>voltage ] must-not-fail

{ } [ "IN: classes.tuple.tests TUPLE: electronic-device voltage grounded? ; C: <computer> computer" eval( -- ) ] unit-test

test-laptop-slot-values
test-server-slot-values

{ 220 } [ "laptop" get voltage>> ] unit-test
{ 110 } [ "server" get voltage>> ] unit-test

{ } [ "IN: classes.tuple.tests TUPLE: electronic-device grounded? voltage ; C: <computer> computer C: <laptop> laptop C: <server> server" eval( -- ) ] unit-test

test-laptop-slot-values
test-server-slot-values

{ 220 } [ "laptop" get voltage>> ] unit-test
{ 110 } [ "server" get voltage>> ] unit-test

! Reshaping superclass and subclass simultaneously
{ } [ "IN: classes.tuple.tests TUPLE: electronic-device voltage ; TUPLE: computer < electronic-device cpu ram ; C: <computer> computer C: <laptop> laptop C: <server> server" eval( -- ) ] unit-test

test-laptop-slot-values
test-server-slot-values

{ 220 } [ "laptop" get voltage>> ] unit-test
{ 110 } [ "server" get voltage>> ] unit-test

! Reshape crash
TUPLE: test1 a ; TUPLE: test2 < test1 b ;

"a" "b" test2 boa "test" set

: test-a/b ( -- )
    [ "a" ] [ "test" get a>> ] unit-test
    [ "b" ] [ "test" get b>> ] unit-test ;

test-a/b

{ } [ "IN: classes.tuple.tests TUPLE: test1 a x ; TUPLE: test2 < test1 b y ;" eval( -- ) ] unit-test

test-a/b

{ } [ "IN: classes.tuple.tests TUPLE: test1 a ; TUPLE: test2 < test1 b ;" eval( -- ) ] unit-test

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

: test-move-up ( -- )
    [ "a" ] [ "move-up" get a>> ] unit-test
    [ "b" ] [ "move-up" get b>> ] unit-test
    [ "c" ] [ "move-up" get c>> ] unit-test ;

test-move-up

{ } [ "IN: classes.tuple.tests TUPLE: move-up-1 a b c ; TUPLE: move-up-2 < move-up-1 ;" eval( -- ) ] unit-test

test-move-up

{ } [ "IN: classes.tuple.tests TUPLE: move-up-1 a c ; TUPLE: move-up-2 < move-up-1 b ;" eval( -- ) ] unit-test

test-move-up

{ } [ "IN: classes.tuple.tests TUPLE: move-up-1 c ; TUPLE: move-up-2 < move-up-1 b a ;" eval( -- ) ] unit-test

test-move-up

{ } [ "IN: classes.tuple.tests TUPLE: move-up-1 ; TUPLE: move-up-2 < move-up-1 a b c ;" eval( -- ) ] unit-test

! Constructors must be recompiled when changing superclass
TUPLE: constructor-update-1 xxx ;

TUPLE: constructor-update-2 < constructor-update-1 yyy zzz ;

: <constructor-update-2> ( a b c -- tuple ) constructor-update-2 boa ;

{ 3 1 } [ <constructor-update-2> ] must-infer-as

{ } [ "IN: classes.tuple.tests TUPLE: constructor-update-1 xxx ttt www ;" eval( -- ) ] unit-test

{ 3 1 } [ <constructor-update-2> ] must-infer-as

[ 1 2 3 4 5 <constructor-update-2> ] [ not-compiled? ] must-fail-with

{ } [ [ \ <constructor-update-2> forget ] with-compilation-unit ] unit-test

! Redefinition problem
TUPLE: redefinition-problem ;

UNION: redefinition-problem' redefinition-problem integer ;

{ t } [ 3 redefinition-problem'? ] unit-test

TUPLE: redefinition-problem-2 ;

"IN: classes.tuple.tests TUPLE: redefinition-problem < redefinition-problem-2 ;" eval( -- )

{ t } [ 3 redefinition-problem'? ] unit-test

! Hardcore unit tests

\ thread "slots" word-prop "slots" set

{ } [
    [
        \ thread tuple { "xxx" } "slots" get append
        define-tuple-class
    ] with-compilation-unit

    [ 1337 sleep ] "Test" spawn drop

    [
        \ thread tuple "slots" get
        define-tuple-class
    ] with-compilation-unit
] unit-test

\ vocab "slots" word-prop "slots" set

{ } [
    [
        \ vocab identity-tuple { "xxx" } "slots" get append
        define-tuple-class
    ] with-compilation-unit

    all-words drop

    [
        \ vocab identity-tuple "slots" get
        define-tuple-class
    ] with-compilation-unit
] unit-test

[ "USE: words T{ word }" eval( -- ) ]
[ error>> T{ no-method f word new } = ]
must-fail-with

! Accessors not being forgotten...
{ [ ] } [
    "IN: classes.tuple.tests TUPLE: forget-accessors-test x y z ;"
    <string-reader>
    "forget-accessors-test" parse-stream
] unit-test

{ t } [ "forget-accessors-test" "classes.tuple.tests" lookup-word class? ] unit-test

: accessor-exists? ( name -- ? )
    [ "forget-accessors-test" "classes.tuple.tests" lookup-word ] dip
    ">>" append "accessors" lookup-word ?lookup-method >boolean ;

{ t } [ "x" accessor-exists? ] unit-test
{ t } [ "y" accessor-exists? ] unit-test
{ t } [ "z" accessor-exists? ] unit-test

{ [ ] } [
    "IN: classes.tuple.tests GENERIC: forget-accessors-test ( a -- b )"
    <string-reader>
    "forget-accessors-test" parse-stream
] unit-test

{ f } [ "forget-accessors-test" "classes.tuple.tests" lookup-word class? ] unit-test

{ f } [ "x" accessor-exists? ] unit-test
{ f } [ "y" accessor-exists? ] unit-test
{ f } [ "z" accessor-exists? ] unit-test

TUPLE: another-forget-accessors-test ;


{ [ ] } [
    "IN: classes.tuple.tests GENERIC: another-forget-accessors-test ( a -- b )"
    <string-reader>
    "another-forget-accessors-test" parse-stream
] unit-test

{ t } [ \ another-forget-accessors-test class? ] unit-test

! Shadowing test
{ f } [
    f parser-quiet? [
        [
            "IN: classes.tuple.tests TUPLE: shadow-1 a b ; TUPLE: shadow-2 < shadow-1 a b ;" eval( -- )
        ] with-string-writer empty?
    ] with-variable
] unit-test

! Missing error check
[ "IN: classes.tuple.tests USE: words TUPLE: wrong-superclass < word ;" eval( -- ) ] must-fail

! Insufficient type checking
[ \ vocab pack-tuple ] [ not-an-instance? ] must-fail-with

! Check type declarations
TUPLE: declared-types { n fixnum } { m string } ;

{ T{ declared-types f 0 "hi" } }
[ { declared-types 0 "hi" } unpack-tuple ]
unit-test

[ { declared-types "hi" 0 } unpack-tuple ]
[ T{ bad-slot-value f "hi" fixnum } = ]
must-fail-with

! Check fixnum coercer
[ 0.0 "hi" declared-types boa n>> ] [ T{ no-method f 0.0 integer>fixnum-strict } = ] must-fail-with

[ declared-types new 0.0 >>n n>> ] [ T{ no-method f 0.0 integer>fixnum-strict } = ] must-fail-with

{ T{ declared-types f 33333 "asdf" } }
[ 33333 >bignum "asdf" declared-types boa ] unit-test

[ 444444444444444444444444444444444444444444444444433333 >bignum "asdf" declared-types boa ]
[
    ${ KERNEL-ERROR ERROR-OUT-OF-FIXNUM-RANGE
       444444444444444444444444444444444444444444444444433333 f } =
] must-fail-with

! Check bignum coercer
TUPLE: bignum-coercer { n bignum initial: $[ 0 >bignum ] } ;

{ 13 bignum } [ 13.5 bignum-coercer boa n>> dup class-of ] unit-test

{ 13 bignum } [ bignum-coercer new 13.5 >>n n>> dup class-of ] unit-test

! Check float coercer
TUPLE: float-coercer { n float } ;

{ 13.0 float } [ 13 float-coercer boa n>> dup class-of ] unit-test

{ 13.0 float } [ float-coercer new 13 >>n n>> dup class-of ] unit-test

! Check integer coercer
TUPLE: integer-coercer { n integer } ;

[ 13.5 integer-coercer boa n>> dup class-of ] [ T{ bad-slot-value f 13.5 integer } = ] must-fail-with

[ integer-coercer new 13.5 >>n n>> dup class-of ] [ T{ bad-slot-value f 13.5 integer } = ] must-fail-with

: foo ( a b -- c ) declared-types boa ;

\ foo def>> must-infer

[ 0.0 "hi" foo ] [ T{ no-method f 0.0 integer>fixnum-strict } = ] must-fail-with

[ "hi" 0.0 declared-types boa ]
[ T{ no-method f "hi" integer>fixnum-strict } = ]
must-fail-with

[ 0 { } declared-types boa ]
[ T{ bad-slot-value f { } string } = ]
must-fail-with

[ "hi" 0.0 foo ]
[ T{ no-method f "hi" integer>fixnum-strict } = ]
must-fail-with

[ 0 { } foo ]
[ T{ bad-slot-value f { } string } = ]
must-fail-with

{ T{ declared-types f 0 "" } } [ declared-types new ] unit-test

: blah ( -- vec ) vector new ;

[ vector new ] must-infer

{ V{ } } [ blah ] unit-test


{ } [
    "IN: classes.tuple.tests TUPLE: forget-subclass-test ; TUPLE: forget-subclass-test' < forget-subclass-test ;"
    <string-reader> "forget-subclass-test" parse-stream
    drop
] unit-test

{ } [ "forget-subclass-test'" "classes.tuple.tests" lookup-word new "bad-object" set ] unit-test

{ } [
    "IN: classes.tuple.tests TUPLE: forget-subclass-test a ;"
    <string-reader> "forget-subclass-test" parse-stream
    drop
] unit-test


{ } [
     "IN: sequences TUPLE: reversed < wrapped-sequence ;" eval( -- )
] unit-test


TUPLE: bogus-hashcode-1 x ;

TUPLE: bogus-hashcode-2 x ;

M: bogus-hashcode-1 hashcode* 2drop 0 >bignum ;

[ T{ bogus-hashcode-2 f T{ bogus-hashcode-1 } } hashcode ] must-not-fail

DEFER: change-slot-test
SLOT: kex

{ } [
    "IN: classes.tuple.tests USING: kernel accessors ; TUPLE: change-slot-test ; SLOT: kex M: change-slot-test kex>> drop 3 ;"
    <string-reader> "change-slot-test" parse-stream
    drop
] unit-test

{ t } [ \ change-slot-test \ kex>> ?lookup-method >boolean ] unit-test

{ } [
    "IN: classes.tuple.tests USING: kernel accessors ; TUPLE: change-slot-test kex ;"
    <string-reader> "change-slot-test" parse-stream
    drop
] unit-test

{ t } [ \ change-slot-test \ kex>> ?lookup-method >boolean ] unit-test

{ } [
    "IN: classes.tuple.tests USING: kernel accessors ; TUPLE: change-slot-test ; SLOT: kex M: change-slot-test kex>> drop 3 ;"
    <string-reader> "change-slot-test" parse-stream
    drop
] unit-test

{ t } [ \ change-slot-test \ kex>> ?lookup-method >boolean ] unit-test
{ f } [ \ change-slot-test \ kex>> ?lookup-method "reading" word-prop ] unit-test

DEFER: redefine-tuple-twice

{ } [ "IN: classes.tuple.tests TUPLE: redefine-tuple-twice ;" eval( -- ) ] unit-test

{ t } [ \ redefine-tuple-twice symbol? ] unit-test

{ } [ "IN: classes.tuple.tests DEFER: redefine-tuple-twice" eval( -- ) ] unit-test

{ t } [ \ redefine-tuple-twice deferred? ] unit-test

{ } [ "IN: classes.tuple.tests TUPLE: redefine-tuple-twice ;" eval( -- ) ] unit-test

{ t } [ \ redefine-tuple-twice symbol? ] unit-test


! Test reshaping with type declarations and slot attributes
TUPLE: reshape-test x ;

T{ reshape-test f "hi" } "tuple" set

{ } [ "IN: classes.tuple.tests TUPLE: reshape-test { x read-only } ;" eval( -- ) ] unit-test

{ f } [ \ reshape-test \ x<< ?lookup-method ] unit-test

[ "tuple" get 5 >>x ] must-fail

{ "hi" } [ "tuple" get x>> ] unit-test

{ } [ "IN: classes.tuple.tests USE: math TUPLE: reshape-test { x integer read-only } ;" eval( -- ) ] unit-test

{ 0 } [ "tuple" get x>> ] unit-test

{ } [ "IN: classes.tuple.tests USE: math TUPLE: reshape-test { x fixnum initial: 4 read-only } ;" eval( -- ) ] unit-test

{ 0 } [ "tuple" get x>> ] unit-test

TUPLE: boa-coercer-test { x array-capacity } ;

{ fixnum } [ 0 >bignum boa-coercer-test boa x>> class-of ] unit-test

{ T{ boa-coercer-test f 0 } } [ T{ boa-coercer-test } ] unit-test

TUPLE: boa-iac { x integer-array-capacity initial: 77 } ;

{ fixnum bignum 77 } [
    30 boa-iac boa x>> class-of
    10 >bignum boa-iac boa x>> class-of
    boa-iac new x>>
] unit-test

[ -99 boa-iac boa ] [ bad-slot-value? ] must-fail-with

! Make sure that tuple reshaping updates code heap roots
TUPLE: code-heap-ref ;

: code-heap-ref' ( -- a ) T{ code-heap-ref } ;

! Push foo's literal to tenured space
{ } [ gc ] unit-test

! Reshape!
{ } [ "IN: classes.tuple.tests USE: math TUPLE: code-heap-ref { x integer initial: 5 } ;" eval( -- ) ] unit-test

! Code heap reference
{ t } [ code-heap-ref' code-heap-ref? ] unit-test
{ 5 } [ code-heap-ref' x>> ] unit-test

! Data heap reference
{ t } [ \ code-heap-ref' def>> first code-heap-ref? ] unit-test
{ 5 } [ \ code-heap-ref' def>> first x>> ] unit-test

! If the metaclass of a superclass changes into something other
! than a tuple class, the tuple needs to have its superclass reset
TUPLE: metaclass-change ;
TUPLE: metaclass-change-subclass < metaclass-change ;

{ metaclass-change } [ metaclass-change-subclass superclass-of ] unit-test

{ } [ "IN: classes.tuple.tests MIXIN: metaclass-change" eval( -- ) ] unit-test

{ t } [ metaclass-change-subclass tuple-class? ] unit-test
{ tuple } [ metaclass-change-subclass superclass-of ] unit-test

! Reshaping bug related to the above
TUPLE: a-g ;
TUPLE: g < a-g ;

{ } [ g new "g" set ] unit-test

{ } [ "IN: classes.tuple.tests MIXIN: a-g TUPLE: g ;" eval( -- ) ] unit-test

{ t } [ g new layout-of "g" get layout-of eq? ] unit-test

! Joe Groff discovered this bug
DEFER: factor-crashes-anymore

{ } [
    "IN: classes.tuple.tests
    TUPLE: unsafe-slot-access ;
    CONSTANT: unsafe-slot-access' T{ unsafe-slot-access }" eval( -- )
] unit-test

{ } [
    "IN: classes.tuple.tests
    USE: accessors
    TUPLE: unsafe-slot-access { x read-only initial: 31337 } ;
    : factor-crashes-anymore ( -- x ) unsafe-slot-access' x>> ;" eval( -- )
] unit-test

{ 31337 } [ factor-crashes-anymore ] unit-test

TUPLE: tuple-predicate-redefine-test ;

{ } [ "IN: classes.tuple.tests TUPLE: tuple-predicate-redefine-test ;" eval( -- ) ] unit-test

{ t } [ \ tuple-predicate-redefine-test? predicate? ] unit-test

! Final classes
TUPLE: final-superclass ;
TUPLE: final-subclass < final-superclass ;

{ final-superclass } [ final-subclass superclass-of ] unit-test

! Making the superclass final should change the superclass of the subclass
{ } [ "IN: classes.tuple.tests TUPLE: final-superclass ; final" eval( -- ) ] unit-test

{ tuple } [ final-subclass superclass-of ] unit-test

{ f } [ \ final-subclass final-class? ] unit-test

! Subclassing a final class should fail
[ "IN: classes.tuple.tests TUPLE: final-subclass < final-superclass ;" eval( -- ) ]
[ error>> bad-superclass? ] must-fail-with

! Making a final class non-final should work
{ } [ "IN: classes.tuple.tests TUPLE: final-superclass ;" eval( -- ) ] unit-test

{ } [ "IN: classes.tuple.tests TUPLE: final-subclass < final-superclass ; final" eval( -- ) ] unit-test

! Changing a superclass should not change the final status of a subclass
{ } [ "IN: classes.tuple.tests TUPLE: final-superclass x ;" eval( -- ) ] unit-test

{ t } [ \ final-subclass final-class? ] unit-test

! Test reset-class on tuples
! Should forget all accessors on rclasstest
TUPLE: rclasstest a b ;
{ } [ [ \ rclasstest reset-class ] with-compilation-unit ] unit-test
{ f } [ \ rclasstest \ a>> ?lookup-method ] unit-test
{ f } [ \ rclasstest \ a<< ?lookup-method ] unit-test
{ f } [ \ rclasstest \ b>> ?lookup-method ] unit-test
{ f } [ \ rclasstest \ b<< ?lookup-method ] unit-test

<< \ rclasstest forget >>

! initial: should type check
TUPLE: initial-class ;

DEFER: initial-slot

{ } [ "IN: classes.tuple.tests TUPLE: initial-slot { x initial-class } ;" eval( -- ) ] unit-test

{ t } [ initial-slot new x>> initial-class? ] unit-test

[ "IN: classes.tuple.tests TUPLE: initial-slot { x initial-class initial: f } ;" eval( -- ) ]
[ error>> T{ bad-initial-value f "x" f initial-class } = ] must-fail-with

[ "IN: classes.tuple.tests TUPLE: initial-slot { x initial-class initial: 3 } ;" eval( -- ) ]
[ error>> T{ bad-initial-value f "x" 3 initial-class } = ] must-fail-with

[ "IN: classes.tuple.tests USE: math TUPLE: foo < foo ;" eval( -- ) ] [ error>> bad-superclass? ] must-fail-with

[ "IN: classes.tuple.tests USE: math TUPLE: foo < + ;" eval( -- ) ] [ error>> bad-superclass? ] must-fail-with


! Test no-slot error and get/set-slot-named

TUPLE: no-slot-tuple0 a b c ;
C: <no-slot-tuple0> no-slot-tuple0

[ 1 2 3 <no-slot-tuple0> "d" over get-slot-named ]
[
    {
        [ no-slot? ]
        [ tuple>> no-slot-tuple0? ]
        [ name>> "d" = ]
    } 1&&
] must-fail-with

{ 1 }
[ 1 2 3 <no-slot-tuple0> "a" swap get-slot-named ] unit-test

{ 2 }
[ 1 2 3 <no-slot-tuple0> "b" swap get-slot-named ] unit-test

{ 3 }
[ 1 2 3 <no-slot-tuple0> "c" swap get-slot-named ] unit-test

{ 4 } [
    1 2 3 <no-slot-tuple0> 4 "a" pick set-slot-named
    "a" swap get-slot-named
] unit-test

[ 1 2 3 <no-slot-tuple0> 4 "d" pick set-slot-named ]
[
    {
        [ no-slot? ]
        [ tuple>> no-slot-tuple0? ]
        [ name>> "d" = ]
    } 1&&
] must-fail-with

[ "IN: classes.tuple.tests TUPLE: too-many-slots-test a b c d ; T{ too-many-slots-test f 1 2 3 4 5 }" eval( -- x ) ]
[ error>> too-many-slots? ] must-fail-with
