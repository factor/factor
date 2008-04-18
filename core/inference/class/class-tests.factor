IN: inference.class.tests
USING: arrays math.private kernel math compiler inference
inference.dataflow optimizer tools.test kernel.private generic
sequences words inference.class quotations alien
alien.c-types strings sbufs sequences.private
slots.private combinators definitions compiler.units
system layouts vectors optimizer.math.partial ;

! Make sure these compile even though this is invalid code
[ ] [ [ 10 mod 3.0 /i ] dataflow optimize drop ] unit-test
[ ] [ [ 10 mod 3.0 shift ] dataflow optimize drop ] unit-test

! Ensure type inference works as it is supposed to by checking
! if various methods get inlined

: inlined? ( quot seq/word -- ? )
    dup word? [ 1array ] when
    swap dataflow optimize
    [ node-param swap member? ] with node-exists? not ;

[ f ] [
    [ { integer } declare >fixnum ]
    \ >fixnum inlined?
] unit-test

GENERIC: mynot ( x -- y )

M: f mynot drop t ;

M: object mynot drop f ;

GENERIC: detect-f ( x -- y )

M: f detect-f ;

[ t ] [
    [ dup [ mynot ] [ ] if detect-f ] \ detect-f inlined?
] unit-test

[ ] [ [ fixnum< ] dataflow optimize drop ] unit-test

[ ] [ [ fixnum< [ ] [ ] if ] dataflow optimize drop ] unit-test

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
    2over fixnum>= [
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
    2over dup xyz drop >= [
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

[ t ] [
    [ { integer fixnum } declare dupd < [ 1 + ] when ]
    \ + inlined?
] unit-test

[ f ] [
    [ { integer fixnum } declare dupd < [ 1 + ] when ]
    \ +-integer-fixnum inlined?
] unit-test

[ f ] [ [ dup 0 < [ neg ] when ] \ - inlined? ] unit-test

[ f ] [
    [
        [ no-cond ] 1
        [ 1array dup quotation? [ >quotation ] unless ] times
    ] \ quotation? inlined?
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

DEFER: blah

[ ] [
    [
        \ blah
        [ dup V{ } eq? [ foo ] when ] dup second dup push define
    ] with-compilation-unit

    \ blah word-def dataflow optimize drop
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

[ t ] [
    [
        1000000000000000000000000000000000 [ ] times
    ] \ + inlined?
] unit-test
[ f ] [
    [
        1000000000000000000000000000000000 [ ] times
    ] \ +-integer-fixnum inlined?
] unit-test

[ f ] [
    [ { bignum } declare [ ] times ]
    \ +-integer-fixnum inlined?
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
    2over >= [
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

GENERIC: detect-float ( a -- b )

M: float detect-float ;

[ t ] [
    [ { real float } declare + detect-float ]
    \ detect-float inlined?
] unit-test

[ t ] [
    [ { float real } declare + detect-float ]
    \ detect-float inlined?
] unit-test

[ t ] [
    [ 3 + = ] \ equal? inlined?
] unit-test

[ t ] [
    [ { fixnum fixnum } declare 7 bitand neg shift ]
    \ shift inlined?
] unit-test

[ t ] [
    [ { fixnum fixnum } declare 7 bitand neg shift ]
    \ fixnum-shift inlined?
] unit-test

[ t ] [
    [ { fixnum fixnum } declare 1 swap 7 bitand shift ]
    \ fixnum-shift inlined?
] unit-test

cell-bits 32 = [
    [ t ] [
        [ { fixnum fixnum } declare 1 swap 31 bitand shift ]
        \ shift inlined?
    ] unit-test

    [ f ] [
        [ { fixnum fixnum } declare 1 swap 31 bitand shift ]
        \ fixnum-shift inlined?
    ] unit-test
] when

[ t ] [
    [ B{ 1 0 } *short 0 number= ]
    \ number= inlined?
] unit-test

[ t ] [
    [ B{ 1 0 } *short 0 { number number } declare number= ]
    \ number= inlined?
] unit-test

[ t ] [
    [ B{ 1 0 } *short 0 = ]
    \ number= inlined?
] unit-test

[ t ] [
    [ B{ 1 0 } *short dup number? [ 0 number= ] [ drop f ] if ]
    \ number= inlined?
] unit-test

[ t ] [
    [ HEX: ff bitand 0 HEX: ff between? ]
    \ >= inlined?
] unit-test

[ t ] [
    [ HEX: ff swap HEX: ff bitand >= ]
    \ >= inlined?
] unit-test

[ t ] [
    [ { vector } declare nth-unsafe ] \ nth-unsafe inlined?
] unit-test

[ t ] [
    [
        dup integer? [
            dup fixnum? [
                1 +
            ] [
                2 +
            ] if
        ] when
    ] \ + inlined?
] unit-test

[ f ] [
    [
        256 mod
    ] { mod fixnum-mod } inlined?
] unit-test

[ f ] [
    [
        dup 0 >= [ 256 mod ] when
    ] { mod fixnum-mod } inlined?
] unit-test

[ t ] [
    [
        { integer } declare dup 0 >= [ 256 mod ] when
    ] { mod fixnum-mod } inlined?
] unit-test

[ t ] [
    [
        { integer } declare 256 rem
    ] { mod fixnum-mod } inlined?
] unit-test

[ t ] [
    [
        { integer } declare [ 256 rem ] map
    ] { mod fixnum-mod rem } inlined?
] unit-test

[ t ] [
    [ 1000 [ 1+ ] map ] { 1+ fixnum+ } inlined?
] unit-test

: fib ( m -- n )
    dup 2 < [ drop 1 ] [ dup 1 - fib swap 2 - fib + ] if ; inline

[ t ] [
    [ 27.0 fib ] { < - } inlined?
] unit-test

[ t ] [
    [ 27 fib ] { < - } inlined?
] unit-test

[ t ] [
    [ 27 >bignum fib ] { < - } inlined?
] unit-test

[ f ] [
    [ 27/2 fib ] { < - } inlined?
] unit-test

[ t ] [
    [ { fixnum } declare 10 [ -1 shift ] times ] \ shift inlined?
] unit-test

[ f ] [
    [ { integer } declare 10 [ -1 shift ] times ] \ shift inlined?
] unit-test

[ f ] [
    [ { fixnum } declare 1048575 fixnum-bitand 524288 fixnum- ]
    \ fixnum-bitand inlined?
] unit-test

[ t ] [
    [ { integer } declare 127 bitand 3 + ]
    { + +-integer-fixnum +-integer-fixnum-fast bitand } inlined?
] unit-test

[ f ] [
    [ { integer } declare 127 bitand 3 + ]
    { >fixnum } inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ drop ] each-integer ]
    { < <-integer-fixnum +-integer-fixnum + } inlined?
] unit-test

[ t ] [
    [ { fixnum } declare length [ drop ] each-integer ]
    { < <-integer-fixnum +-integer-fixnum + } inlined?
] unit-test

[ t ] [
    [ { fixnum } declare [ drop ] each ]
    { < <-integer-fixnum +-integer-fixnum + } inlined?
] unit-test

[ t ] [
    [ { fixnum } declare 0 [ + ] reduce ]
    { < <-integer-fixnum } inlined?
] unit-test

[ f ] [
    [ { fixnum } declare 0 [ + ] reduce ]
    \ +-integer-fixnum inlined?
] unit-test

[ t ] [
    [
        { integer } declare
        dup 0 >= [
            615949 * 797807 + 20 2^ mod dup 19 2^ -
        ] [ dup ] if
    ] { * + shift mod fixnum-mod fixnum* fixnum+ fixnum- } inlined?
] unit-test

[ t ] [
    [
        { fixnum } declare
        615949 * 797807 + 20 2^ mod dup 19 2^ -
    ] { >fixnum } inlined?
] unit-test

[ f ] [
    [
        { integer } declare [ ] map
    ] \ >fixnum inlined?
] unit-test

[ f ] [
    [
        { integer } declare { } set-nth-unsafe
    ] \ >fixnum inlined?
] unit-test

[ f ] [
    [
        { integer } declare 1 + { } set-nth-unsafe
    ] \ >fixnum inlined?
] unit-test

[ t ] [
    [
        { integer } declare 0 swap
        [
            drop 615949 * 797807 + 20 2^ rem dup 19 2^ -
        ] map
    ] { * + shift rem mod fixnum-mod fixnum* fixnum+ fixnum- } inlined?
] unit-test

[ t ] [
    [
        { fixnum } declare 0 swap
        [
            drop 615949 * 797807 + 20 2^ rem dup 19 2^ -
        ] map
    ] { * + shift rem mod fixnum-mod fixnum* fixnum+ fixnum- >fixnum } inlined?
] unit-test

! Later

! [ t ] [
!     [
!         { integer } declare [ 256 mod ] map
!     ] { mod fixnum-mod } inlined?
! ] unit-test
! 
! [ t ] [
!     [
!         { integer } declare [ 0 >= ] map
!     ] { >= fixnum>= } inlined?
! ] unit-test
