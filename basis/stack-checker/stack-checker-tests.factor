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

[ 1234 infer ] must-fail

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
: too-deep ( a b -- c )
    dup [ drop ] [ 2dup too-deep too-deep * ] if ; inline recursive
{ 2 1 } [ too-deep ] must-infer-as

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

[ [ 1 drop-locals ] infer ] [ inference-error? ] must-fail-with

! Regression
[ [ cleave ] infer ] [ inference-error? ] must-fail-with

! Test some curry stuff
{ 1 1 } [ 3 [ ] curry 4 [ ] curry if ] must-infer-as

{ 2 1 } [ [ ] curry 4 [ ] curry if ] must-infer-as

[ [ 3 [ ] curry 1 2 [ ] 2curry if ] infer ] must-fail

{ 1 3 } [ [ 2drop f ] assoc-find ] must-infer-as

! Test words with continuations
{ 0 0 } [ [ drop ] callcc0 ] must-infer-as
{ 0 1 } [ [ 4 swap continue-with ] callcc1 ] must-infer-as
{ 2 1 } [ [ + ] [ ] [ ] cleanup ] must-infer-as
{ 2 1 } [ [ + ] [ 3drop 0 ] recover ] must-infer-as

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
[ [ 1 load-locals ] infer ] must-fail

! Corner case
[ [ [ f dup ] [ dup ] produce ] infer ] must-fail

[ [ [ f dup ] [ ] while ] infer ] must-fail

: erg's-inference-bug ( -- ) f dup [ erg's-inference-bug ] when ; inline recursive
[ [ erg's-inference-bug ] infer ] must-fail
FORGET: erg's-inference-bug

: bad-recursion-3 ( -- ) dup [ [ bad-recursion-3 ] dip ] when ; inline recursive
[ [ bad-recursion-3 ] infer ] must-fail
FORGET: bad-recursion-3

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

FORGET: unbalanced-retain-usage

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

[ [ cond ] infer ] must-fail
[ [ bi ] infer ] must-fail
[ at ] must-infer

[ [ [ "OOPS" throw ] dip ] [ drop ] if ] must-infer