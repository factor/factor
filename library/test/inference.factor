IN: temporary
USING: arrays errors generic inference kernel kernel-internals
math math-internals namespaces parser sequences test vectors ;

[ f ] [ f [ [ ] map-nodes ] with-node-iterator ] unit-test

[ t ] [ [ ] dataflow dup [ [ ] map-nodes ] with-node-iterator = ] unit-test

[ t ] [ [ 1 2 ] dataflow dup [ [ ] map-nodes ] with-node-iterator = ] unit-test

[ t ] [ [ [ ] [ ] if ] dataflow dup [ [ ] map-nodes ] with-node-iterator = ] unit-test

[ { 0 0 } ] [ f infer ] unit-test
[ { 0 2 } ] [ [ 2 "Hello" ] infer ] unit-test
[ { 1 2 } ] [ [ dup ] infer ] unit-test

[ { 1 2 } ] [ [ [ dup ] call ] infer ] unit-test
[ [ call ] infer ] unit-test-fails

[ { 2 4 } ] [ [ 2dup ] infer ] unit-test

[ { 1 0 } ] [ [ [ ] [ ] if ] infer ] unit-test
[ [ if ] infer ] unit-test-fails
[ [ [ ] if ] infer ] unit-test-fails
[ [ [ 2 ] [ ] if ] infer ] unit-test-fails
[ { 4 3 } ] [ [ [ rot ] [ -rot ] if ] infer ] unit-test

[ { 4 3 } ] [
    [
        [
            [ swap 3 ] [ nip 5 5 ] if
        ] [
            -rot
        ] if
    ] infer
] unit-test

[ { 1 1 } ] [ [ dup [ ] when ] infer ] unit-test
[ { 1 1 } ] [ [ dup [ dup fixnum* ] when ] infer ] unit-test
[ { 2 1 } ] [ [ [ dup fixnum* ] when ] infer ] unit-test

[ { 1 0 } ] [ [ [ drop ] when* ] infer ] unit-test
[ { 1 1 } ] [ [ [ { { [ ] } } ] unless* ] infer ] unit-test

[ { 0 1 } ] [
    [ [ 2 2 fixnum+ ] dup [ ] when call ] infer
] unit-test

[
    [ [ 2 2 fixnum+ ] ] [ [ 2 2 fixnum* ] ] if call
] unit-test-fails

! Test inference of termination of control flow
: termination-test-1
    "foo" throw ;

: termination-test-2 [ termination-test-1 ] [ 3 ] if ;

[ { 1 1 } ] [ [ termination-test-2 ] infer ] unit-test

: infinite-loop infinite-loop ;

[ [ infinite-loop ] infer ] unit-test-fails

: no-base-case-1 dup [ no-base-case-1 ] [ no-base-case-1 ] if ;
[ [ no-base-case-1 ] infer ] unit-test-fails

: simple-recursion-1
    dup [ simple-recursion-1 ] [ ] if ;

[ { 1 1 } ] [ [ simple-recursion-1 ] infer ] unit-test

: simple-recursion-2
    dup [ ] [ simple-recursion-2 ] if ;

[ { 1 1 } ] [ [ simple-recursion-2 ] infer ] unit-test

: bad-recursion-2
    dup [ dup first swap second bad-recursion-2 ] [ ] if ;

[ [ bad-recursion-2 ] infer ] unit-test-fails

: funny-recursion
    dup [ funny-recursion 1 ] [ 2 ] if drop ;

[ { 1 1 } ] [ [ funny-recursion ] infer ] unit-test

! Simple combinators
[ { 1 2 } ] [ [ [ first ] keep second ] infer ] unit-test

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

[ { 2 1 } ] [ [ fie ] infer ] unit-test
[ { 2 1 } ] [ [ foe ] infer ] unit-test

: nested-when ( -- )
    t [
        t [
            5 drop
        ] when
    ] when ;

[ { 0 0 } ] [ [ nested-when ] infer ] unit-test

: nested-when* ( -- )
    [
        [
            drop
        ] when*
    ] when* ;

[ { 1 0 } ] [ [ nested-when* ] infer ] unit-test

SYMBOL: sym-test

[ { 0 1 } ] [ [ sym-test ] infer ] unit-test

: terminator-branch
    dup [
        length
    ] [
        "foo" throw
    ] if ;

[ { 1 1 } ] [ [ terminator-branch ] infer ] unit-test

: recursive-terminator
    dup [
        recursive-terminator
    ] [
        "Hi" throw
    ] if ;

[ { 1 0 } ] [ [ recursive-terminator ] infer ] unit-test

GENERIC: potential-hang
M: fixnum potential-hang dup [ potential-hang ] when ;

[ ] [ [ 5 potential-hang ] infer drop ] unit-test

TUPLE: funny-cons car cdr ;
GENERIC: iterate
M: funny-cons iterate funny-cons-cdr iterate ;
M: f iterate drop ;
M: real iterate drop ;

[ { 1 0 } ] [ [ iterate ] infer ] unit-test

DEFER: agent
: smith 1+ agent ; inline
: agent dup 0 = [ [ swap call ] 2keep smith ] when ; inline
[ { 0 2 } ]
[ [ [ drop ] 0 agent ] infer ] unit-test

: no-base-case-2 no-base-case-2 ;
[ [ no-base-case-2 ] infer ] unit-test-fails

! Regression
: cat dup [ throw ] [ throw ] if ;
: dog dup [ cat ] [ 3drop ] if ;
[ { 3 0 } ] [ [ dog ] infer ] unit-test

! Regression
DEFER: monkey
: friend dup [ friend ] [ monkey ] if ;
: monkey dup [ 3drop ] [ friend ] if ;
[ { 3 0 } ] [ [ friend ] infer ] unit-test

! Regression -- same as above but we infer the second word first
DEFER: blah2
: blah dup [ blah ] [ blah2 ] if ;
: blah2 dup [ blah ] [ 3drop ] if ;
[ { 3 0 } ] [ [ blah2 ] infer ] unit-test

! Regression
DEFER: blah4
: blah3 dup [ blah3 ] [ dup [ blah4 ] [ blah3 ] if ] if ;
: blah4 dup [ blah4 ] [ dup [ 3drop ] [ blah3 ] if ] if ;
[ { 3 0 } ] [ [ blah4 ] infer ] unit-test

! Regression
: bad-combinator ( obj quot -- )
    over [
        2drop
    ] [
        [ swap slip ] keep swap bad-combinator
    ] if ; inline

[ [ [ 1 ] [ ] bad-combinator ] infer ] unit-test-fails

! Regression
DEFER: do-crap
: more-crap dup [ drop ] [ dup do-crap call ] if ;
: do-crap dup [ do-crap ] [ more-crap ] if ;
[ [ do-crap ] infer ] unit-test-fails

! Regression
: too-deep dup [ drop ] [ 2dup too-deep too-deep * ] if ; inline
[ { 2 1 } ] [ [ too-deep ] infer ] unit-test

! Error reporting is wrong
G: xyz math-combination ;
M: fixnum xyz 2array ;
M: ratio xyz 
    [ >fraction ] 2apply swapd >r 2array swap r> 2array swap ;

[ t ] [ [ [ xyz ] infer ] catch inference-error? ] unit-test

! Doug Coleman discovered this one while working on the
! calendar library
DEFER: A
DEFER: B
DEFER: C

: A
    dup {
        [ drop ]
        [ A ]
        [ \ A no-method ]
        [ dup C A ]
    } dispatch ;

: B
    dup {
        [ C ]
        [ B ]
        [ \ B no-method ]
        [ dup B B ]
    } dispatch ;

: C
    dup {
        [ A ]
        [ C ]
        [ \ C no-method ]
        [ dup B C ]
    } dispatch ;

[ { 1 0 } ] [ [ A ] infer ] unit-test
[ { 1 0 } ] [ [ B ] infer ] unit-test
[ { 1 0 } ] [ [ C ] infer ] unit-test

! I found this bug by thinking hard about the previous one
DEFER: Y
: X dup [ swap Y ] [ ] if ;
: Y X ;

[ { 2 2 } ] [ [ X ] infer ] unit-test
[ { 2 2 } ] [ [ Y ] infer ] unit-test

[ 1234 infer ] unit-test-fails

! This hangs

[ [ [ dup call ] dup call ] infer ] unit-test-fails

! This form should not have a stack effect

: bad-recursion-1
    dup [ drop bad-recursion-1 5 ] [ ] if ;

[ [ bad-recursion-1 ] infer ] unit-test-fails

: bad-bin 5 [ 5 bad-bin bad-bin 5 ] [ 2drop ] if ;
[ [ bad-bin ] infer ] unit-test-fails

! Test some random library words

[ { 1 1 } ] [ [ unit ] infer ] unit-test

[ { 1 0 } ] [ [ >n ] infer ] unit-test
[ { 0 1 } ] [ [ n> ] infer ] unit-test

[ { 2 1 } ] [ [ bitor ] infer ] unit-test
[ { 2 1 } ] [ [ bitand ] infer ] unit-test
[ { 2 1 } ] [ [ bitxor ] infer ] unit-test
[ { 2 1 } ] [ [ mod ] infer ] unit-test
[ { 2 1 } ] [ [ /i ] infer ] unit-test
[ { 2 1 } ] [ [ /f ] infer ] unit-test
[ { 2 2 } ] [ [ /mod ] infer ] unit-test
[ { 2 1 } ] [ [ + ] infer ] unit-test
[ { 2 1 } ] [ [ - ] infer ] unit-test
[ { 2 1 } ] [ [ * ] infer ] unit-test
[ { 2 1 } ] [ [ / ] infer ] unit-test
[ { 2 1 } ] [ [ < ] infer ] unit-test
[ { 2 1 } ] [ [ <= ] infer ] unit-test
[ { 2 1 } ] [ [ > ] infer ] unit-test
[ { 2 1 } ] [ [ >= ] infer ] unit-test
[ { 2 1 } ] [ [ number= ] infer ] unit-test

[ { 1 1 } ] [ [ string>number ] infer ] unit-test
[ { 2 1 } ] [ [ = ] infer ] unit-test
[ { 1 1 } ] [ [ get ] infer ] unit-test

[ { 2 0 } ] [ [ push ] infer ] unit-test
[ { 2 0 } ] [ [ set-length ] infer ] unit-test
[ { 2 1 } ] [ [ append ] infer ] unit-test
[ { 1 1 } ] [ [ peek ] infer ] unit-test

[ { 1 1 } ] [ [ length ] infer ] unit-test
[ { 1 1 } ] [ [ reverse ] infer ] unit-test
[ { 2 1 } ] [ [ member? ] infer ] unit-test
[ { 2 1 } ] [ [ remove ] infer ] unit-test
