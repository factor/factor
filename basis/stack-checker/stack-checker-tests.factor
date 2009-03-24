USING: accessors arrays generic stack-checker
stack-checker.backend stack-checker.errors kernel classes
kernel.private math math.parser math.private namespaces
namespaces.private parser sequences strings vectors words
quotations effects tools.test continuations generic.standard
sorting assocs definitions prettyprint io inspector
classes.tuple classes.union classes.predicate debugger
threads.private io.streams.string io.timeouts io.thread
sequences.private destructors combinators eval locals.backend
system compiler.units ;
IN: stack-checker.tests

\ infer. must-infer

{ 0 2 } [ 2 "Hello" ] must-infer-as
{ 1 2 } [ dup ] must-infer-as

{ 1 2 } [ [ dup ] call ] must-infer-as
[ [ call ] infer ] must-fail

{ 2 4 } [ 2dup ] must-infer-as

{ 1 0 } [ [ ] [ ] if ] must-infer-as
[ [ if ] infer ] must-fail
[ [ [ ] if ] infer ] must-fail
[ [ [ 2 ] [ ] if ] infer ] must-fail
{ 4 3 } [ [ rot ] [ -rot ] if ] must-infer-as

{ 4 3 } [
    [
        [ swap 3 ] [ nip 5 5 ] if
    ] [
        -rot
    ] if
] must-infer-as

{ 1 1 } [ dup [ ] when ] must-infer-as
{ 1 1 } [ dup [ dup fixnum* ] when ] must-infer-as
{ 2 1 } [ [ dup fixnum* ] when ] must-infer-as

{ 1 0 } [ [ drop ] when* ] must-infer-as
{ 1 1 } [ [ { { [ ] } } ] unless* ] must-infer-as

{ 0 1 }
[ [ 2 2 fixnum+ ] dup [ ] when call ] must-infer-as

[
    [ [ [ 2 2 fixnum+ ] ] [ [ 2 2 fixnum* ] ] if call ] infer
] must-fail

! Test inference of termination of control flow
: termination-test-1 ( -- * ) "foo" throw ;

: termination-test-2 ( ? -- x ) [ termination-test-1 ] [ 3 ] if ;

{ 1 1 } [ termination-test-2 ] must-infer-as

: simple-recursion-1 ( obj -- obj )
    dup [ simple-recursion-1 ] [ ] if ;

{ 1 1 } [ simple-recursion-1 ] must-infer-as

: simple-recursion-2 ( obj -- obj )
    dup [ ] [ simple-recursion-2 ] if ;

{ 1 1 } [ simple-recursion-2 ] must-infer-as

: bad-recursion-2 ( obj -- obj )
    dup [ dup first swap second bad-recursion-2 ] [ ] if ;

[ [ bad-recursion-2 ] infer ] must-fail

: funny-recursion ( obj -- obj )
    dup [ funny-recursion 1 ] [ 2 ] if drop ;

{ 1 1 } [ funny-recursion ] must-infer-as

! Simple combinators
{ 1 2 } [ [ first ] keep second ] must-infer-as

! Mutual recursion
DEFER: foe

: fie ( element obj -- ? )
    dup array? [ foe ] [ eq? ] if ;

: foe ( element tree -- ? )
    dup [
        2dup first fie [
            nip
        ] [
            second dup array? [
                foe
            ] [
                fie
            ] if
        ] if
    ] [
        2drop f
    ] if ;

{ 2 1 } [ fie ] must-infer-as
{ 2 1 } [ foe ] must-infer-as

: nested-when ( -- )
    t [
        t [
            5 drop
        ] when
    ] when ;

{ 0 0 } [ nested-when ] must-infer-as

: nested-when* ( obj -- )
    [
        [
            drop
        ] when*
    ] when* ;

{ 1 0 } [ nested-when* ] must-infer-as

SYMBOL: sym-test

{ 0 1 } [ sym-test ] must-infer-as

: terminator-branch ( a -- b )
    dup [
        length
    ] [
        "foo" throw
    ] if ;

{ 1 1 } [ terminator-branch ] must-infer-as

: recursive-terminator ( obj -- )
    dup [
        recursive-terminator
    ] [
        "Hi" throw
    ] if ;

{ 1 0 } [ recursive-terminator ] must-infer-as

GENERIC: potential-hang ( obj -- obj )
M: fixnum potential-hang dup [ potential-hang ] when ;

[ ] [ [ 5 potential-hang ] infer drop ] unit-test

TUPLE: funny-cons car cdr ;
GENERIC: iterate ( obj -- )
M: funny-cons iterate cdr>> iterate ;
M: f iterate drop ;
M: real iterate drop ;

{ 1 0 } [ iterate ] must-infer-as

! Regression
: cat ( obj -- * ) dup [ throw ] [ throw ] if ;
: dog ( a b c -- ) dup [ cat ] [ 3drop ] if ;
{ 3 0 } [ dog ] must-infer-as

! Regression
DEFER: monkey
: friend ( a b c -- ) dup [ friend ] [ monkey ] if ;
: monkey ( a b c -- ) dup [ 3drop ] [ friend ] if ;
{ 3 0 } [ friend ] must-infer-as

! Regression -- same as above but we infer the second word first
DEFER: blah2
: blah ( a b c -- ) dup [ blah ] [ blah2 ] if ;
: blah2 ( a b c -- ) dup [ blah ] [ 3drop ] if ;
{ 3 0 } [ blah2 ] must-infer-as

! Regression
DEFER: blah4
: blah3 ( a b c -- )
    dup [ blah3 ] [ dup [ blah4 ] [ blah3 ] if ] if ;
: blah4 ( a b c -- )
    dup [ blah4 ] [ dup [ 3drop ] [ blah3 ] if ] if ;
{ 3 0 } [ blah4 ] must-infer-as

! Regression
: bad-combinator ( obj quot: ( -- ) -- )
    over [
        2drop
    ] [
        [ swap slip ] keep swap bad-combinator
    ] if ; inline recursive

[ [ [ 1 ] [ ] bad-combinator ] infer ] must-fail

! Regression
{ 2 2 } [
    dup string? [ 2array throw ] unless
    over string? [ 2array throw ] unless
] must-infer-as

! Regression

! This order of branches works
DEFER: do-crap
: more-crap ( obj -- ) dup [ drop ] [ dup do-crap call ] if ;
: do-crap ( obj -- ) dup [ more-crap ] [ do-crap ] if ;
[ [ do-crap ] infer ] must-fail

! This one does not
DEFER: do-crap*
: more-crap* ( obj -- ) dup [ drop ] [ dup do-crap* call ] if ;
: do-crap* ( obj -- ) dup [ do-crap* ] [ more-crap* ] if ;
[ [ do-crap* ] infer ] must-fail

! Regression
: too-deep ( a b -- c )
    dup [ drop ] [ 2dup too-deep too-deep * ] if ; inline recursive
{ 2 1 } [ too-deep ] must-infer-as

! Error reporting is wrong
MATH: xyz ( a b -- c )
M: fixnum xyz 2array ;
M: float xyz
    [ 3 ] bi@ swapd [ 2array swap ] dip 2array swap ;

[ [ xyz ] infer ] [ inference-error? ] must-fail-with

! Doug Coleman discovered this one while working on the
! calendar library
DEFER: A
DEFER: B
DEFER: C

: A ( a -- )
    dup {
        [ drop ]
        [ A ]
        [ \ A no-method ]
        [ dup C A ]
    } dispatch ;

: B ( b -- )
    dup {
        [ C ]
        [ B ]
        [ \ B no-method ]
        [ dup B B ]
    } dispatch ;

: C ( c -- )
    dup {
        [ A ]
        [ C ]
        [ \ C no-method ]
        [ dup B C ]
    } dispatch ;

{ 1 0 } [ A ] must-infer-as
{ 1 0 } [ B ] must-infer-as
{ 1 0 } [ C ] must-infer-as

! I found this bug by thinking hard about the previous one
DEFER: Y
: X ( a b -- c d ) dup [ swap Y ] [ ] if ;
: Y ( a b -- c d ) X ;

{ 2 2 } [ X ] must-infer-as
{ 2 2 } [ Y ] must-infer-as

! This one comes from UI code
DEFER: #1
: #2 ( a b: ( -- ) -- ) dup [ call ] [ 2drop ] if ; inline
: #3 ( a -- ) [ #1 ] #2 ;
: #4 ( a -- ) dup [ drop ] [ dup #4 dup #3 call ] if ;
: #1 ( a -- ) dup [ dup #4 dup #3 ] [ ] if drop ;

[ \ #4 def>> infer ] must-fail
[ [ #1 ] infer ] must-fail

! Similar
DEFER: bar
: foo ( a b -- c d ) dup [ 2drop f f bar ] [ ] if ;
: bar ( a b -- ) [ 2 2 + ] t foo drop call drop ;

[ [ foo ] infer ] must-fail

[ 1234 infer ] must-fail

! This used to hang
[ [ [ dup call ] dup call ] infer ]
[ inference-error? ] must-fail-with

: m ( q -- ) dup call ; inline

[ [ [ m ] m ] infer ] [ inference-error? ] must-fail-with

: m' ( quot -- ) dup curry call ; inline

[ [ [ m' ] m' ] infer ] [ inference-error? ] must-fail-with

: m'' ( -- q ) [ dup curry ] ; inline

: m''' ( -- ) m'' call call ; inline

[ [ [ m''' ] m''' ] infer ] [ inference-error? ] must-fail-with

: m-if ( a b c -- ) t over if ; inline

[ [ [ m-if ] m-if ] infer ] [ inference-error? ] must-fail-with

! This doesn't hang but it's also an example of the
! undedicable case
[ [ [ [ drop 3 ] swap call ] dup call ] infer ]
[ inference-error? ] must-fail-with

! This form should not have a stack effect

: bad-recursion-1 ( a -- b )
    dup [ drop bad-recursion-1 5 ] [ ] if ;

[ [ bad-recursion-1 ] infer ] must-fail

: bad-bin ( a b -- ) 5 [ 5 bad-bin bad-bin 5 ] [ 2drop ] if ;
[ [ bad-bin ] infer ] must-fail

[ [ 1 drop-locals ] infer ] [ inference-error? ] must-fail-with

! Regression
[ [ cleave ] infer ] [ inference-error? ] must-fail-with

! Test some curry stuff
{ 1 1 } [ 3 [ ] curry 4 [ ] curry if ] must-infer-as

{ 2 1 } [ [ ] curry 4 [ ] curry if ] must-infer-as

[ [ 3 [ ] curry 1 2 [ ] 2curry if ] infer ] must-fail

! Test number protocol
\ bitor must-infer
\ bitand must-infer
\ bitxor must-infer
\ mod must-infer
\ /i must-infer
\ /f must-infer
\ /mod must-infer
\ + must-infer
\ - must-infer
\ * must-infer
\ / must-infer
\ < must-infer
\ <= must-infer
\ > must-infer
\ >= must-infer
\ number= must-infer

! Test object protocol
\ = must-infer
\ clone must-infer
\ hashcode* must-infer

! Test sequence protocol
\ length must-infer
\ nth must-infer
\ set-length must-infer
\ set-nth must-infer
\ new must-infer
\ new-resizable must-infer
\ like must-infer
\ lengthen must-infer

! Test assoc protocol
\ at* must-infer
\ set-at must-infer
\ new-assoc must-infer
\ delete-at must-infer
\ clear-assoc must-infer
\ assoc-size must-infer
\ assoc-like must-infer
\ assoc-clone-like must-infer
\ >alist must-infer
{ 1 3 } [ [ 2drop f ] assoc-find ] must-infer-as

! Test some random library words
\ 1quotation must-infer
\ string>number must-infer
\ get must-infer

\ push must-infer
\ append must-infer
\ peek must-infer

\ reverse must-infer
\ member? must-infer
\ remove must-infer
\ natural-sort must-infer

\ forget must-infer
\ define-class must-infer
\ define-tuple-class must-infer
\ define-union-class must-infer
\ define-predicate-class must-infer
\ instance? must-infer
\ next-method-quot must-infer

! Test words with continuations
{ 0 0 } [ [ drop ] callcc0 ] must-infer-as
{ 0 1 } [ [ 4 swap continue-with ] callcc1 ] must-infer-as
{ 2 1 } [ [ + ] [ ] [ ] cleanup ] must-infer-as
{ 2 1 } [ [ + ] [ 3drop 0 ] recover ] must-infer-as

\ dispose must-infer

! Test stream protocol
\ set-timeout must-infer
\ stream-read must-infer
\ stream-read1 must-infer
\ stream-readln must-infer
\ stream-read-until must-infer
\ stream-write must-infer
\ stream-write1 must-infer
\ stream-nl must-infer
\ stream-flush must-infer

! Test stream utilities
\ lines must-infer
\ contents must-infer

! Test prettyprinting
\ . must-infer
\ short. must-infer
\ unparse must-infer

\ describe must-infer
\ error. must-infer

! Test odds and ends
\ io-thread must-infer

! Incorrect stack declarations on inline recursive words should
! be caught
: fooxxx ( a b -- c ) over [ foo ] when ; inline
: barxxx ( a b -- c ) fooxxx ;

[ [ barxxx ] infer ] must-fail

! A typo
{ 1 0 } [ { [ ] } dispatch ] must-infer-as

DEFER: inline-recursive-2
: inline-recursive-1 ( -- ) inline-recursive-2 ;
: inline-recursive-2 ( -- ) inline-recursive-1 ;

{ 0 0 } [ inline-recursive-1 ] must-infer-as

! Hooks
SYMBOL: my-var
HOOK: my-hook my-var ( -- x )

M: integer my-hook "an integer" ;
M: string my-hook "a string" ;

{ 0 1 } [ my-hook ] must-infer-as

DEFER: deferred-word

{ 1 1 } [ [ deferred-word ] [ 3 ] if ] must-infer-as


DEFER: an-inline-word

: normal-word-3 ( -- )
    3 [ [ 2 + ] curry ] an-inline-word call drop ;

: normal-word-2 ( -- )
    normal-word-3 ;

: normal-word ( x -- x )
    dup [ normal-word-2 ] when ;

: an-inline-word ( obj quot -- )
    [ normal-word ] dip call ; inline

{ 1 1 } [ [ 3 * ] an-inline-word ] must-infer-as

{ 0 1 } [ [ 2 ] [ 2 ] [ + ] compose compose call ] must-infer-as

ERROR: custom-error ;

[ T{ effect f 0 0 t } ] [
    [ custom-error ] infer
] unit-test

: funny-throw ( a -- * ) throw ; inline

[ T{ effect f 0 0 t } ] [
    [ 3 funny-throw ] infer
] unit-test

[ T{ effect f 0 0 t } ] [
    [ custom-error inference-error ] infer
] unit-test

[ T{ effect f 1 2 t } ] [
    [ dup [ 3 throw ] dip ] infer
] unit-test

! Regression
: missing->r-check ( a -- ) 1 load-locals ;

[ [ missing->r-check ] infer ] must-fail

! Corner case
[ [ [ f dup ] [ dup ] produce ] infer ] must-fail

[ [ [ f dup ] [ ] while ] infer ] must-fail

: erg's-inference-bug ( -- ) f dup [ erg's-inference-bug ] when ; inline recursive

[ [ erg's-inference-bug ] infer ] must-fail

: inference-invalidation-a ( -- ) ;
: inference-invalidation-b ( quot -- ) [ inference-invalidation-a ] dip call ; inline
: inference-invalidation-c ( a b -- c ) [ + ] inference-invalidation-b ; inline

[ 7 ] [ 4 3 inference-invalidation-c ] unit-test

{ 2 1 } [ [ + ] inference-invalidation-b ] must-infer-as

[ ] [ "IN: stack-checker.tests : inference-invalidation-a ( -- a b ) 1 2 ;" eval ] unit-test

[ 3 ] [ inference-invalidation-c ] unit-test

{ 0 1 } [ inference-invalidation-c ] must-infer-as

GENERIC: inference-invalidation-d ( obj -- )

M: object inference-invalidation-d inference-invalidation-c 2drop ;

\ inference-invalidation-d must-infer

[ ] [ "IN: stack-checker.tests : inference-invalidation-a ( -- ) ;" eval ] unit-test

[ [ inference-invalidation-d ] infer ] must-fail

: bad-recursion-3 ( -- ) dup [ [ bad-recursion-3 ] dip ] when ; inline recursive
[ [ bad-recursion-3 ] infer ] must-fail

: bad-recursion-4 ( -- ) 4 [ dup call roll ] times ; inline recursive
[ [ [ ] [ 1 2 3 ] over dup bad-recursion-4 ] infer ] must-fail

: bad-recursion-5 ( obj quot: ( -- ) -- ) dup call swap bad-recursion-5 ; inline recursive
[ [ f [ ] bad-recursion-5 ] infer ] must-fail

: bad-recursion-6 ( quot: ( -- ) -- )
    dup bad-recursion-6 call ; inline recursive
[ [ [ drop f ] bad-recursion-6 ] infer ] must-fail

{ 3 0 } [ [ 2drop "A" throw ] [ ] if 2drop ] must-infer-as
{ 2 0 } [ drop f f [ 2drop "A" throw ] [ ] if 2drop ] must-infer-as

: unbalanced-retain-usage ( a b -- )
    dup 10 < [ 2drop 5 1 + unbalanced-retain-usage ] [ 2drop ] if ;
    inline recursive

[ [ unbalanced-retain-usage ] infer ] [ inference-error? ] must-fail-with

DEFER: eee'
: ddd' ( ? -- ) [ f eee' ] when ; inline recursive
: eee' ( ? -- ) [ swap [ ] ] dip ddd' call ; inline recursive

[ [ eee' ] infer ] [ inference-error? ] must-fail-with

: bogus-error ( x -- )
    dup "A" throw [ bogus-error ] [ drop ] if ; inline recursive

[ bogus-error ] must-infer

[ [ clear ] infer. ] [ inference-error? ] must-fail-with

: debugging-curry-folding ( quot -- )
    [ debugging-curry-folding ] curry call ; inline recursive

[ [ ] debugging-curry-folding ] must-infer

[ [ exit ] [ 1 2 3 ] if ] must-infer

! Stack effects are required now but FORGET: clears them...
: forget-test ( -- ) ;

[ forget-test ] must-infer
[ ] [ [ \ forget-test forget ] with-compilation-unit ] unit-test
[ forget-test ] must-infer