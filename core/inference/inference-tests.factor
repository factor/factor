USING: arrays generic inference inference.backend
inference.dataflow kernel classes kernel.private math
math.parser math.private namespaces namespaces.private parser
sequences strings vectors words quotations effects tools.test
continuations generic.standard sorting assocs definitions
prettyprint io inspector bootstrap.image tuples
classes.union classes.predicate debugger bootstrap.image
bootstrap.image.private io.launcher threads.private
io.streams.string combinators.private ;
IN: temporary

: short-effect
    dup effect-in length swap effect-out length 2array ;

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
    [ [ [ 2 2 fixnum+ ] ] [ [ 2 2 fixnum* ] ] if call ] infer
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
MATH: xyz
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
[ t ] [
    [ [ [ dup call ] dup call ] infer ] catch
    inference-error?
] unit-test

: m dup call ; inline

[ t ] [
    [ [ [ m ] m ] infer ] catch inference-error?
] unit-test

: m' dup curry call ; inline

[ t ] [
    [ [ [ m' ] m' ] infer ] catch inference-error?
] unit-test

: m'' [ dup curry ] ; inline

: m''' m'' call call ; inline

[ t ] [
    [ [ [ m''' ] m''' ] infer ] catch inference-error?
] unit-test

: m-if t over if ; inline

[ t ] [
    [ [ [ m-if ] m-if ] infer ] catch inference-error?
] unit-test

! This doesn't hang but it's also an example of the
! undedicable case
[ t ] [
    [ [ [ [ drop 3 ] swap call ] dup call ] infer ] catch
    inference-error?
] unit-test

! This form should not have a stack effect

: bad-recursion-1 ( a -- b )
    dup [ drop bad-recursion-1 5 ] [ ] if ;

[ [ bad-recursion-1 ] infer short-effect ] unit-test-fails

: bad-bin ( a b -- ) 5 [ 5 bad-bin bad-bin 5 ] [ 2drop ] if ;
[ [ bad-bin ] infer short-effect ] unit-test-fails

[ t ] [ [ [ r> ] infer short-effect ] catch inference-error? ] unit-test

! Regression
[ t ] [ [ [ get-slots ] infer ] catch inference-error? ] unit-test

! Test some curry stuff
[ { 1 1 } ] [ [ 3 [ ] curry 4 [ ] curry if ] infer short-effect ] unit-test

[ { 2 1 } ] [ [ [ ] curry 4 [ ] curry if ] infer short-effect ] unit-test

[ [ 3 [ ] curry 1 2 [ ] 2curry if ] infer ] unit-test-fails

! Test number protocol
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

! Test object protocol
[ { 2 1 } ] [ [ = ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ clone ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ hashcode* ] infer short-effect ] unit-test

! Test sequence protocol
[ { 1 1 } ] [ [ length ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ nth ] infer short-effect ] unit-test
[ { 2 0 } ] [ [ set-length ] infer short-effect ] unit-test
[ { 3 0 } ] [ [ set-nth ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ new ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ new-resizable ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ like ] infer short-effect ] unit-test
[ { 2 0 } ] [ [ lengthen ] infer short-effect ] unit-test

! Test assoc protocol
[ { 2 2 } ] [ [ at* ] infer short-effect ] unit-test
[ { 3 0 } ] [ [ set-at ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ new-assoc ] infer short-effect ] unit-test
[ { 2 0 } ] [ [ delete-at ] infer short-effect ] unit-test
[ { 1 0 } ] [ [ clear-assoc ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ assoc-size ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ assoc-like ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ assoc-clone-like ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ >alist ] infer short-effect ] unit-test
[ { 1 3 } ] [ [ [ 2drop f ] assoc-find ] infer short-effect ] unit-test

! Test some random library words
[ { 1 1 } ] [ [ 1quotation ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ string>number ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ get ] infer short-effect ] unit-test

[ { 2 0 } ] [ [ push ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ append ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ peek ] infer short-effect ] unit-test

[ { 1 1 } ] [ [ reverse ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ member? ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ remove ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ natural-sort ] infer short-effect ] unit-test

[ { 1 0 } ] [ [ forget ] infer short-effect ] unit-test
[ { 4 0 } ] [ [ define-class ] infer short-effect ] unit-test
[ { 2 0 } ] [ [ define-tuple-class ] infer short-effect ] unit-test
[ { 2 0 } ] [ [ define-union-class ] infer short-effect ] unit-test
[ { 3 0 } ] [ [ define-predicate-class ] infer short-effect ] unit-test

! Test words with continuations
[ { 0 0 } ] [ [ [ drop ] callcc0 ] infer short-effect ] unit-test
[ { 0 1 } ] [ [ [ 4 swap continue-with ] callcc1 ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ [ + ] [ ] [ ] cleanup ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ [ + ] [ 3drop 0 ] recover ] infer short-effect ] unit-test

! Test stream protocol
[ { 2 0 } ] [ [ set-timeout ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ stream-read ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ stream-read1 ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ stream-readln ] infer short-effect ] unit-test
[ { 2 2 } ] [ [ stream-read-until ] infer short-effect ] unit-test
[ { 2 0 } ] [ [ stream-write ] infer short-effect ] unit-test
[ { 2 0 } ] [ [ stream-write1 ] infer short-effect ] unit-test
[ { 1 0 } ] [ [ stream-nl ] infer short-effect ] unit-test
[ { 1 0 } ] [ [ stream-close ] infer short-effect ] unit-test
[ { 3 0 } ] [ [ stream-format ] infer short-effect ] unit-test
[ { 3 0 } ] [ [ stream-write-table ] infer short-effect ] unit-test
[ { 1 0 } ] [ [ stream-flush ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ make-span-stream ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ make-block-stream ] infer short-effect ] unit-test
[ { 2 1 } ] [ [ make-cell-stream ] infer short-effect ] unit-test

! Test stream utilities
[ { 1 1 } ] [ [ lines ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ contents ] infer short-effect ] unit-test

! Test prettyprinting
[ { 1 0 } ] [ [ . ] infer short-effect ] unit-test
[ { 1 0 } ] [ [ short. ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ unparse ] infer short-effect ] unit-test

[ { 1 0 } ] [ [ describe ] infer short-effect ] unit-test
[ { 1 0 } ] [ [ error. ] infer short-effect ] unit-test

! Test odds and ends
[ { 1 1 } ] [ [ ' ] infer short-effect ] unit-test
[ { 2 0 } ] [ [ write-image ] infer short-effect ] unit-test
[ { 1 1 } ] [ [ <process-stream> ] infer short-effect ] unit-test
[ { 0 0 } ] [ [ idle-thread ] infer short-effect ] unit-test

! Incorrect stack declarations on inline recursive words should
! be caught
: fooxxx ( a b -- c ) over [ foo ] when ; inline
: barxxx fooxxx ;

[ [ barxxx ] infer ] unit-test-fails

! A typo
[ { 1 0 } ] [ [ { [ ] } dispatch ] infer short-effect ] unit-test

DEFER: inline-recursive-2
: inline-recursive-1 ( -- ) inline-recursive-2 ;
: inline-recursive-2 ( -- ) inline-recursive-1 ;

[ { 0 0 } ] [ [ inline-recursive-1 ] infer short-effect ] unit-test

! Hooks
SYMBOL: my-var
HOOK: my-hook my-var ( -- x )

M: integer my-hook "an integer" ;
M: string my-hook "a string" ;

[ { 0 1 } ] [ [ my-hook ] infer short-effect ] unit-test

DEFER: deferred-word

: calls-deferred-word [ deferred-word ] [ 3 ] if ;

[ { 1 1 } ] [ [ calls-deferred-word ] infer short-effect ] unit-test

USE: inference.dataflow

[ { 1 0 } ] [ [ [ iterate-next ] iterate-nodes ] infer short-effect ] unit-test

[ { 1 0 } ] [
    [
        [ [ iterate-next ] iterate-nodes ] with-node-iterator
    ] infer short-effect
] unit-test

: nilpotent ( quot -- )
    t [ [ call ] keep nilpotent ] [ drop ] if ; inline

: semisimple ( quot -- )
    [ call ] keep [ [ semisimple ] keep ] nilpotent drop ; inline

[ { 0 1 } ] [
    [ [ ] [ call ] keep [ [ call ] keep ] nilpotent ]
    infer short-effect
] unit-test

[ { 0 0 } ] [ [ [ ] semisimple ] infer short-effect ] unit-test

[ { 1 0 } ] [ [ [ drop ] each-node ] infer short-effect ] unit-test

DEFER: an-inline-word

: normal-word-3 ( -- )
    3 [ [ 2 + ] curry ] an-inline-word call drop ;

: normal-word-2 ( -- )
    normal-word-3 ;

: normal-word ( x -- x )
    dup [ normal-word-2 ] when ;

: an-inline-word ( obj quot -- )
    >r normal-word r> call ; inline

[ { 1 1 } ] [ [ [ 3 * ] an-inline-word ] infer short-effect ] unit-test

[ { 0 1 } ] [ [ [ 2 ] [ 2 ] [ + ] compose compose call ] infer short-effect ] unit-test

TUPLE: custom-error ;

[ T{ effect f 0 0 t } ] [
    [ custom-error construct-boa throw ] infer
] unit-test

: funny-throw throw ; inline

[ T{ effect f 0 0 t } ] [
    [ 3 funny-throw ] infer
] unit-test

[ T{ effect f 0 0 t } ] [
    [ custom-error inference-error ] infer
] unit-test

[ T{ effect f 1 1 t } ] [
    [ dup >r 3 throw r> ] infer
] unit-test

! This was a false trigger of the undecidable quotation
! recursion bug
[ { 2 1 } ] [ [ find-last-sep ] infer short-effect ] unit-test
