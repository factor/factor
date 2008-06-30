USING: arrays byte-arrays kernel kernel.private math memory
namespaces sequences tools.test math.private quotations
continuations prettyprint io.streams.string debugger assocs ;
IN: kernel.tests

[ 0 ] [ f size ] unit-test
[ t ] [ [ \ = \ = ] all-equal? ] unit-test

! Don't leak extra roots if error is thrown
[ ] [ 10000 [ [ 3 throw ] ignore-errors ] times ] unit-test

[ ] [ 10000 [ [ -1 f <array> ] ignore-errors ] times ] unit-test

! Make sure we report the correct error on stack underflow
[ clear drop ] [ { "kernel-error" 11 f f } = ] must-fail-with

[ ] [ :c ] unit-test

[ { } set-retainstack r> ] [ { "kernel-error" 13 f f } = ] must-fail-with

[ ] [ :c ] unit-test

: overflow-d 3 overflow-d ;

[ overflow-d ] [ { "kernel-error" 12 f f } = ] must-fail-with

[ ] [ :c ] unit-test

: (overflow-d-alt) 3 ;

: overflow-d-alt (overflow-d-alt) overflow-d-alt ;

[ overflow-d-alt ] [ { "kernel-error" 12 f f } = ] must-fail-with

[ ] [ [ :c ] with-string-writer drop ] unit-test

: overflow-r 3 >r overflow-r ;

[ overflow-r ] [ { "kernel-error" 14 f f } = ] must-fail-with

[ ] [ :c ] unit-test

[ -7 <byte-array> ] must-fail

[ 2 3 4 1 ] [ 1 2 3 4 roll ] unit-test
[ 1 2 3 4 ] [ 2 3 4 1 -roll ] unit-test

[ 3 ] [ t 3 and ] unit-test
[ f ] [ f 3 and ] unit-test
[ f ] [ 3 f and ] unit-test
[ 4 ] [ 4 6 or ] unit-test
[ 6 ] [ f 6 or ] unit-test

[ slip ] must-fail
[ ] [ :c ] unit-test

[ 1 slip ] must-fail
[ ] [ :c ] unit-test

[ 1 2 slip ] must-fail
[ ] [ :c ] unit-test

[ 1 2 3 slip ] must-fail
[ ] [ :c ] unit-test


[ 5 ] [ [ 2 2 + ] 1 slip + ] unit-test

[ [ ] keep ] must-fail

[ 6 ] [ 2 [ sq ] keep + ] unit-test

[ [ ] 2keep ] must-fail
[ 1 [ ] 2keep ] must-fail
[ 3 1 2 ] [ 1 2 [ 2drop 3 ] 2keep ] unit-test

[ 0 ] [ f [ sq ] [ 0 ] if* ] unit-test
[ 4 ] [ 2 [ sq ] [ 0 ] if* ] unit-test

[ 0 ] [ f [ 0 ] unless* ] unit-test
[ t ] [ t [ "Hello" ] unless* ] unit-test

[ "2\n" ] [ [ 1 2 [ . ] [ sq . ] ?if ] with-string-writer ] unit-test
[ "9\n" ] [ [ 3 f [ . ] [ sq . ] ?if ] with-string-writer ] unit-test

[ f ] [ f (clone) ] unit-test
[ -123 ] [ -123 (clone) ] unit-test

[ 6 2 ] [ 1 2 [ 5 + ] dip ] unit-test

[ ] [ callstack set-callstack ] unit-test

[ 3drop datastack ] must-fail
[ ] [ :c ] unit-test

! Doesn't compile; important
: foo 5 + 0 [ ] each ;

[ drop foo ] must-fail
[ ] [ :c ] unit-test

! Regression
: (loop) ( a b c d -- )
    >r pick r> swap >r pick r> swap
    < [ >r >r >r 1+ r> r> r> (loop) ] [ 2drop 2drop ] if ; inline

: loop ( obj obj -- )
    H{ } values swap >r dup length swap r> 0 -roll (loop) ;

[ loop ] must-fail

! Discovered on Windows
: total-failure-1 "" [ ] map unimplemented ;

[ total-failure-1 ] must-fail

: total-failure-2 [ ] (call) unimplemented ;

[ total-failure-2 ] must-fail

! From combinators.lib
[ 1 1 2 2 3 3 ] [ 1 2 3 [ dup ] tri@ ] unit-test
[ 1 4 9 ] [ 1 2 3 [ sq ] tri@ ] unit-test
[ [ sq ] tri@ ] must-infer
