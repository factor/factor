IN: temporary
USING: arrays math.private kernel math compiler inference
inference.dataflow optimizer tools.test kernel.private generic
sequences words inference.class quotations alien
alien.c-types strings sbufs sequences.private
slots.private combinators ;

! Make sure these compile even though this is invalid code
[ ] [ [ 10 mod 3.0 /i ] dataflow optimize drop ] unit-test
[ ] [ [ 10 mod 3.0 shift ] dataflow optimize drop ] unit-test

! Ensure type inference works as it is supposed to by checking
! if various methods get inlined

: inlined? ( quot word -- ? )
    swap dataflow optimize
    [ node-param eq? ] curry* node-exists? not ;

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
    [ { fixnum } declare dup 100 >= [ 1 + ] unless ] \ fixnum+ inlined?
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
    [ { fixnum } declare [ ] times ] \ >= inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ ] times ] \ 1+ inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ ] times ] \ + inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ ] times ] \ fixnum+ inlined?
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

GENERIC: detect-fx ( n -- n )

M: fixnum detect-fx ;

[ t ] [
    [
        [ uchar-nth ] 2keep [ uchar-nth ] 2keep uchar-nth
        >r >r 298 * r> 100 * - r> 208 * - 128 + -8 shift
        255 min 0 max detect-fx
    ] \ detect-fx inlined?
] unit-test

[ f ] [
    [
        1000000000000000000000000000000000 [ ] times
    ] \ 1+ inlined?
] unit-test

[ f ] [
    [ { bignum } declare [ ] times ] \ 1+ inlined?
] unit-test


[ t ] [
    [ { string sbuf } declare push-all ] \ push-all inlined?
] unit-test

[ t ] [
    [ { string sbuf } declare push-all ] \ + inlined?
] unit-test

[ t ] [
    [ { string sbuf } declare push-all ] \ fixnum+ inlined?
] unit-test

[ t ] [
    [ { string sbuf } declare push-all ] \ >fixnum inlined?
] unit-test

[ t ] [
    [ { array-capacity } declare 0 < ] \ < inlined?
] unit-test

[ t ] [
    [ { array-capacity } declare 0 < ] \ fixnum< inlined?
] unit-test

[ t ] [
    [ { array-capacity } declare 1 fixnum- ] \ fixnum- inlined?
] unit-test

[ t ] [
    [ 5000 [ 5000 [ ] times ] times ] \ 1+ inlined?
] unit-test

[ t ] [
    [ 5000 [ [ ] times ] each ] \ 1+ inlined?
] unit-test

[ t ] [
    [ 5000 0 [ dup 2 - swap [ 2drop ] curry each ] reduce ]
    \ 1+ inlined?
] unit-test

GENERIC: annotate-entry-test-1 ( x -- )

M: fixnum annotate-entry-test-1 drop ;

: (annotate-entry-test-2) ( from to quot -- )
    pick pick >= [
        3drop
    ] [
        [ swap >r call dup annotate-entry-test-1 1+ r> ] keep (annotate-entry-test-2)
    ] if ; inline

: annotate-entry-test-2 0 -rot (annotate-entry-test-2) ; inline

[ f ] [
    [ { bignum } declare [ ] annotate-entry-test-2 ]
    \ annotate-entry-test-1 inlined?
] unit-test

[ t ] [
    [ { float } declare 10 [ 2.3 * ] times >float ]
    \ >float inlined?
] unit-test

[ t ] [
    [ 3 + = ] \ equal? inlined?
] unit-test
