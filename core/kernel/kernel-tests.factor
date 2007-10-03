USING: arrays byte-arrays kernel kernel.private math memory
namespaces sequences tools.test math.private quotations
continuations prettyprint io.streams.string ;
IN: temporary

[ 0 ] [ f size ] unit-test
[ t ] [ [ \ = \ = ] all-equal? ] unit-test

! Don't leak extra roots if error is thrown
[ ] [ 10000 [ [ 3 throw ] catch drop ] times ] unit-test

[ ] [ 10000 [ [ -1 f <array> ] catch drop ] times ] unit-test

! Make sure we report the correct error on stack underflow
[ { "kernel-error" 11 f f } ]
[ [ clear drop ] catch ] unit-test

[ { "kernel-error" 13 f f } ]
[ [ { } set-retainstack r> ] catch ] unit-test

: overflow-d 3 overflow-d ;

[ { "kernel-error" 12 f f } ]
[ [ overflow-d ] catch ] unit-test

: overflow-r 3 >r overflow-r ;

[ { "kernel-error" 14 f f } ]
[ [ overflow-r ] catch ] unit-test

! : overflow-c overflow-c 3 ;
! 
! [ { "kernel-error" 16 f f } ]
! [ [ overflow-c ] catch ] unit-test

[ -7 <byte-array> ] unit-test-fails

[ 2 3 4 1 ] [ 1 2 3 4 roll ] unit-test
[ 1 2 3 4 ] [ 2 3 4 1 -roll ] unit-test

[ 3 ] [ t 3 and ] unit-test
[ f ] [ f 3 and ] unit-test
[ f ] [ 3 f and ] unit-test
[ 4 ] [ 4 6 or ] unit-test
[ 6 ] [ f 6 or ] unit-test

[ slip ] unit-test-fails
[ 1 slip ] unit-test-fails
[ 1 2 slip ] unit-test-fails
[ 1 2 3 slip ] unit-test-fails

[ 5 ] [ [ 2 2 + ] 1 slip + ] unit-test

[ [ ] keep ] unit-test-fails

[ 6 ] [ 2 [ sq ] keep + ] unit-test

[ [ ] 2keep ] unit-test-fails
[ 1 [ ] 2keep ] unit-test-fails
[ 3 1 2 ] [ 1 2 [ 2drop 3 ] 2keep ] unit-test

[ 0 ] [ f [ sq ] [ 0 ] if* ] unit-test
[ 4 ] [ 2 [ sq ] [ 0 ] if* ] unit-test

[ 0 ] [ f [ 0 ] unless* ] unit-test
[ t ] [ t [ "Hello" ] unless* ] unit-test

[ "2\n" ] [ [ 1 2 [ . ] [ sq . ] ?if ] string-out ] unit-test
[ "9\n" ] [ [ 3 f [ . ] [ sq . ] ?if ] string-out ] unit-test

[ f ] [ f (clone) ] unit-test
[ -123 ] [ -123 (clone) ] unit-test

[ 6 2 ] [ 1 2 [ 5 + ] dip ] unit-test

[ ] [ callstack set-callstack ] unit-test

[ 3drop datastack ] unit-test-fails
