IN: temporary
USING: arrays byte-arrays kernel kernel-internals math memory
namespaces sequences test errors math-internals
quotations ;

[ 0 ] [ f size ] unit-test
[ t ] [ [ \ = \ = ] all-equal? ] unit-test

! Don't leak extra roots if error is thrown
[ ] [ 10000 [ [ -1 f <array> ] catch drop ] times ] unit-test

[ t ] [ cell integer? ] unit-test
[ t ] [ bootstrap-cell integer? ] unit-test

[ [ 3 ] ] [ 3 f curry ] unit-test
[ [ \ + ] ] [ \ + f curry ] unit-test
[ [ \ + = ] ] [ \ + [ = ] curry ] unit-test

! Make sure we report the correct error on stack underflow
[ { kernel-error 11 f f } ]
[ [ clear drop ] catch ] unit-test

[ { kernel-error 13 f f } ]
[ [ V{ } set-retainstack r> ] catch ] unit-test

: overflow-d 3 overflow-d ;

[ { kernel-error 12 f f } ]
[ [ overflow-d ] catch ] unit-test

: overflow-r 3 >r overflow-r ;

[ { kernel-error 14 f f } ]
[ [ overflow-r ] catch ] unit-test

! [ { kernel-error 15 f f } ]
! [ [ V{ } set-callstack ] catch ] unit-test

: overflow-c overflow-c 3 ;

[ { kernel-error 16 f f } ]
[ [ overflow-c ] catch ] unit-test

[ -7 <byte-array> ] unit-test-fails

[ 2 3 4 1 ] [ 1 2 3 4 roll ] unit-test
[ 1 2 3 4 ] [ 2 3 4 1 -roll ] unit-test

[ 3 ] [ t 3 and ] unit-test
[ f ] [ f 3 and ] unit-test
[ f ] [ 3 f and ] unit-test
[ 4 ] [ 4 6 or ] unit-test
[ 6 ] [ f 6 or ] unit-test

! some primitives are missing GC checks
! these tests take a long time to run and they have dubious value
! we always GC check in allot() now

! [ ] [ 1000000 [ drop H{ } clone >n n> drop ] each ] unit-test
! [ ] [ 1.0 1000000 [ 1.0 * ] times drop ] unit-test
! [ ] [ 268435455 >fixnum 1000000 [ dup dup + drop ] times drop ] unit-test
! [ ] [ 268435455 >fixnum 1000000 [ dup dup fixnum+ drop ] times drop ] unit-test
! [ ] [ 1000000 [ drop 1/3 >fixnum drop ] each ] unit-test
! [ ] [ 1000000 [ drop 1/3 >bignum drop ] each ] unit-test
! [ ] [ 1000000 [ drop 1/3 >float drop ] each ] unit-test
