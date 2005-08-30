IN: temporary
USING: alien strings ;
USE: compiler
USE: test
USE: math
USE: kernel
USE: words
USE: math-internals

: dummy-ifte-1 t [ ] [ ] ifte ; compiled

[ ] [ dummy-ifte-1 ] unit-test

: dummy-ifte-2 f [ ] [ ] ifte ; compiled

[ ] [ dummy-ifte-2 ] unit-test

: dummy-ifte-3 t [ 1 ] [ 2 ] ifte ; compiled

[ 1 ] [ dummy-ifte-3 ] unit-test

: dummy-ifte-4 f [ 1 ] [ 2 ] ifte ; compiled

[ 2 ] [ dummy-ifte-4 ] unit-test

: dummy-ifte-5 0 dup 1 fixnum<= [ drop 1 ] [ ] ifte ; compiled

[ 1 ] [ dummy-ifte-5 ] unit-test

: dummy-ifte-6
    dup 1 fixnum<= [
        drop 1
    ] [
        1 fixnum- dup swap 1 fixnum- fixnum+
    ] ifte ;

[ 17 ] [ 10 dummy-ifte-6 ] unit-test

: dead-code-rec
    t [
        #{ 3 2 }#
    ] [
        dead-code-rec
    ] ifte ; compiled

[ #{ 3 2 }# ] [ dead-code-rec ] unit-test

: one-rec [ f one-rec ] [ "hi" ] ifte ; compiled

[ "hi" ] [ t one-rec ] unit-test

: after-ifte-test
    t [ ] [ ] ifte 5 ; compiled

[ 5 ] [ after-ifte-test ] unit-test

DEFER: countdown-b

: countdown-a ( n -- ) dup 0 eq? [ drop ] [ 1 fixnum- countdown-b ] ifte ;
: countdown-b ( n -- ) dup 0 eq? [ drop ] [ 1 fixnum- countdown-a ] ifte ; compiled

[ ] [ 10 countdown-b ] unit-test

: dummy-when-1 t [ ] when ; compiled

[ ] [ dummy-when-1 ] unit-test

: dummy-when-2 f [ ] when ; compiled

[ ] [ dummy-when-2 ] unit-test

: dummy-when-3 dup [ dup fixnum* ] when ; compiled

[ 16 ] [ 4 dummy-when-3 ] unit-test
[ f ] [ f dummy-when-3 ] unit-test

: dummy-when-4 dup [ dup dup fixnum* fixnum* ] when swap ; compiled

[ 64 f ] [ f 4 dummy-when-4 ] unit-test
[ f t ] [ t f dummy-when-4 ] unit-test

: dummy-when-5 f [ dup fixnum* ] when ; compiled

[ f ] [ f dummy-when-5 ] unit-test

: dummy-unless-1 t [ ] unless ; compiled

[ ] [ dummy-unless-1 ] unit-test

: dummy-unless-2 f [ ] unless ; compiled

[ ] [ dummy-unless-2 ] unit-test

: dummy-unless-3 dup [ drop 3 ] unless ; compiled

[ 3 ] [ f dummy-unless-3 ] unit-test
[ 4 ] [ 4 dummy-unless-3 ] unit-test

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
