USING: arrays errors generic inference kernel kernel-internals
math math-internals namespaces parser sequences strings test
vectors words ;
IN: temporary

: short-effect
    dup effect-in length swap effect-out length 2array nip ;

[ f ] [ f [ [ ] map-nodes ] with-node-iterator ] unit-test

[ t ] [ [ ] dataflow dup [ [ ] map-nodes ] with-node-iterator = ] unit-test

[ t ] [ [ 1 2 ] dataflow dup [ [ ] map-nodes ] with-node-iterator = ] unit-test

[ t ] [ [ [ ] [ ] if ] dataflow dup [ [ ] map-nodes ] with-node-iterator = ] unit-test

[ { 0 0 } ] [ f infer short-effect ] unit-test
[ { 0 2 } ] [ [ 2 "Hello" ] infer short-effect ] unit-test
[ { 1 2 } ] [ [ dup ] infer short-effect ] unit-test

[ { 1 2 } ] [ [ [ dup ] call ] infer short-effect ] unit-test
[ [ call ] infer short-effect ] unit-test-fails

[ { 2 4 } ] [ [ 2dup ] infer short-effect ] unit-test

[ { 1 0 } ] [ [ [ ] [ ] if ] infer short-effect ] unit-test
[ [ if ] infer short-effect ] unit-test-fails
[ [ [ ] if ] infer short-effect ] unit-test-fails
[ [ [ 2 ] [ ] if ] infer short-effect ] unit-test-fails
[ { 4 3 } ] [ [ [ rot ] [ -rot ] if ] infer short-effect ] unit-test

[ { 4 3 } ] [
    [
        [
            [ swap 3 ] [ nip 5 5 ] if
        ] [
            -rot
        ] if
    ] infer short-effect
] unit-test

[ { 1 1 } ] [ [ dup [ ] when ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ dup [ dup fixnum* ] when ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ [ dup fixnum* ] when ] infer short-effect ] unit-test

[ { 1 0 } ] [ [ [ drop ] when* ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ [ { { [ ] } } ] unless* ] infer short-effect ] unit-test

[ { 0 1 } ] [
    [ [ 2 2 fixnum+ ] dup [ ] when call ] infer short-effect
] unit-test

[
    [ [ 2 2 fixnum+ ] ] [ [ 2 2 fixnum* ] ] if call
] unit-test-fails

! Test inference of termination of control flow
: termination-test-1
    "foo" throw ;

: termination-test-2 [ termination-test-1 ] [ 3 ] if ;

[ { 1 1 } ] [ [ termination-test-2 ] infer short-effect ] unit-test

: infinite-loop infinite-loop ;

[ [ infinite-loop ] infer short-effect ] unit-test-fails

: no-base-case-1 dup [ no-base-case-1 ] [ no-base-case-1 ] if ;
[ [ no-base-case-1 ] infer short-effect ] unit-test-fails

: simple-recursion-1 ( obj -- obj )
    dup [ simple-recursion-1 ] [ ] if ;

[ { 1 1 } ] [ [ simple-recursion-1 ] infer short-effect ] unit-test

: simple-recursion-2 ( obj -- obj )
    dup [ ] [ simple-recursion-2 ] if ;

[ { 1 1 } ] [ [ simple-recursion-2 ] infer short-effect ] unit-test

: bad-recursion-2 ( obj -- obj )
    dup [ dup first swap second bad-recursion-2 ] [ ] if ;

[ [ bad-recursion-2 ] infer short-effect ] unit-test-fails

: funny-recursion ( obj -- obj )
    dup [ funny-recursion 1 ] [ 2 ] if drop ;

[ { 1 1 } ] [ [ funny-recursion ] infer short-effect ] unit-test

! Simple combinators
[ { 1 2 } ] [ [ [ first ] keep second ] infer short-effect ] unit-test

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

[ { 2 1 } ] [ [ fie ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ foe ] infer short-effect ] unit-test

: nested-when ( -- )
    t [
        t [
            5 drop
        ] when
    ] when ;

[ { 0 0 } ] [ [ nested-when ] infer short-effect ] unit-test

: nested-when* ( obj -- )
    [
        [
            drop
        ] when*
    ] when* ;

[ { 1 0 } ] [ [ nested-when* ] infer short-effect ] unit-test

SYMBOL: sym-test

[ { 0 1 } ] [ [ sym-test ] infer short-effect ] unit-test

: terminator-branch
    dup [
        length
    ] [
        "foo" throw
    ] if ;

[ { 1 1 } ] [ [ terminator-branch ] infer short-effect ] unit-test

: recursive-terminator ( obj -- )
    dup [
        recursive-terminator
    ] [
        "Hi" throw
    ] if ;

[ { 1 0 } ] [ [ recursive-terminator ] infer short-effect ] unit-test

GENERIC: potential-hang ( obj -- obj )
M: fixnum potential-hang dup [ potential-hang ] when ;

[ ] [ [ 5 potential-hang ] infer short-effect drop ] unit-test

TUPLE: funny-cons car cdr ;
GENERIC: iterate ( obj -- )
M: funny-cons iterate funny-cons-cdr iterate ;
M: f iterate drop ;
M: real iterate drop ;

[ { 1 0 } ] [ [ iterate ] infer short-effect ] unit-test

! Regression
: cat ( obj -- * ) dup [ throw ] [ throw ] if ;
: dog ( a b c -- ) dup [ cat ] [ 3drop ] if ;
[ { 3 0 } ] [ [ dog ] infer short-effect ] unit-test

! Regression
DEFER: monkey
: friend ( a b c -- ) dup [ friend ] [ monkey ] if ;
: monkey ( a b c -- ) dup [ 3drop ] [ friend ] if ;
[ { 3 0 } ] [ [ friend ] infer short-effect ] unit-test

! Regression -- same as above but we infer short-effect the second word first
DEFER: blah2
: blah ( a b c -- ) dup [ blah ] [ blah2 ] if ;
: blah2 ( a b c -- ) dup [ blah ] [ 3drop ] if ;
[ { 3 0 } ] [ [ blah2 ] infer short-effect ] unit-test

! Regression
DEFER: blah4
: blah3 ( a b c -- )
    dup [ blah3 ] [ dup [ blah4 ] [ blah3 ] if ] if ;
: blah4 ( a b c -- )
    dup [ blah4 ] [ dup [ 3drop ] [ blah3 ] if ] if ;
[ { 3 0 } ] [ [ blah4 ] infer short-effect ] unit-test

! Regression
: bad-combinator ( obj quot -- )
    over [
        2drop
    ] [
        [ swap slip ] keep swap bad-combinator
    ] if ; inline

[ [ [ 1 ] [ ] bad-combinator ] infer short-effect ] unit-test-fails

! Regression
: bad-input#
    dup string? [ 2array throw ] unless
    over string? [ 2array throw ] unless ;

[ { 2 2 } ] [ [ bad-input# ] infer short-effect ] unit-test

! Regression

! This order of branches works
DEFER: do-crap
: more-crap ( obj -- ) dup [ drop ] [ dup do-crap call ] if ;
: do-crap ( obj -- ) dup [ more-crap ] [ do-crap ] if ;
[ [ do-crap ] infer short-effect ] unit-test-fails

! This one does not
DEFER: do-crap*
: more-crap* ( obj -- ) dup [ drop ] [ dup do-crap* call ] if ;
: do-crap* ( obj -- ) dup [ do-crap* ] [ more-crap* ] if ;
[ [ do-crap* ] infer short-effect ] unit-test-fails

! Regression
: too-deep ( a b -- c )
    dup [ drop ] [ 2dup too-deep too-deep * ] if ; inline
[ { 2 1 } ] [ [ too-deep ] infer short-effect ] unit-test

! Error reporting is wrong
G: xyz math-combination ;
M: fixnum xyz 2array ;
M: ratio xyz 
    [ >fraction ] 2apply swapd >r 2array swap r> 2array swap ;

[ t ] [ [ [ xyz ] infer short-effect ] catch inference-error? ] unit-test

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

[ { 1 0 } ] [ [ A ] infer short-effect ] unit-test
[ { 1 0 } ] [ [ B ] infer short-effect ] unit-test
[ { 1 0 } ] [ [ C ] infer short-effect ] unit-test

! I found this bug by thinking hard about the previous one
DEFER: Y
: X ( a b -- c d ) dup [ swap Y ] [ ] if ;
: Y ( a b -- c d ) X ;

[ { 2 2 } ] [ [ X ] infer short-effect ] unit-test
[ { 2 2 } ] [ [ Y ] infer short-effect ] unit-test

! This one comes from UI code
DEFER: #1
: #2 ( a b -- ) dup [ call ] [ 2drop ] if ; inline
: #3 ( a -- ) [ #1 ] #2 ;
: #4 ( a -- ) dup [ drop ] [ dup #4 dup #3 call ] if ;
: #1 ( a -- ) dup [ dup #4 dup #3 ] [ ] if drop ;

[ \ #4 word-def infer short-effect ] unit-test-fails
[ [ #1 ] infer short-effect ] unit-test-fails

! Similar
DEFER: bar
: foo ( a b -- c d ) dup [ 2drop f f bar ] [ ] if ;
: bar ( a b -- ) [ 2 2 + ] t foo drop call drop ;

[ [ foo ] infer short-effect ] unit-test-fails

[ 1234 infer short-effect ] unit-test-fails

! This used to hang
[ [ [ dup call ] dup call ] infer short-effect ] unit-test-fails

! This form should not have a stack effect

: bad-recursion-1 ( a -- b )
    dup [ drop bad-recursion-1 5 ] [ ] if ;

[ [ bad-recursion-1 ] infer short-effect ] unit-test-fails

: bad-bin ( a b -- ) 5 [ 5 bad-bin bad-bin 5 ] [ 2drop ] if ;
[ [ bad-bin ] infer short-effect ] unit-test-fails

[ t ] [ [ [ r> ] infer short-effect ] catch inference-error? ] unit-test

! Test some random library words

[ { 1 1 } ] [ [ unit ] infer short-effect ] unit-test

! Unbalanced >n/n> is an error now!
! [ { 1 0 } ] [ [ >n ] infer short-effect ] unit-test
! [ { 0 1 } ] [ [ n> ] infer short-effect ] unit-test

[ { 2 1 } ] [ [ bitor ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ bitand ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ bitxor ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ mod ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ /i ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ /f ] infer short-effect ] unit-test
[ { 2 2 } ] [ [ /mod ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ + ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ - ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ * ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ / ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ < ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ <= ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ > ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ >= ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ number= ] infer short-effect ] unit-test

[ { 1 1 } ] [ [ string>number ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ = ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ get ] infer short-effect ] unit-test

[ { 2 0 } ] [ [ push ] infer short-effect ] unit-test
[ { 2 0 } ] [ [ set-length ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ append ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ peek ] infer short-effect ] unit-test

[ { 1 1 } ] [ [ length ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ reverse ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ member? ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ remove ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ natural-sort ] infer short-effect ] unit-test

! Test scope inference
SYMBOL: x

[ [ n> ] infer ] unit-test-fails
[ [ ndrop ] infer ] unit-test-fails
[ V{ x } ] [ [ x get ] infer drop inferred-vars-reads ] unit-test
[ V{ x } ] [ [ x set ] infer drop inferred-vars-writes ] unit-test
[ V{ x } ] [ [ [ x get ] with-scope ] infer drop inferred-vars-reads ] unit-test
[ V{ } ] [ [ [ x set ] with-scope ] infer drop inferred-vars-writes ] unit-test
[ V{ x } ] [ [ [ x get ] bind ] infer drop inferred-vars-reads ] unit-test
[ V{ } ] [ [ [ x set ] bind ] infer drop inferred-vars-writes ] unit-test
[ V{ x } ] [ [ [ x get ] make-hash ] infer drop inferred-vars-reads ] unit-test
[ V{ } ] [ [ [ x set ] make-hash ] infer drop inferred-vars-writes ] unit-test
[ V{ building } ] [ [ , ] infer drop inferred-vars-reads ] unit-test
[ V{ } ] [ [ [ 3 , ] { } make ] infer drop inferred-vars-reads ] unit-test
[ V{ x } ] [ [ [ x get ] [ 5 ] if ] infer drop inferred-vars-reads ] unit-test
[ V{ x } ] [ [ >n [ x get ] [ 5 ] if n> ] infer drop inferred-vars-reads ] unit-test
[ V{ } ] [ [ >n [ x set ] [ drop ] if x get n> ] infer drop inferred-vars-reads ] unit-test
[ V{ x } ] [ [ >n x get ndrop ] infer drop inferred-vars-reads ] unit-test
[ V{ } ] [ [ >n x set ndrop ] infer drop inferred-vars-writes ] unit-test

[ [ >n ] [ ] if ] unit-test-fails
