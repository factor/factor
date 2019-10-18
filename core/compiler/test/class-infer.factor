IN: temporary
USING: arrays math-internals kernel math compiler inference
optimizer test kernel-internals generic sequences words
class-inference ;

! Ensure type inference works as it is supposed to by checking
! if various methods get inlined

: inlined? ( quot word -- ? )
    swap dataflow optimize
    [ node-param eq? not ] all-nodes-with? ;

GENERIC: mynot ( x -- y )

M: f mynot drop t ;

M: general-t mynot drop f ;

GENERIC: detect-f ( x -- y )

M: f detect-f ;

[ t ] [
    [ dup [ mynot ] [ ] if detect-f ] \ detect-f inlined?
] unit-test

[ ] [ [ fixnum< ] dataflow optimize drop ] unit-test

[ ] [ [ fixnum< [ ] [ ] if ] dataflow optimize drop ] unit-test

FORGET: xyz

GENERIC: xyz ( n -- n )

M: integer xyz ;

M: object xyz ;

[ t ] [
    [ { integer } declare xyz ] \ xyz inlined?
] unit-test

[ t ] [
    [ dup fixnum? [ xyz ] [ drop "hi" ] if ]
    \ xyz inlined?
] unit-test

: (fx-repeat) ( i n quot -- )
    pick pick fixnum>= [
        3drop
    ] [
        [ swap >r call 1 fixnum+fast r> ] keep (fx-repeat)
    ] if ; inline

: fx-repeat ( n quot -- )
    0 -rot (fx-repeat) ; inline

! The + should be optimized into fixnum+, if it was not, then
! the type of the loop index was not inferred correctly
[ t ] [
    [ [ dup 2 + drop ] fx-repeat ] \ + inlined?
] unit-test

: (i-repeat) ( i n quot -- )
    pick pick dup xyz drop >= [
        3drop
    ] [
        [ swap >r call 1+ r> ] keep (i-repeat)
    ] if ; inline

: i-repeat >r { integer } declare r> 0 -rot (i-repeat) ; inline

[ t ] [
    [ [ dup xyz drop ] i-repeat ] \ xyz inlined?
] unit-test

[ t ] [
    [ dupd fixnum< [ small? ] when ] \ small? inlined?
] unit-test

[ f ] [
    [ dup fixnum? [ small? ] when ] \ small? inlined?
] unit-test

[ t ] [
    [ dupd fixnum>= [ 1 + ] unless ] \ fixnum+ inlined?
] unit-test

[ t ] [
    [ dupd fixnum< [ 1 + 1 + ] when ] \ + inlined?
] unit-test

[ f ] [
    [ dupd fixnum< [ 1 + 1 + 1 + ] when ] \ + inlined?
] unit-test

[ t ] [
    [ dupd fixnum>= [ 1 + 1 + ] unless ] \ + inlined?
] unit-test

[ f ] [
    [ dupd fixnum>= [ 1 + 1 + 1 + ] unless ] \ + inlined?
] unit-test

[ t ] [
    [ { fixnum fixnum } declare dupd < [ 1 + 1 + ] when ]
    \ + inlined?
] unit-test

[ t ] [
    [ { fixnum fixnum } declare dupd < [ 1 + 1 + ] when ]
    \ + inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ ] repeat ] \ <= inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ ] repeat ] \ 1+ inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ ] repeat ] \ + inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ ] repeat ] \ fixnum+ inlined?
] unit-test

[ f ] [
    [ { integer fixnum } declare dupd < [ 1 + ] when ]
    \ + inlined?
] unit-test

[ f ] [ [ dup 0 < [ neg ] when ] \ neg inlined? ] unit-test

[ f ] [
    [
        [ no-cond ] 1
        [ 1array dup quotation? [ >quotation ] unless ] times
    ] \ type inlined?
] unit-test

[ f ] [ [ <reversed> length ] \ slot inlined? ] unit-test

! We don't want to use = to compare literals
: foo reverse ;

\ foo [
    [
        fixnum 0 `output class,
        V{ } dup dup push 0 `input literal,
    ] set-constraints
] "constraints" set-word-prop

[ t ] [
    [ dup V{ } eq? [ foo ] when ] dup second dup push
    compile-quot word?
] unit-test
