IN: temporary
USE: compiler
USE: test
USE: words
USE: lists
USE: math
USE: kernel

! Test shuffle intrinsics
[ ] [ 1 [ drop ] compile-1 ] unit-test
[ ] [ 1 2 [ 2drop ] compile-1 ] unit-test
[ ] [ 1 2 3 [ 3drop ] compile-1 ] unit-test
[ 1 1 ] [ 1 [ dup ] compile-1 ] unit-test
[ 1 2 1 2 ] [ 1 2 [ 2dup ] compile-1 ] unit-test
[ 1 2 3 1 2 3 ] [ 1 2 3 [ 3dup ] compile-1 ] unit-test
[ 2 3 1 ] [ 1 2 3 [ rot ] compile-1 ] unit-test
[ 3 1 2 ] [ 1 2 3 [ -rot ] compile-1 ] unit-test
[ 1 1 2 ] [ 1 2 [ dupd ] compile-1 ] unit-test
[ 2 1 3 ] [ 1 2 3 [ swapd ] compile-1 ] unit-test
[ 2 ] [ 1 2 [ nip ] compile-1 ] unit-test
[ 3 ] [ 1 2 3 [ 2nip ] compile-1 ] unit-test
[ 2 1 2 ] [ 1 2 [ tuck ] compile-1 ] unit-test
[ 1 2 1 ] [ 1 2 [ over ] compile-1 ] unit-test
[ 1 2 3 1 ] [ 1 2 3 [ pick ] compile-1 ] unit-test
[ 2 1 ] [ 1 2 [ swap ] compile-1 ] unit-test

! Test various kill combinations

: kill-1
    [ 1 2 3 ] [ + ] over drop drop ; compiled

[ [ 1 2 3 ] ] [ kill-1 ] unit-test

: kill-2
    [ + ] [ 1 2 3 ] over drop nip ; compiled

[ [ 1 2 3 ] ] [ kill-2 ] unit-test

: kill-3
    [ + ] dup over 3drop ;

[ ] [ kill-3 ] unit-test

: kill-4
    [ 1 2 3 ] [ + ] [ - ] pick >r 2drop r> ; compiled

[ [ 1 2 3 ] [ 1 2 3 ] ] [ kill-4 ] unit-test

: kill-5
    [ + ] [ - ] [ 1 2 3 ] pick pick 2drop >r 2drop r> ; compiled

[ [ 1 2 3 ] ] [ kill-5 ] unit-test

: kill-6
    [ 1 2 3 ] [ 4 5 6 ] [ + ] pick >r drop r> ; compiled

[ [ 1 2 3 ] [ 4 5 6 ] [ 1 2 3 ] ] [ kill-6 ] unit-test
