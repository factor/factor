IN: temporary
USING: alien strings compiler tools.test math kernel words
math.private combinators ;

: dummy-if-1 t [ ] [ ] if ;

[ ] [ dummy-if-1 ] unit-test

: dummy-if-2 f [ ] [ ] if ;

[ ] [ dummy-if-2 ] unit-test

: dummy-if-3 t [ 1 ] [ 2 ] if ;

[ 1 ] [ dummy-if-3 ] unit-test

: dummy-if-4 f [ 1 ] [ 2 ] if ;

[ 2 ] [ dummy-if-4 ] unit-test

: dummy-if-5 0 dup 1 fixnum<= [ drop 1 ] [ ] if ;

[ 1 ] [ dummy-if-5 ] unit-test

: dummy-if-6
    dup 1 fixnum<= [
        drop 1
    ] [
        1 fixnum- dup 1 fixnum- fixnum+
    ] if ;

[ 17 ] [ 10 dummy-if-6 ] unit-test

: dead-code-rec
    t [
        3.2
    ] [
        dead-code-rec
    ] if ;

[ 3.2 ] [ dead-code-rec ] unit-test

: one-rec [ f one-rec ] [ "hi" ] if ;

[ "hi" ] [ t one-rec ] unit-test

: after-if-test
    t [ ] [ ] if 5 ;

[ 5 ] [ after-if-test ] unit-test

DEFER: countdown-b

: countdown-a ( n -- ) dup 0 eq? [ drop ] [ 1 fixnum- countdown-b ] if ;
: countdown-b ( n -- ) dup 0 eq? [ drop ] [ 1 fixnum- countdown-a ] if ;

[ ] [ 10 countdown-b ] unit-test

: dummy-when-1 t [ ] when ;

[ ] [ dummy-when-1 ] unit-test

: dummy-when-2 f [ ] when ;

[ ] [ dummy-when-2 ] unit-test

: dummy-when-3 dup [ dup fixnum* ] when ;

[ 16 ] [ 4 dummy-when-3 ] unit-test
[ f ] [ f dummy-when-3 ] unit-test

: dummy-when-4 dup [ dup dup fixnum* fixnum* ] when swap ;

[ 64 f ] [ f 4 dummy-when-4 ] unit-test
[ f t ] [ t f dummy-when-4 ] unit-test

: dummy-when-5 f [ dup fixnum* ] when ;

[ f ] [ f dummy-when-5 ] unit-test

: dummy-unless-1 t [ ] unless ;

[ ] [ dummy-unless-1 ] unit-test

: dummy-unless-2 f [ ] unless ;

[ ] [ dummy-unless-2 ] unit-test

: dummy-unless-3 dup [ drop 3 ] unless ;

[ 3 ] [ f dummy-unless-3 ] unit-test
[ 4 ] [ 4 dummy-unless-3 ] unit-test

! Test cond expansion
[ "even" ] [
    [
        2 {
            { [ dup 2 mod 0 = ] [ drop "even" ] }
            { [ dup 2 mod 1 = ] [ drop "odd" ] }
        } cond
    ] compile-1
] unit-test

[ "odd" ] [
    [
        3 {
            { [ dup 2 mod 0 = ] [ drop "even" ] }
            { [ dup 2 mod 1 = ] [ drop "odd" ] }
        } cond
    ] compile-1
] unit-test

[ "neither" ] [
    [
        3 {
            { [ dup string? ] [ drop "string" ] }
            { [ dup float? ] [ drop "float" ] }
            { [ dup alien? ] [ drop "alien" ] }
            { [ t ] [ drop "neither" ] }
        } cond
    ] compile-1
] unit-test

[ 3 ] [
    [
        3 {
            { [ dup fixnum? ] [ ] }
            { [ t ] [ drop t ] }
        } cond
    ] compile-1
] unit-test
