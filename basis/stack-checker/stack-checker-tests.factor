USING: accessors arrays generic stack-checker
stack-checker.backend stack-checker.errors kernel classes
kernel.private math math.parser math.private namespaces
namespaces.private parser sequences strings vectors words
quotations effects tools.test continuations generic.standard
sorting assocs definitions prettyprint io inspector
classes.tuple classes.union classes.predicate debugger
threads.private io.streams.string io.timeouts io.thread
sequences.private destructors combinators eval locals.backend
system compiler.units vocabs combinators.smart ;
IN: stack-checker.tests

[ 1234 infer ] must-fail

{ 0 2 } [ 2 "Hello" ] must-infer-as
{ 1 2 } [ dup ] must-infer-as

{ 1 2 } [ [ dup ] call ] must-infer-as
[ [ call ] infer ] [ T{ unknown-macro-input f call } = ] must-fail-with
[ [ curry call ] infer ] [ T{ unknown-macro-input f call } = ] must-fail-with
[ [ { } >quotation call ] infer ] [ T{ bad-macro-input f call } = ] must-fail-with
[ [ append curry call ] infer ] [ T{ bad-macro-input f call } = ] must-fail-with

{ 2 4 } [ 2dup ] must-infer-as

{ 1 0 } [ [ ] [ ] if ] must-infer-as
[ [ if ] infer ] [ T{ unknown-macro-input f if } = ] must-fail-with
[ [ { } >quotation { } >quotation if ] infer ] [ T{ bad-macro-input f if } = ] must-fail-with
[ [ [ ] if ] infer ] [ T{ unknown-macro-input f if } = ] must-fail-with
[ [ [ 2 ] [ ] if ] infer ] [ unbalanced-branches-error? ] must-fail-with
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
] [ T{ bad-macro-input f call } = ] must-fail-with

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

{ } [ [ 5 potential-hang ] infer drop ] unit-test

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
        [ dip ] 1guard bad-combinator
    ] if ; inline recursive

[ [ [ 1 ] [ ] bad-combinator ] infer ] must-fail

! Regression
{ 2 2 } [
    dup string? [ 2array throw ] unless
    over string? [ 2array throw ] unless
] must-infer-as

! Regression
: too-deep ( a b -- c )
    dup [ drop ] [ 2dup too-deep too-deep * ] if ; inline recursive
{ 2 1 } [ too-deep ] must-infer-as

! This used to hang
[ [ [ dup call ] dup call ] infer ]
[ recursive-quotation-error? ] must-fail-with

: m ( q -- ) dup call ; inline

[ [ [ m ] m ] infer ] [ recursive-quotation-error? ] must-fail-with

: m' ( quot -- ) dup curry call ; inline

[ [ [ m' ] m' ] infer ] [ recursive-quotation-error? ] must-fail-with

: m'' ( -- q ) [ dup curry ] ; inline

: m''' ( -- ) m'' call call ; inline

[ [ [ m''' ] m''' ] infer ] [ recursive-quotation-error? ] must-fail-with

: m-if ( a b c -- ) t over when ; inline

[ [ [ m-if ] m-if ] infer ] [ recursive-quotation-error? ] must-fail-with

! This doesn't hang but it's also an example of the
! undedicable case
[ [ [ [ drop 3 ] swap call ] dup call ] infer ]
[ recursive-quotation-error? ] must-fail-with

[ [ 1 drop-locals ] infer ] [ too-many-r>? ] must-fail-with

! Regression
[ [ cleave ] infer ] [ T{ unknown-macro-input f cleave } = ] must-fail-with

! Test some curry stuff
{ 1 1 } [ 3 [ ] curry 4 [ ] curry if ] must-infer-as
{ 3 1 } [ [ ] curry [ [ ] curry ] dip if ] must-infer-as

{ 2 1 } [ [ ] curry 4 [ ] curry if ] must-infer-as

[ [ 3 [ ] curry 1 2 [ ] 2curry if ] infer ] [ unbalanced-branches-error? ] must-fail-with
[ [ [ ] curry [ [ ] 2curry ] dip if ] infer ] [ unbalanced-branches-error? ] must-fail-with

{ 1 3 } [ [ 2drop f ] assoc-find ] must-infer-as

! Test words with continuations
{ 0 0 } [ [ drop ] callcc0 ] must-infer-as
{ 0 1 } [ [ 4 swap continue-with ] callcc1 ] must-infer-as
{ 2 1 } [ [ + ] [ ] finally ] must-infer-as
{ 2 1 } [ [ + ] [ 3drop 0 ] recover ] must-infer-as

! A typo
{ 1 0 } [ { [ ] } dispatch ] must-infer-as

! Make sure the error is correct
[
    [ { [ drop ] [ dup ] } dispatch ] infer
] [ word>> \ dispatch eq? ] must-fail-with

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

{ T{ effect f { } { } t } } [
    [ custom-error ] infer
] unit-test

: funny-throw ( a -- * ) throw ; inline

{ T{ effect f { } { } t } } [
    [ 3 funny-throw ] infer
] unit-test

{ T{ effect f { } { } t } } [
    [ custom-error inference-error ] infer
] unit-test

{ T{ effect f { "x" } { "x" "x" } t } } [
    [ dup [ 3 throw ] dip ] infer
] unit-test

! Regression
[ [ 1 load-locals ] infer ] [ too-many->r? ] must-fail-with

! Corner case
[ [ [ f dup ] [ dup ] produce ] infer ] must-fail

[ [ [ f dup ] [ ] while ] infer ] must-fail

: erg's-inference-bug ( -- ) f dup [ erg's-inference-bug ] when ; inline recursive
[ [ erg's-inference-bug ] infer ] must-fail
FORGET: erg's-inference-bug

: bad-recursion-3 ( -- ) dup [ [ bad-recursion-3 ] dip ] when ; inline recursive
[ [ bad-recursion-3 ] infer ] must-fail
FORGET: bad-recursion-3

: bad-recursion-4 ( -- ) 4 [ dup call [ rot ] dip swap ] times ; inline recursive
[ [ [ ] [ 1 2 3 ] over dup bad-recursion-4 ] infer ] must-fail

: bad-recursion-5 ( obj quot: ( -- ) -- ) dup call swap bad-recursion-5 ; inline recursive
[ [ f [ ] bad-recursion-5 ] infer ] must-fail

: bad-recursion-6 ( quot: ( -- ) -- )
    dup bad-recursion-6 call ; inline recursive
[ [ [ drop f ] bad-recursion-6 ] infer ] must-fail

{ } [ [ \ bad-recursion-6 forget ] with-compilation-unit ] unit-test

{ 3 0 } [ [ 2drop "A" throw ] [ ] if 2drop ] must-infer-as
{ 2 0 } [ drop f f [ 2drop "A" throw ] [ ] if 2drop ] must-infer-as

: unbalanced-retain-usage ( a b -- )
    dup 10 <
    [ 2drop 5 1 + unbalanced-retain-usage ]
    [ 2drop ] if ; inline recursive

[ [ unbalanced-retain-usage ] infer ] [ inference-error? ] must-fail-with

FORGET: unbalanced-retain-usage

DEFER: eee'
: ddd' ( ? -- ) [ f eee' ] when ; inline recursive
: eee' ( ? -- ) [ swap [ ] ] dip ddd' call ; inline recursive

[ [ eee' ] infer ] [ inference-error? ] must-fail-with

{ } [ [ \ ddd' forget ] with-compilation-unit ] unit-test
{ } [ [ \ eee' forget ] with-compilation-unit ] unit-test

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
{ } [ [ \ forget-test forget ] with-compilation-unit ] unit-test
[ forget-test ] must-infer

[ [ cond ] infer ] [ T{ unknown-macro-input f cond } = ] must-fail-with
[ [ call ] infer ] [ T{ unknown-macro-input f call } = ] must-fail-with
[ [ dip ] infer ] [ T{ unknown-macro-input f call } = ] must-fail-with

[ [ each ] infer ] [ T{ unknown-macro-input f each } = ] must-fail-with
[ [ if* ] infer ] [ T{ unknown-macro-input f if* } = ] must-fail-with
[ [ [ "derp" ] if* ] infer ] [ T{ unknown-macro-input f if* } = ] must-fail-with

[ [ [ "OOPS" throw ] dip ] [ drop ] if ] must-infer

! Found during code review
[ [ [ drop [ ] ] when call ] infer ] must-fail
[ swap [ [ drop [ ] ] when call ] infer ] must-fail

{ 3 1 } [ call( a b -- c ) ] must-infer-as
{ 3 1 } [ execute( a b -- c ) ] must-infer-as

[ [ call-effect ] infer ] [ T{ unknown-macro-input f call-effect } = ] must-fail-with
[ [ execute-effect ] infer ] [ T{ unknown-macro-input f execute-effect } = ] must-fail-with

[ \ set-datastack def>> infer ] [ T{ do-not-compile f do-primitive } = ] must-fail-with
{ } [ [ \ set-datastack def>> infer ] try ] unit-test

! Make sure all primitives are covered
{ { } } [
    all-words [ primitive? ] filter
    [ "default-output-classes" word-prop ] reject
    [ "special" word-prop ] reject
    [ "shuffle" word-prop ] reject
] unit-test

{ 1 0 } [ [ drop       ] each ] must-infer-as
{ 2 1 } [ [ append     ] each ] must-infer-as
{ 1 1 } [ [            ] map  ] must-infer-as
{ 1 1 } [ [ reverse    ] map  ] must-infer-as
{ 2 2 } [ [ append dup ] map  ] must-infer-as
{ 2 2 } [ [ swap nth suffix dup ] map-index ] must-infer-as

{ 4 1 } [ [ 2drop ] [ 2nip    ] if ] must-infer-as
{ 3 3 } [ [ dup   ] [ over    ] if ] must-infer-as
{ 1 1 } [ [ 1     ] [ 0       ] if ] must-infer-as
{ 2 2 } [ [ t     ] [ 1 + f   ] if ] must-infer-as

{ 1 0 } [ [ write     ] [ "(f)" write ] if* ] must-infer-as
{ 1 1 } [ [           ] [ f           ] if* ] must-infer-as
{ 2 1 } [ [ nip       ] [ drop f      ] if* ] must-infer-as
{ 2 1 } [ [ nip       ] [             ] if* ] must-infer-as
{ 3 2 } [ [ 3append f ] [             ] if* ] must-infer-as
{ 1 0 } [ [ drop      ] [             ] if* ] must-infer-as

{ 1 1 } [ [ 1 +       ] [ "oops" throw ] if* ] must-infer-as

: strict-each ( seq quot: ( x -- ) -- )
    each ; inline
: strict-map ( seq quot: ( x -- x' ) -- seq' )
    map ; inline
: strict-2map ( xs ys quot: ( x y -- z ) -- zs )
    2map ; inline

{ 1 0 } [ [ drop ] strict-each ] must-infer-as
{ 1 1 } [ [ 1 + ] strict-map ] must-infer-as
{ 1 1 } [ [  ] strict-map ] must-infer-as
{ 2 1 } [ [ + ] strict-2map ] must-infer-as
{ 2 1 } [ [ drop ] strict-2map ] must-infer-as
[ [ [ append ] strict-each ] infer ] [ unbalanced-branches-error? ] must-fail-with
[ [ [ 1 + ] strict-2map ] infer ] [ unbalanced-branches-error? ] must-fail-with

! ensure that polymorphic checking works on recursive combinators
: (recursive-reduce) ( identity i seq quot: ( prev elt -- next ) n -- result )
    pickd tuck < [
        [ [ [ nth-unsafe ] dip call ] 3keep [ 1 + ] 2dip ] dip
        (recursive-reduce)
    ] [ 4drop ] if ; inline recursive
: recursive-reduce ( seq i quot: ( prev elt -- next ) -- result )
    swapd [ 0 ] 2dip over length (recursive-reduce) ; inline
{ 24995000 } [ 10000 <iota> 0 [ dup even? [ + ] [ drop ] if ] recursive-reduce ] unit-test
{ 3 1 } [ [ member? [ 1 + ] when ] curry recursive-reduce ] must-infer-as

[ [ [ write write ] each      ] infer ] [ unbalanced-branches-error? ] must-fail-with

[ [ [             ] each      ] infer ] [ unbalanced-branches-error? ] must-fail-with
[ [ [ dup         ] map       ] infer ] [ unbalanced-branches-error? ] must-fail-with
[ [ [ drop        ] map       ] infer ] [ unbalanced-branches-error? ] must-fail-with
[ [ [ 1 +         ] map-index ] infer ] [ unbalanced-branches-error? ] must-fail-with

[ [ [ dup  ] [      ] if ] infer ] [ unbalanced-branches-error? ] must-fail-with
[ [ [ 2dup ] [ over ] if ] infer ] [ unbalanced-branches-error? ] must-fail-with
[ [ [ drop ] [      ] if ] infer ] [ unbalanced-branches-error? ] must-fail-with

[ [ [      ] [       ] if* ] infer ] [ unbalanced-branches-error? ] must-fail-with
[ [ [ dup  ] [       ] if* ] infer ] [ unbalanced-branches-error? ] must-fail-with
[ [ [ drop ] [ drop  ] if* ] infer ] [ unbalanced-branches-error? ] must-fail-with
[ [ [      ] [ drop  ] if* ] infer ] [ unbalanced-branches-error? ] must-fail-with
[ [ [      ] [ 2dup  ] if* ] infer ] [ unbalanced-branches-error? ] must-fail-with

! M\ declared-effect infer-call* didn't properly unify branches
{ 1 0 } [ [ 1 [ drop ] [ drop ] if ] each ] must-infer-as

! Make sure alien-callback effects are checked properly
USING: alien.c-types alien ;

[ void { } cdecl [ ] alien-callback ] must-infer

[ [ void { } cdecl [ f [ drop ] unless ] alien-callback ] infer ] [ unbalanced-branches-error? ] must-fail-with

[ [ void { } cdecl [ drop ] alien-callback ] infer ] [ effect-error? ] must-fail-with

[ [ int { } cdecl [ ] alien-callback ] infer ] [ effect-error? ] must-fail-with

[ int { } cdecl [ 5 ] alien-callback ] must-infer

[ int { int } cdecl [ ] alien-callback ] must-infer

[ int { int } cdecl [ 1 + ] alien-callback ] must-infer

[ void { int } cdecl [ . ] alien-callback ] must-infer

: recursive-callback-1 ( -- x )
    void { } cdecl [ recursive-callback-1 drop ] alien-callback ;

\ recursive-callback-1 def>> must-infer

: recursive-callback-2 ( -- x )
    void { } cdecl [ recursive-callback-2 drop ] alien-callback ; inline recursive

[ recursive-callback-2 ] must-infer

! test one-sided row polymorphism

: poly-output ( x a: ( x -- ..a ) -- ..a ) call ; inline

[ [ ] poly-output ] must-infer
[ [ f f f ] poly-output ] must-infer

: poly-input ( ..a a: ( ..a -- x ) -- x ) call ; inline

[ [ ] poly-input ] must-infer
[ [ drop drop drop ] poly-input ] must-infer

: poly-output-input ( x a: ( x -- ..a ) b: ( ..a -- y ) -- y ) [ call ] bi@ ; inline

[ [ ] [ ] poly-output-input ] must-infer
[ [ f f f ] [ drop drop drop ] poly-output-input ] must-infer
[ [ [ f f ] [ drop drop drop ] poly-output-input ] infer ] [ unbalanced-branches-error? ] must-fail-with
[ [ [ f f f ] [ drop drop ] poly-output-input ] infer ] [ unbalanced-branches-error? ] must-fail-with

: poly-input-output ( ..a a: ( ..a -- x ) b: ( x -- ..b ) -- ..b ) [ call ] bi@ ; inline

[ [ ] [ ] poly-input-output ] must-infer
[ [ drop drop drop ] [ f f f ] poly-input-output ] must-infer
[ [ drop drop ] [ f f f ] poly-input-output ] must-infer
[ [ drop drop drop ] [ f f ] poly-input-output ] must-infer

! Check that 'inputs' and 'outputs' work at compile-time

: inputs-test0 ( -- n )
    [ 5 + ] inputs ;

: inputs-test1 ( x -- n )
    [ + ] curry inputs ;

{ 1 } [ inputs-test0 ] unit-test
{ 1 } [ 10 inputs-test1 ] unit-test
